function params = get_base_params()
    params = struct();
    params.tf = 85;
    params.Ts = 0.2;
    params.N = params.tf / params.Ts;
    params.u0_nonlinear = -0.897;
    params.u0_linear = -1.7863;

    params.colors = {'b', 'r', 'g', 'm', 'c', 'k'};  
    
    bias = -1;
    span = 0.4;
    
    % Define input
    levels = bias * ones(1, 10) + span * [0, 0.6, 1.8, -0.3, -1.5, -0.6, 0, 2.4, -2.1, 0];
    spans = 1 * [5, 5, 7, 7, 7, 7, 6, 20, 12, 8];
    
    span_steps = round(spans ./ params.Ts);
    ref_signal = [];
    for i = 1:length(levels)
        ref_signal = [ref_signal; repmat(levels(i), span_steps(i), 1)];
    end
    params.Ref = [ref_signal; repmat(levels(end), max(0, params.N - length(ref_signal)), 1)];
    
    % Define parameters
    params.P = 11;
    params.M = 8;
    params.alpha = 0.5;
    params.Q = 1 * ones(params.P, 1);
    params.R = 0.3107 * ones(params.M, 1);
    params.N_model = 55;
    params.disturbance_amp = 0.2;
    params.noise_power = -40;
    params.disturbance_start_time = 55;
    params.x0 = [-1; 0];
    params.is_programmed = true;
    params.is_open_loop = false;
end
