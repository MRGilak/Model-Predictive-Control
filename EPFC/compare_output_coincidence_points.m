clear; clc; close all;

%% Common parameters
Ts = 0.2;
tf = 73;
N_model = 50;
m = [0];
q = 1 * ones(1, 3);
r = 0.1;
psi = 0.3 * ones(1, 3);

noise_power = -inf;
dist_amp = 0;
dist_time = 50;
dist_duration = 1;
u_min = -inf;
u_max = inf;
x0 = [0.5; 0];
u0 = 0.1001;

beta = 0.1;
Ni = 5;
TOL = 1e-3;

% Reference signal (same as in your main script)
span = 1;
bias = 0.5;
levels = bias * ones(1, 10) + span * [0, 0.6, 1.8, -0.3, -1.5, -0.6, 0, 2.4, -2.1, 0];
spans = 1 * [7, 7, 7, 7, 7, 7, 7, 7, 9, 7];
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

%% Define different mu sets (3 coincidence points each)
mu_sets = {
    [2, 4, 10], ...           % Spread
    [1, 2, 3], ...            % Clustered near start
    [20, 30, 40]              % Clustered near end
};
labels = {'Spread \mu', 'Start Cluster \mu', 'End Cluster \mu'};

%% Run simulations for each mu set
results_list = cell(1, numel(mu_sets));
for i = 1:numel(mu_sets)
    mu = mu_sets{i};
    results_list{i} = run_simulation(method, Ts, tf, N_model, mu, m, q, r, psi, ...
                                    noise_power, dist_amp, dist_time, dist_duration, ...
                                    u_min, u_max, x0, u0, Ref, beta, Ni, TOL, is_programmed_ref);
end

%% Plot comparison
save_prefix = 'compare_mu_scenarios';
plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, save_prefix);
