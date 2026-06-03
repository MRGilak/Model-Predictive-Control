function step_response = get_step_response_nonlinear(x0, u0, Ts, N_model)
    du = 1e-2;

    x = x0;
    y0 = zeros(N_model, 1);
    for i = 1:N_model
        x = systems.model.epfc.update_nonlinear_state(x, u0, Ts);
        y0(i) = x(1);
    end

    x = x0;
    y1 = zeros(N_model, 1);
    for i = 1:N_model
        x = systems.model.epfc.update_nonlinear_state(x, u0 + du, Ts);
        y1(i) = x(1);
    end

    step_response = (y1 - y0) / du;
end
