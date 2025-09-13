clear; close all; clc;

%% Set parameters
params = get_base_params();
gamma_values = [0.01, 1, 100];

%% Simulate
for i = 1:length(gamma_values)
    params = get_base_params();
    params.R = gamma_values(i) * 0.3107 * ones(params.M, 1);

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results(results_lin, results_nonlin, params, gamma_values, '\gamma', true)
