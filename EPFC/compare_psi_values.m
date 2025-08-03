clear; close all; clc;

%% Common parameters
Ts = 0.2;
tf = 80;
N_model = 50;
mu = [2, 4, 6];
m = [0];
q = 1 * ones(1, length(mu));
r = 0.1 * ones(1, length(m));

noise_power = -40;
dist_amp = 5;
dist_time = 57;
dist_duration = 1;

u_min = -inf;
u_max = inf;

x0 = [0.5; 0];
u0 = 0.1001;

beta = 0.1;
Ni = 5;
TOL = 1e-3;

% Reference signal (same as before)
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

% Linearization method and programmed ref flag
method = 'perturbation';
is_programmed_ref = false;

%% Define different psi sets (same length as mu)
psi_sets = {
    0.1 * ones(1, length(mu)),  ...   % Mostly reference-driven
    0.4 * ones(1, length(mu)),  ...   % Balanced blending
    0.8 * ones(1, length(mu))           % Mostly output-driven (feedback)
};
labels = {'ψ = 0.1', 'ψ = 0.4', 'ψ = 0.8'};

%% Run simulations for each psi set
results_list = cell(1, numel(psi_sets));
for i = 1:numel(psi_sets)
    psi = psi_sets{i};
    results_list{i} = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
                                    noise_power, dist_amp, dist_time, dist_duration, ...
                                    u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref);
end

%% Plot comparison
save_prefix = 'compare_psi_scenarios';
plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, save_prefix);
