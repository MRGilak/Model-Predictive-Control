function [results, sr] = simulate_linear_system(params)
    A_lin = [0, 1; -1.7941, -1.1];
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

    x0 = params.x0;
    controller_cfg = struct('sr', sr, 'p', params.P, 'm', params.M, ...
        'a', params.alpha, 'Q', params.Q, 'R', params.R, ...
        'u0', params.u0_linear, 'y0', x0(1), ...
        'is_programmed', params.is_programmed, ...
        'is_open_loop', params.is_open_loop, ...
        'mode', 'linear');
    controller = controllers.dmc.DMCController(controller_cfg);

    if isfield(params, 'actual_linear_step_fn')
        actual_linear_step_fn = params.actual_linear_step_fn;
    else
        actual_linear_step_fn = @systems.model.dmc.update_linear_state;
    end

    Y = zeros(N, 1);
    Y(1) = x0(1);

    results = struct('Y', Y, 'U', zeros(N,1), 'X', zeros(N,2), ...
                     'DU', zeros(N,1), 'Ref_filtered', zeros(N,1), ...
                     'time', (0:N-1)'*Ts, 'F', [], 'G', [], 'sr_all', [], ...
                     'd', zeros(N, 1), 'Ebar', zeros(N, params.P));

    x = x0(:);
    y_measured = x0(1);
    disturbance_start_step = round(params.disturbance_start_time / Ts);

    for k = 1:N
        ref_window = Ref(k:min(N, k+params.P-1));
        [u_next, info] = controller.step(y_measured, ref_window);

        % Store control inputs
        results.U(k) = u_next;
        results.DU(k) = info.du;

        % Disturbances and noise
        w3 = params.disturbance_amp * (k >= disturbance_start_step & k <= (disturbance_start_step + 1));
        w4 = wgn(1, 1, params.noise_power);

        % Apply full absolute input
        u_actual = results.U(k) + w3;

        % Linear system
        x = actual_linear_step_fn(sys_d, x, u_actual) + [w3; 0];
        y = sys_d.C * x + w4;
        results.Y(k) = y;
        results.X(k,:) = x';
        y_measured = y;

        % Reference filtering
        if k == 1
            results.Ref_filtered(k) = Ref(k);
        else
            results.Ref_filtered(k) = params.alpha * results.Ref_filtered(k - 1) + (1 - params.alpha) * Ref(k);
        end

        results.d(k) = info.d;
        results.Ebar(k, :) = info.Ebar(:)';
    end

    data = controller.internals();
    results.F = data.F;
    results.G = data.G;
    results.gainMatrix = data.gainMatrix;
    results.sr_all = sr_all;
end