clear; close all; clc;

%% Set parameters
params = get_base_params();
Q_values = [1, 10, 'decreasing'];

%% Simulate
for i = 1:length(Q_values)
    params = get_base_params();
    if i < 3
        params.Q = Q_values(i) * ones(params.P, 1);
    end
    if i == 3
        params.Q = linspace(5, 0.01, params.P);
    end

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results_for_Q(results_lin, results_nonlin, params, Q_values, 'Q', true)
