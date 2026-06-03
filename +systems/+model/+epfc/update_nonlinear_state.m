function x_next = update_nonlinear_state(x, u, Ts, disturbance)
    if nargin < 4
        disturbance = 0;
    end
    substeps = 20;
    dt = Ts / substeps;
    x1 = x(1); x2 = x(2);

    for j = 1:substeps
        dx1 = x2;
        dx2 = -0.33 * exp(-x1) * x1 - 1.1 * x2 + u + disturbance;
        x1 = x1 + dt * dx1;
        x2 = x2 + dt * dx2;
    end

    x_next = [x1; x2];
end
