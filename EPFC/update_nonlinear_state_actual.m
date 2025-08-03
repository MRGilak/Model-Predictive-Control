function x_next = update_nonlinear_state_actual(x, u, Ts, disturbance)
    if nargin < 4
        disturbance = 0;
    end
    substeps = 20;
    dt = Ts / substeps;
    x1 = x(1); x2 = x(2);

    % Assume the true system has a different constant, e.g., -0.4 instead of -0.33
    true_c1 = -0.4;   % Changed from -0.33 (original)
    true_c2 = -1.5;   % Keep the same or change as you want

    for j = 1:substeps
        dx1 = x2;
        dx2 = true_c1 * exp(-x1 * 1) * x1 + true_c2 * x2 + u + disturbance;
        x1 = x1 + dt * dx1;
        x2 = x2 + dt * dx2;
    end

    x_next = [x1; x2];
end
