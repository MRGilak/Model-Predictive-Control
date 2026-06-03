function [A, B] = linearize_dynamics(x, Ts)
    x1 = x(1);

    dfdx = [ 0, 1;
            -0.33*(1 - x1)*exp(-x1), -1.1];
    dfdu = [0; 1];

    A = eye(2) + dfdx * Ts;
    B = dfdu * Ts;
end
