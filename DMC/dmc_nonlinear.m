function Struct = dmc_nonlinear(Struct, x_now, ts)
    if ~isfield(Struct, 'upast') || isempty(Struct.upast)
        N = numel(Struct.sr);
        n = N - Struct.p;
        Struct.upast = zeros(n, 1);

        % Ypast matrix
        step_response = Struct.sr(1:n);

        % Toeplitz Matrix
        Struct.G = toeplitz(Struct.sr(1:Struct.p), Struct.sr(1)*eye(1,Struct.m)); % Toeplitz

        % DMC gain
        Q = diag(Struct.Q);
        R = diag(Struct.R);
        K = (Struct.G'*Q*Struct.G + R) \ (Struct.G'*Q);
        Struct.k = K(1, :);

        % Control variables
        Struct.u = -0.897;
        Struct.u_prev = -0.897;
        Struct.d = 0;
        Struct.control = zeros(Struct.m, 1);
        Struct.block_counter = 0;

        if isfield(Struct, 'x0')
            Struct.y_prev = Struct.x0(1);
            Struct.y = Struct.x0(1);
        else
            Struct.y_prev = 0;
            Struct.y = 0;
        end
    end

    % Disturbance
    if isfield(Struct, 'is_open_loop') && Struct.is_open_loop
        Struct.d = 0;
    else
        Struct.d = Struct.y - Struct.y_prev;
    end

    D = ones(Struct.p,1) * Struct.d;

    Ypast = zeros(Struct.p, 1);
    u_current = Struct.u_prev;
    x = x_now;
    for k = 1:Struct.p
        x = update_nonlinear_state(x, u_current, ts);
        Ypast(k) = x(1);
    end

    if Struct.is_programmed 
        number_reference = numel(Struct.r);
        if number_reference >= Struct.p
            ref = Struct.r(1:Struct.p);
        else
            ref = [Struct.r(:); Struct.r(end) * ones(Struct.p - number_reference, 1)];
        end
    else
        ref = Struct.r(1) * ones(Struct.p, 1);  % Unprogrammed: assume reference stays constant
    end

    Struct.w = filter([0 (1-Struct.a)], [1 -Struct.a], ref, Struct.y); % Filtered Reference

    Q = diag(Struct.Q);
    R = diag(Struct.R);
    K = (Struct.G'*Q*Struct.G + R) \ (Struct.G'*Q);
    Struct.Ebar = Struct.w - Ypast - D;
    Struct.control = K * Struct.Ebar;

    % Apply control input
    Struct.du = Struct.control(1);
    Struct.upast = [Struct.du; Struct.upast(1:end-1)];
    Struct.u = Struct.u_prev + Struct.du;

    % Predict next output
    Struct.y_prev = Ypast(1) + Struct.G(1, 1) * Struct.du;

    % Shift and update
    Struct.control = [Struct.control(2:end); 0];
    Struct.u_prev = Struct.u;
end