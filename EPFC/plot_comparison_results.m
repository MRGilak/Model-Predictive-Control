function plot_comparison_results(results_list, labels, Ref, u_min, u_max, dist_time, dist_amp, tf, save_prefix)
    if nargin < 9
        save_prefix = '';
    end

    num_experiments = numel(results_list);
    colors = lines(num_experiments);

    set(0, 'DefaultAxesFontSize', 12);
    set(0, 'DefaultTextFontSize', 14);

    %% Create save directory
    if ~isempty(save_prefix)
        base_dir = fullfile(getenv('USERPROFILE'), 'Downloads', 'simulation_results');
        full_dir = fullfile(base_dir, save_prefix);
        if ~exist(full_dir, 'dir')
            mkdir(full_dir);
        end
    end

    %% Plot 1: Output and Control Input
    fig1 = figure;
    subplot(2,1,1); hold on;
    for i = 1:num_experiments
        plot(results_list{i}.time, results_list{i}.Y, 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    plot(results_list{1}.time, Ref, 'k', 'LineWidth', 1);
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('y'); title('System Output Comparison');
    legend([labels(:); "Reference"]); grid on;
    xlim([0, tf-0.2]); ylim([-3, 4]);

    subplot(2,1,2); hold on;
    for i = 1:num_experiments
        stairs(results_list{i}.time, results_list{i}.U, 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    if isfinite(u_max), yline(u_max, 'k--'); end
    if isfinite(u_min), yline(u_min, 'k--'); end
    ylabel('u'); xlabel('Time [s]');
    title('Actual Control Input Comparison');
    legend([labels(:); "u_{max}"; "u_{min}"]); grid on;
    xlim([0, tf-0.2]); ylim([-7, 7]);

    if ~isempty(save_prefix)
        saveas(fig1, fullfile(full_dir, 'comparison_output_input.fig'));
    end

    %% Plot 2: Virtual Control and Δu
    fig2 = figure;
    subplot(2,1,1); hold on;
    for i = 1:num_experiments
        stairs(results_list{i}.time, results_list{i}.V, 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('v'); title('Virtual Control Input Comparison');
    legend(labels); grid on; xlim([0, tf-0.2]);

    subplot(2,1,2); hold on;
    for i = 1:num_experiments
        stairs(results_list{i}.time, results_list{i}.DU, 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('\Delta u'); xlabel('Time [s]');
    title('Control Input Increment Comparison');
    legend(labels); grid on; xlim([0, tf-0.2]);

    if ~isempty(save_prefix)
        saveas(fig2, fullfile(full_dir, 'comparison_virtual_du.fig'));
    end

    %% Plot 3: States
    fig3 = figure;
    subplot(2,1,1); hold on;
    for i = 1:num_experiments
        plot(results_list{i}.time, results_list{i}.X(:,1), 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    plot(results_list{1}.time, Ref, 'k', 'LineWidth', 1);
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('x_1'); title('State x_1 Comparison');
    legend([labels(:); "Reference"]); grid on;
    xlim([0, tf-0.2]);

    subplot(2,1,2); hold on;
    for i = 1:num_experiments
        plot(results_list{i}.time, results_list{i}.X(:,2), 'Color', colors(i,:), 'LineWidth', 1.5);
    end
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('x_2'); xlabel('Time [s]');
    title('State x_2 Comparison'); grid on; xlim([0, tf-0.2]);

    if ~isempty(save_prefix)
        saveas(fig3, fullfile(full_dir, 'comparison_states.fig'));
    end
end
