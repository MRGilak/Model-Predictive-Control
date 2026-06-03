function results = simulate_closed_loop(linearization_method, Ts, tf, N_model, mu, m, q, r, psi, ...
                                        noise_power, dist_amp, dist_time, dist_duration, ...
                                        u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref, ...
                                        update_actual_fn, update_model_fn)
    if nargin < 22
        is_programmed_ref = false;
    end
    if nargin < 23 || isempty(update_actual_fn)
        update_actual_fn = @systems.model.epfc.update_nonlinear_state;
    end
    if nargin < 24 || isempty(update_model_fn)
        update_model_fn = @systems.model.epfc.update_nonlinear_state;
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

    controller_cfg = struct(...
        'linearization_method', linearization_method, ...
        'Ts', Ts, ...
        'N_model', N_model, ...
        'mu', mu, ...
        'm', m, ...
        'q', q, ...
        'r', r, ...
        'psi', psi, ...
        'u_min', u_min, ...
        'u_max', u_max, ...
        'beta', beta, ...
        'Ni', Ni, ...
        'TOL', TOL, ...
        'is_programmed_ref', is_programmed_ref, ...
        'x0', x0, ...
        'u0', u0, ...
        'linearize_fn', @systems.model.epfc.linearize_dynamics, ...
        'step_response_fn', @systems.model.epfc.get_step_response_nonlinear, ...
        'model_step_fn', update_model_fn);

    controller = controllers.epfc.EPFCController(controller_cfg);

    x_actual = x0;
    x_model = x0;
    dist_sample = dist_time / Ts;

    for k = 2:N
        current_y = Y(k - 1);
        current_ref = Ref(k);
        ref_future = Ref(k:end);

        [u, info] = controller.step(x_model, current_y, current_ref, ref_future);

        if k >= dist_sample && k < dist_sample + dist_duration
            dist = dist_amp;
        else
            dist = 0;
        end

        x_model = update_model_fn(x_model, u, Ts);
        x_actual = update_actual_fn(x_actual, u, Ts, dist);
        y = x_actual(1) + wgn(1, 1, noise_power);

        Y(k) = y;
        U(k) = u;
        DU(k) = info.du;
        D(k) = info.d_ext;
        V(k) = info.v;
        X(k, :) = x_actual';
    end

    results = struct('Y', Y, 'U', U, 'V', V, 'DU', DU, ...
                     'D', D, 'X', X, 'time', (0:N-1)' * Ts);
end
