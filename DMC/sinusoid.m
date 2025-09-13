clear; close all; clc;

%% Define parameters
params = struct();
params.tf = 150;
params.Ts = 0.2;
params.N = params.tf / params.Ts;
params.u0_nonlinear = -0.897;
params.u0_linear = -1.7863;

%% Define input
omega = 0.02;
bias = -1;
amplitude = 0.9;

params.Ref = bias * ones(params.N, 1) + amplitude * sin(2 * pi * omega * (0:params.N-1)' * params.Ts);

%% Define parameters
params.P = 11;
params.M = 8;
params.alpha = 0.5;
params.Q = 1 * ones(params.P, 1);
params.R = 0.3107 * ones(params.M, 1);
params.N_model = 55;
params.disturbance_amp = 0;
params.noise_power = -200000;
params.disturbance_start_time = 50;
params.x0 = [-1; 0];
params.is_programmed = true;
params.is_open_loop = false;

%% Run simulations
[results_lin, sr_lin] = simulate_linear_system(params);
[results_nonlin, ~] = simulate_nonlinear_system(params);

Hankel = results_lin.F;
Toeplitz = results_lin.G;
gainMatrix = results_lin.gainMatrix;
sr_all = results_lin.sr_all;

%% Plot results
plot_simulation_results(results_lin, results_nonlin, params, false);
% plot_step_response(params, sr_all);
% plot_static_gain(-1);





