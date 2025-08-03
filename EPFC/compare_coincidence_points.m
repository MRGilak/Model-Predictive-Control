clear; close all; clc;

%% Parameters
Ts = 0.2;
tf = 70;
N_model = 100;

q = 1;
r = 0.1;
psi = 0.3;

noise_power = -inf;
dist_amp = 0;
dist_time = 53;
dist_duration = 1;

u_min = -inf;
u_max = inf;

x0 = [0; 0];
u0 = 0;

beta = 0.1;
Ni = 5;
TOL = 1e-3;

%% Reference signal
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

%% Define 3 mu/m configurations
mu_set = {
    [5], ...                % 1 output point
    [4, 6, 10], ...         % 3 output points
    [4, 7, 10]              % 3 output points
};

m_set = {
    [0], ...                % 1 input change point
    [0, 5, 8], ...          % 3 input change points, between mu's
    [0]                     % 2 input change points, underactuated
};

labels = {
    '1 output / 1 input',
    '3 output / 3 input',
    '3 output / 1 input'
};

%% Run simulations
results_list = cell(1, 3);

for i = 1:3
    mu = mu_set{i};
    m = m_set{i};
    q_vec = q * ones(1, length(mu));
    r_vec = r * ones(1, length(m));
    psi_vec = psi * ones(1, length(mu));
    
    results_list{i} = run_simulation('jacobian', Ts, tf, N_model, mu, m, q_vec, r_vec, psi_vec, ...
                                     noise_power, dist_amp, dist_time, dist_duration, ...
                                     u_min, u_max, x0, u0, Ref, beta, Ni, TOL);
end

%% Plot comparison
plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, 'compare_coincidence_points');
