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

x0 = [0.5; 0];
u0 = 0.1001;

beta = 0.1;
Ni = 5;
TOL = 1e-4;

%% Reference signal
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

% --- Unconstrained case
u_min_uncon = -inf;
u_max_uncon = inf;
results_uncon = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
    noise_power, dist_amp, dist_time, dist_duration, ...
    u_min_uncon, u_max_uncon, x0, u0, Ref, beta, Ni, TOL);

% --- Constrained case
u_min_con = -2.7;
u_max_con = 1;
results_con = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
    noise_power, dist_amp, dist_time, dist_duration, ...
    u_min_con, u_max_con, x0, u0, Ref, beta, Ni, TOL);

%% Plot comparison
labels = {'Unconstrained', 'Constrained'};
results_list = {results_uncon, results_con};
plot_comparison_results(results_list, labels, Ref, u_min_con, u_max_con, dist_time, dist_amp, tf, 'compare_unconstrained_vs_constrained');
