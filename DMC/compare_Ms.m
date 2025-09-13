clear; close all; clc;

%% Set parameters
params = get_base_params();
M_values = [1, 6, 11];

%% Simulate
for i = 1:length(M_values)
    params = get_base_params();
    params.M = M_values(i);
    params.R = 0.3107 * ones(params.M, 1);

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results(results_lin, results_nonlin, params, M_values, 'M', true)
