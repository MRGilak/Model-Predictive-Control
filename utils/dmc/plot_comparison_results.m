function plot_comparison_results(results_lin, results_nonlin, params, values, name, disturbanceShow)
    
    % Linear Outputs and inputs
    figure;
    subplot(2, 1, 1);
    hold on;
    plot(results_lin{1}.time, params.Ref, 'k-', ...
         results_lin{1}.time, results_lin{1}.Ref_filtered, 'k--.', 'LineWidth', 1.5);

    for i = 1:length(values)
        plot(results_lin{i}.time, results_lin{i}.Y, params.colors{i}, 'LineWidth', 1.5);
    end

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Output (Linear)');
    xlabel('Time (s)'); ylabel('Output');

    % Legends
    legend_entries = {'Ref', 'Filtered Ref'};
    for i = 1:length(values)
        legend_entries{end + 1} = sprintf('%s = %g', name, values(i));
    end
    legend(legend_entries, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    subplot(2, 1, 2);
    hold on;

    for i = 1:length(values)
        plot(results_lin{i}.time, results_lin{i}.U, params.colors{i}, 'LineWidth', 1.5);
    end

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Control Input (Linear)');
    xlabel('Time (s)'); ylabel('Input');

    % Legends
    legend_entries = {};
    for i = 1:length(values)
        legend_entries{end + 1} = sprintf('%s = %g', name, values(i));
    end
    legend(legend_entries, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);




    % Noninear Outputs and inputs
    figure;
    subplot(2, 1, 1);
    hold on;
    plot(results_nonlin{1}.time, params.Ref, 'k-', ...
         results_nonlin{1}.time, results_nonlin{1}.Ref_filtered, 'k--.', 'LineWidth', 1.5);

    for i = 1:length(values)
        plot(results_nonlin{i}.time, results_nonlin{i}.Y, params.colors{i}, 'LineWidth', 1.5);
    end

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Output (Nonlinear)');
    xlabel('Time (s)'); ylabel('Output');

    % Legends
    legend_entries = {'Ref', 'Filtered Ref'};
    for i = 1:length(values)
        legend_entries{end + 1} = sprintf('%s = %g', name, values(i));
    end
    legend(legend_entries, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    subplot(2, 1, 2);
    hold on;

    for i = 1:length(values)
        plot(results_nonlin{i}.time, results_nonlin{i}.U, params.colors{i}, 'LineWidth', 1.5);
    end

    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end

    title('Control Input (Noninear)');
    xlabel('Time (s)'); ylabel('Input');

    % Legends
    legend_entries = {};
    for i = 1:length(values)
        legend_entries{end + 1} = sprintf('%s = %g', name, values(i));
    end
    legend(legend_entries, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);

end

