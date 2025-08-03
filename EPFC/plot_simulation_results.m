function plot_simulation_results(time, Y, Ref, U, V, DU, X, u_min, u_max, dist_time, dist_amp, tf, save_prefix)
    % Backward-compatible: if no save_prefix is given, skip saving
    if nargin < 13
        save_prefix = '';
    end

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

    %% Plot 1: Output and Actual Control (u)
    fig1 = figure;
    subplot(2,1,1);
    plot(time, Y, 'b', 'LineWidth', 1.5); hold on;
    plot(time, Ref, 'k', 'LineWidth', 1);
    if dist_amp ~= 0
        xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1);
    end
    ylabel('y'); title('System Output and Reference');
    legend('y', 'Reference'); grid on;
    xlim([0, tf-0.2]); ylim([-3, 4]);

    subplot(2,1,2);
    stairs(time, U, 'm', 'LineWidth', 1.5); hold on;
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    if isfinite(u_max), yline(u_max, 'k--'); end
    if isfinite(u_min), yline(u_min, 'k--'); end
    ylabel('u'); xlabel('Time [s]');
    title('Actual Control Input');
    legend('u', 'u_{max}', 'u_{min}'); grid on;
    xlim([0, tf-0.2]); ylim([-7, 7]);

    if ~isempty(save_prefix)
        saveas(fig1, fullfile(full_dir, 'output_input.fig'));
    end

    %% Plot 2: Virtual Control and du
    fig2 = figure;
    subplot(2,1,1);
    stairs(time, V, 'b', 'LineWidth', 1.5); hold on;
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('v'); title('Virtual Control Input'); grid on;
    xlim([0, tf-0.2]); ylim([-9, 9]);

    subplot(2,1,2);
    stairs(time, DU, 'm', 'LineWidth', 1.5); hold on;
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('\Delta u'); xlabel('Time [s]');
    title('Control Input Increment'); grid on;
    xlim([0, tf-0.2]);

    if ~isempty(save_prefix)
        saveas(fig2, fullfile(full_dir, 'virtual_du.fig'));
    end

    %% Plot 3: States x1 and x2
    fig3 = figure;
    subplot(2,1,1);
    plot(time, X(:,1), 'b', 'LineWidth', 1.5); hold on;
    plot(time, Ref, 'k', 'LineWidth', 1);
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('x_1'); title('State x_1 and Reference');
    legend('x_1', 'Reference'); grid on;
    xlim([0, tf-0.2]);

    subplot(2,1,2);
    plot(time, X(:,2), 'm', 'LineWidth', 1.5); hold on;
    if dist_amp ~= 0, xline(dist_time, 'k--', 'Label', 'Dist Start', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1); end
    ylabel('x_2'); xlabel('Time [s]');
    title('State x_2'); grid on;
    xlim([0, tf-0.2]);

    if ~isempty(save_prefix)
        saveas(fig3, fullfile(full_dir, 'states.fig'));
    end
end
