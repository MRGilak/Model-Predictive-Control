clear; close all; clc;

%% Set parameters
params = get_base_params();
alpha_values = [0.1, 0.5, 0.9];

%% Simulate
for i = 1:length(alpha_values)
    params = get_base_params();
    params.alpha = alpha_values(i);

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results_for_alpha(results_lin, results_nonlin, params, alpha_values, true)
