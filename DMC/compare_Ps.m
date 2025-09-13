clear; close all; clc;

%% Set parameters
params = get_base_params();
P_values = [11, 22, 44];

%% Simulate
for i = 1:length(P_values)
    params = get_base_params();
    params.P = P_values(i);
    params.Q = ones(params.P, 1);

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results(results_lin, results_nonlin, params, P_values, 'P', true)
