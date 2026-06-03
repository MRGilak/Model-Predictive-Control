function plot_simulation_results(varargin)
    if nargin >= 4 && isstruct(varargin{1}) && isstruct(varargin{2})
        results_lin = varargin{1};
        results_nonlin = varargin{2};
        params = varargin{3};
        disturbanceShow = varargin{4};

        figure;
        plot(results_lin.time, results_lin.Y, 'b-', ...
             results_nonlin.time, results_nonlin.Y, 'r-', ...
             results_lin.time, params.Ref, 'k-', ...
             results_lin.time, results_lin.Ref_filtered, 'k--.', 'LineWidth', 1.5);
        if disturbanceShow
            xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
        end
        title('Output (Linear & Nonlinear)');
        xlabel('Time (s)'); ylabel('Output');
        legend('Linear', 'Nonlinear', 'Ref', 'Filtered Ref'); grid on;
        xlim([0, params.N * params.Ts]);
        ylim([-2.1, 0.36]);

        figure;
        subplot(2, 1, 1);
        stairs(results_lin.time, results_lin.U, 'b-', 'LineWidth', 1.5); hold on;
        stairs(results_nonlin.time, results_nonlin.U, 'r-', 'LineWidth', 1.5);
        if disturbanceShow
            xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
        end
        title('Control Input');
        xlabel('Time (s)'); ylabel('u'); grid on;
        legend('Linear', 'Nonlinear');
        xlim([0, params.N * params.Ts]);

        subplot(2, 1, 2);
        stairs(results_lin.time, results_lin.DU, 'b-', 'LineWidth', 1.2); hold on;
        stairs(results_nonlin.time, results_nonlin.DU, 'r-', 'LineWidth', 1.2);
        if disturbanceShow
            xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
        end
        title('$\Delta u$', 'Interpreter', 'latex');
        xlabel('Time (s)'); ylabel('\Delta u'); grid on;
        legend('$\Delta u_{lin}$', '$\Delta u_{nonlin}$', 'interpreter', 'latex');
        xlim([0, params.N * params.Ts]);

        figure;
        subplot(2, 1, 1);
        plot(results_lin.time, results_lin.X(:, 1), 'b-', ...
             results_nonlin.time, results_nonlin.X(:, 1), 'r-', 'LineWidth', 1.5);
        if disturbanceShow
            xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
        end
        title('State 1 (Linear & Nonlinear)');
        xlabel('Time (s)'); ylabel('State 1');
        legend('Linear', 'Nonlinear'); grid on;
        xlim([0, params.N * params.Ts]);

        subplot(2, 1, 2);
        plot(results_lin.time, results_lin.X(:, 2), 'b-', ...
             results_nonlin.time, results_nonlin.X(:, 2), 'r-', 'LineWidth', 1.5);
        if disturbanceShow
            xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
        end
        title('State 2 (Linear & Nonlinear)');
        xlabel('Time (s)'); ylabel('State 2');
        legend('Linear', 'Nonlinear'); grid on;
        xlim([0, params.N * params.Ts]);
        return;
    end

    if nargin < 12
        error('plot_simulation_results:NotEnoughInputs', 'Expected either DMC result structs or EPFC vectors.');
    end

    time = varargin{1};
    Y = varargin{2};
    Ref = varargin{3};
    U = varargin{4};
    V = varargin{5};
    DU = varargin{6};
    X = varargin{7};
    u_min = varargin{8};
    u_max = varargin{9};
    dist_time = varargin{10};
    dist_amp = varargin{11};
    tf = varargin{12};
    if nargin >= 13
        save_prefix = varargin{13};
    else
        save_prefix = '';
    end

    set(0, 'DefaultAxesFontSize', 12);
    set(0, 'DefaultTextFontSize', 14);

    if ~isempty(save_prefix)
        base_dir = fullfile(getenv('USERPROFILE'), 'Downloads', 'simulation_results');
        full_dir = fullfile(base_dir, save_prefix);
        if ~exist(full_dir, 'dir')
            mkdir(full_dir);
        end
    end

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
