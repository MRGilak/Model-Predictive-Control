function plot_comparison_results_for_Q(results_lin, results_nonlin, params, values, name, disturbanceShow)

    colors = {'b', 'r', 'g'};  

    %% ----------- LINEAR SYSTEM PLOTS -----------
    figure;

    % Output
    subplot(2, 1, 1); hold on;
    plot(results_lin{1}.time, params.Ref, 'k-', 'LineWidth', 1.5);
    plot(results_lin{1}.time, results_lin{1}.Ref_filtered, 'k--.', 'LineWidth', 1.5);
    
    plot(results_lin{1}.time, results_lin{1}.Y, 'Color', colors{1}, 'LineWidth', 1.5);
    plot(results_lin{2}.time, results_lin{2}.Y, 'Color', colors{2}, 'LineWidth', 1.5);
    plot(results_lin{3}.time, results_lin{3}.Y, 'Color', colors{3}, 'LineWidth', 1.5);

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Output (Linear)');
    xlabel('Time (s)'); ylabel('Output');
    legend({'Ref', 'Filtered Ref', ...
            'Q = I', 'Q = 10I', 'Q = decreasing'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    % Input
    subplot(2, 1, 2); hold on;
    plot(results_lin{1}.time, results_lin{1}.U, 'Color', colors{1}, 'LineWidth', 1.5);
    plot(results_lin{2}.time, results_lin{2}.U, 'Color', colors{2}, 'LineWidth', 1.5);
    plot(results_lin{3}.time, results_lin{3}.U, 'Color', colors{3}, 'LineWidth', 1.5);

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Control Input (Linear)');
    xlabel('Time (s)'); ylabel('Input');
    legend({'Q = I', 'Q = 10I', 'Q = decreasing'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);


    %% ----------- NONLINEAR SYSTEM PLOTS -----------
    figure;

    % Output
    subplot(2, 1, 1); hold on;
    plot(results_nonlin{1}.time, params.Ref, 'k-', 'LineWidth', 1.5);
    plot(results_nonlin{1}.time, results_nonlin{1}.Ref_filtered, 'k--.', 'LineWidth', 1.5);
    
    plot(results_nonlin{1}.time, results_nonlin{1}.Y, 'Color', colors{1}, 'LineWidth', 1.5);
    plot(results_nonlin{2}.time, results_nonlin{2}.Y, 'Color', colors{2}, 'LineWidth', 1.5);
    plot(results_nonlin{3}.time, results_nonlin{3}.Y, 'Color', colors{3}, 'LineWidth', 1.5);

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Output (Nonlinear)');
    xlabel('Time (s)'); ylabel('Output');
    legend({'Ref', 'Filtered Ref', ...
            'Q = I', 'Q = 10I', 'Q = decreasing'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    % Input
    subplot(2, 1, 2); hold on;
    plot(results_nonlin{1}.time, results_nonlin{1}.U, 'Color', colors{1}, 'LineWidth', 1.5);
    plot(results_nonlin{2}.time, results_nonlin{2}.U, 'Color', colors{2}, 'LineWidth', 1.5);
    plot(results_nonlin{3}.time, results_nonlin{3}.U, 'Color', colors{3}, 'LineWidth', 1.5);

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Control Input (Nonlinear)');
    xlabel('Time (s)'); ylabel('Input');
    legend({'Q = I', 'Q = 10I', 'Q = decreasing'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
end
