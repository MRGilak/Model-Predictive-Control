clear; close all; clc;

%% Parameters
Ts = 0.2;
tf = 80;
N_model = 100;

mu = [4, 7, 10];
m = [0];
q = 1 * ones(1, length(mu));
r = 0.1 * ones(1, length(m));
psi = 0.3 * ones(1, length(mu));

noise_power = -40;
dist_amp = 5;
dist_time = 50;
dist_duration = 1;
u_min = -inf;
u_max = inf;

x0 = [0; 0];
u0 = 0;

% iterative procedure variables
beta = 0.1;        % Relaxation factor
Ni = 5;            % Max iteration count
TOL = 1e-3;        % Tolerance

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

%% Run simulations with both methods
results_jacobian = run_simulation('jacobian', Ts, tf, N_model, mu, m, q, r, psi, ...
                                  noise_power, dist_amp, dist_time, dist_duration, ...
                                  u_min, u_max, x0, u0, Ref, beta, Ni, TOL);

results_perturb = run_simulation('perturbation', Ts, tf, N_model, mu, m, q, r, psi, ...
                                  noise_power, dist_amp, dist_time, dist_duration, ...
                                  u_min, u_max, x0, u0, Ref, beta, Ni, TOL);

%% Plot and Compare

% Comparison Plot
results_list = {results_jacobian, results_perturb};
labels = {'Jacobian', 'Perturbation'};

plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, 'compare_linearization_method');
