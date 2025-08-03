clear; close all; clc;

%% Parameters
Ts = 0.2;
tf = 80;
N_model = 21;

mu = [4, 7, 10];
m = [0];
q = 1 * ones(1, length(mu));
r = 0.1 * ones(1, length(m));
psi = 0.3 * ones(1, length(mu));

noise_power = -40;
dist_amp = 5;
dist_time = 57;
dist_duration = 1;
u_min = -inf;
u_max = inf;

x0 = [0.5; 0];
u0 = 0.1001;

% Iterative correction parameters
beta = 0.1;
Ni = 5;
TOL = 1e-3;

%% Reference signal (piecewise constant levels)
span = 1;
bias = 0.5;
levels = bias * ones(1, 10) + span * [0, 0.6, 1.8, -0.3, -1.5, -0.6, 0, 2.4, -2.1, 0];
spans = 1 * [7, 7, 7, 7, 7, 7, 7, 15, 9, 7];
span_steps = round(spans ./ Ts);

ref_signal = [];
for i = 1:length(levels)
    ref_signal = [ref_signal; repmat(levels(i), span_steps(i), 1)];
end

N = tf / Ts;
Ref = [ref_signal; repmat(levels(end), max(0, N - length(ref_signal)), 1)];
Ref = Ref(1:N);

%% Run simulations
method = 'perturbation';

% --- Unprogrammed reference tracking
is_programmed_ref = false;
results_unprog = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
    noise_power, dist_amp, dist_time, dist_duration, ...
    u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref);

% --- Programmed reference tracking
is_programmed_ref = true;
results_prog = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
    noise_power, dist_amp, dist_time, dist_duration, ...
    u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref);

%% Plot comparison
labels = {'Unprogrammed', 'Programmed'};
results_list = {results_unprog, results_prog};
plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, 'compare_programmed_vs_unprogrammed');
