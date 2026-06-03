function x_next = update_nonlinear_state(x, u, Ts, disturbance)
    if nargin < 4
        disturbance = 0;
    end
    x_next = systems.model.dmc.update_nonlinear_state(x, u, Ts) + [disturbance; 0];
end
