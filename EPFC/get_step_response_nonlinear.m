function step_response = get_step_response_nonlinear(x0, u0, Ts, N_model)
    % Small control perturbation
    du = 1e-2;

    % Simulate system with baseline control (u0)
    x = x0;
    y0 = zeros(N_model, 1);
    for i = 1:N_model
        x = update_nonlinear_state(x, u0, Ts);
        y0(i) = x(1);
    end

    % Simulate system with perturbed control (u0 + du)
    x = x0;
    y1 = zeros(N_model, 1);
    for i = 1:N_model
        x = update_nonlinear_state(x, u0 + du, Ts);
        y1(i) = x(1);
    end

    % Difference approximates step response
    step_response = (y1 - y0) / du;
end
