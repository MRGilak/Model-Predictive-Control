function [results, sr] = simulate_nonlinear_system(params)
    A_lin = [0, 1; -1.79, -1.1];
    B_lin = [0; 1];
    C_lin = [1, 0];

    N = params.N;
    Ts = params.Ts;

    sys_c = ss(A_lin, B_lin, C_lin, 0);
    sys_d = c2d(sys_c, Ts);

    N_model = params.N_model;
    Ref = padarray(params.Ref(:), max(0, N - numel(params.Ref)), 'replicate', 'post');

    [sr_all, ~] = step(sys_d, (0:N_model)*Ts);
    sr = sr_all(2:end);

    % Initialize p with y set to x0(1)
    Struct = struct('sr', sr, 'p', params.P, 'm', params.M, ...
               'a', params.alpha, 'Q', params.Q, 'R', params.R, ...
               'y', params.x0(1), 'v', [], 'u', 0, ...
               'is_programmed', params.is_programmed, ...
               'is_open_loop', params.is_open_loop);

    x0 = params.x0;
    Struct.y0 = x0(1);
    Struct.x0 = x0;
    Struct.u0 = params.u0_nonlinear;

    Y = zeros(N, 1);
    Y(1) = x0(1);

    results = struct('Y', Y, 'U', zeros(N,1), 'X', zeros(N,2), ...
                     'DU', zeros(N,1), 'Ref_filtered', zeros(N,1), ...
                     'time', (0:N-1)'*Ts);

    x = x0(:);  % Absolute coordinates for nonlinear system
    disturbance_start_step = round(params.disturbance_start_time / Ts);

    for k = 1:N
        ref_window = Ref(k:min(N,k+params.P-1));
        Struct.r = ref_window;

        % Compute control
        Struct = dmc_nonlinear(Struct, x, params.Ts);

        % Store control inputs
        results.U(k) = Struct.u;
        results.DU(k) = Struct.du;

        % Disturbances and noise
        w1 = params.disturbance_amp * (k >= disturbance_start_step & k <= (disturbance_start_step + 1));
        w2 = wgn(1, 1, params.noise_power);

        % Apply full absolute input
        u_actual = results.U(k);

        % Nonlinear system
        x = update_nonlinear_state(x, u_actual, Ts) + [w1; 0];
        y = x(1) + w2;
        results.Y(k) = y;
        results.X(k,:) = x';

        % Feedback
        Struct.y = results.Y(k);

        % Reference filtering
        if k == 1
            results.Ref_filtered(k) = Ref(k);
        else
            results.Ref_filtered(k) = params.alpha * results.Ref_filtered(k - 1) + (1 - params.alpha) * Ref(k);
        end

        results.d(k) = Struct.d;
        results.y_prev(k) = Struct.y_prev;
    end
end