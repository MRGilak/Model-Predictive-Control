function results = run_simulation(linearization_method, Ts, tf, N_model, mu, m, q, r, psi, ...
                                  noise_power, dist_amp, dist_time, dist_duration, ...
                                  u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref, ...
                                  update_actual_fn)
    if nargin < 22
        is_programmed_ref = false;
    end
    if nargin < 23 || isempty(update_actual_fn)
        update_actual_fn = @update_nonlinear_state; % Default (no uncertainty)
    end
    
    N = tf / Ts;
    C = [1, 0];
    
    Y = zeros(N, 1); Y(1) = C * x0;
    U = zeros(N, 1);
    V = zeros(N, 1);
    DU = zeros(N, 1);
    D = zeros(N, 1);
    X = zeros(N, 2);
    X(1, :) = x0';
    
    y_prev = C * x0;
    x_prev = x0;
    v_prev = 0;
    u_prev = u0;
    x_next = x0;
    dist_sample = dist_time / Ts;
    y_pred = x0(1);
    
    for k = 2:N
        x1_prev = x_prev(1);

        u_prev = -x1_prev + v_prev;
    
        if strcmp(linearization_method, 'jacobian')
            [A, B] = linearize_dynamics(x_prev, Ts);
            sys_d = ss(A, B, C, 0, Ts);
            [sr_all, ~] = step(sys_d, (0:N_model)*Ts);
            step_response = sr_all(1:end);
        elseif strcmp(linearization_method, 'perturbation')
            step_response = get_step_response_nonlinear(x_prev, u_prev, Ts, N_model);
        else
            error('Unknown linearization method');
        end
    
        G = zeros(length(mu), length(m));
        for i = 1:length(mu)
            for j = 1:length(m)
                idx = mu(i) - m(j);
                if idx > 0 && idx <= length(step_response)
                    G(i, j) = step_response(idx);
                else
                    G(i, j) = 0;
                end
            end
        end
    
        Tmat = zeros(length(mu), length(m));
        for i = 1:length(mu)
            for j = 1:length(m)
                idx = mu(i) - m(j);
                if idx > 0 && idx <= length(step_response)
                    Tmat(i, j) = step_response(idx);
                else
                    Tmat(i, j) = 0;
                end
            end
        end
    
        Ypast = zeros(max(mu), 1);
        x_tmp = x_prev;
        for t = 1:max(mu)
            u_sim = -x_tmp(1) + v_prev;
            x_tmp = update_nonlinear_state(x_tmp, u_sim, Ts);
            Ypast(t) = x_tmp(1);
        end
    
        current_ref = Ref(k);
        current_y = Y(k-1);
        if is_programmed_ref
            % Use future reference values
            Yd = zeros(1, length(mu));
            for i = 1:length(mu)
                idx = k + mu(i);  % future index
                if idx <= length(Ref)
                    ref_val = Ref(idx);
                else
                    ref_val = Ref(end);  % handle boundary
                end
                Yd(i) = psi(i) * current_y + (1 - psi(i)) * ref_val;
            end
        else
            % Use current reference only
            Yd = psi .* current_y + (1 - psi) .* current_ref;
        end
    
    
        Ym = Ypast(mu);
        d_ext = current_y - y_pred;
        D_ext = d_ext * ones(length(Ym), 1);
    
        % === Iterative Correction on D^nl ===
        D_nl = zeros(length(Ym), 1);
    
        for iter = 1:Ni
            D_total = D_ext + D_nl;
            e = Yd(:) - Ym - D_total;
    
            Q = diag(q);
            R = diag(r);
            H = G' * Q * G + R;
            f = -G' * Q * e;
    
            T = tril(ones(length(m)));
            use_constraints = isfinite(u_min) && isfinite(u_max);
    
            options = optimoptions('quadprog', 'Display', 'off');
    
            if use_constraints
                Aineq = [T; -T];
                bineq = [ (u_max + x1_prev - v_prev) * ones(length(m), 1);
                         -(u_min + x1_prev - v_prev) * ones(length(m), 1) ];
    
                dv = quadprog(H, f, Aineq, bineq, [], [], [], [], [], options);
            else
                dv = quadprog(H, f, [], [], [], [], [], [], [], options);
            end
    
            % Simulate nonlinear model to get Y_nl
            x_nl_tmp = x_prev;
            Y_nl = zeros(length(mu), 1);
            for i = 1:max(mu)
                if any(m == (i-1))
                    delta_idx = find(m == (i-1));
                    delta_u = dv(delta_idx);
                else
                    delta_u = 0;
                end
                u_sim = -x_nl_tmp(1) + v_prev + delta_u;
                x_nl_tmp = update_nonlinear_state(x_nl_tmp, u_sim, Ts);
                if any(mu == i)
                    Y_nl(mu == i) = x_nl_tmp(1);
                end
            end
    
            % Compute linear prediction with Toeplitz matrix
            Y_li = Tmat * dv + Ym;
            h = Y_nl - (Y_li + D_nl);
    
            D_nl_new = D_nl + beta * h;
    
            if norm(D_nl_new - D_nl) < TOL
                D_nl = D_nl_new;
                break;
            end
    
            D_nl = D_nl_new;
        end
    
        v = v_prev + dv(1);
        u = -x_next(1) + v;
    
        if k >= dist_sample && k < dist_sample + dist_duration
            dist = dist_amp;
        else
            dist = 0;
        end
    
        x_pred = update_nonlinear_state(x_prev, u, Ts);
        y_pred = x_pred(1);
    
        x_next = update_actual_fn(x_next, u, Ts, dist);
        y = x_next(1) + wgn(1, 1, noise_power);
    
        Y(k) = y;
        U(k) = u;
        DU(k) = dv(1);
        D(k) = d_ext;
        V(k) = v;
        X(k,:) = x_next';
    
        v_prev = v;
        y_prev = y;
        x_prev = x_next;
    end
    
    results = struct('Y', Y, 'U', U, 'V', V, 'DU', DU, ...
                     'D', D, 'X', X, 'time', (0:N-1)' * Ts);
end
