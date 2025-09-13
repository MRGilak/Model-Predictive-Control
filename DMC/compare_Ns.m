clear; close all; clc;

%% Set parameters
params = get_base_params();
N_values = [15, 55, 300];

%% Simulate
for i = 1:length(N_values)
    params = get_base_params();
    params.N_model = N_values(i);

    % Simulate
    [results_lin{i}, sr_lin] = simulate_linear_system(params);
    [results_nonlin{i}, ~] = simulate_nonlinear_system(params);
end

%% Plot results

plot_comparison_results(results_lin, results_nonlin, params, N_values, 'N', true)
