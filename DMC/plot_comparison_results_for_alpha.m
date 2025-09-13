function plot_comparison_results_for_alpha(results_lin, results_nonlin, params, alphas, disturbanceShow)

    % Use fixed colors for each alpha
    colors = {'b', 'r', 'g'};  % For alpha = 0.1, 0.5, 0.9

    %% --------- LINEAR SYSTEM PLOTS ---------
    figure;

    % Output
    subplot(2,1,1); hold on;
    plot(results_lin{1}.time, params.Ref, 'k-', 'LineWidth', 1.5);  % Same Ref for all
    for i = 1:length(alphas)
        plot(results_lin{i}.time, results_lin{i}.Ref_filtered, [colors{i} '--'], 'LineWidth', 1.2);
        plot(results_lin{i}.time, results_lin{i}.Y, colors{i}, 'LineWidth', 1.5);
    end
    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end
    title('Output (Linear)');
    xlabel('Time (s)'); ylabel('Output');
    legend({'Ref', ...
            '\alpha = 0.1 filtered', '\alpha = 0.1 Y', ...
            '\alpha = 0.5 filtered', '\alpha = 0.5 Y', ...
            '\alpha = 0.9 filtered', '\alpha = 0.9 Y'}, ...
           'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    % Input
    subplot(2,1,2); hold on;
    for i = 1:length(alphas)
        plot(results_lin{i}.time, results_lin{i}.U, colors{i}, 'LineWidth', 1.5);
    end
    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end
    title('Control Input (Linear)');
    xlabel('Time (s)'); ylabel('Input');
    legend({'\alpha = 0.1', '\alpha = 0.5', '\alpha = 0.9'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);

    %% --------- NONLINEAR SYSTEM PLOTS ---------
    figure;

    % Output
    subplot(2,1,1); hold on;
    plot(results_nonlin{1}.time, params.Ref, 'k-', 'LineWidth', 1.5);
    for i = 1:length(alphas)
        plot(results_nonlin{i}.time, results_nonlin{i}.Ref_filtered, [colors{i} '--'], 'LineWidth', 1.2);
        plot(results_nonlin{i}.time, results_nonlin{i}.Y, colors{i}, 'LineWidth', 1.5);
    end
    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end
    title('Output (Nonlinear)');
    xlabel('Time (s)'); ylabel('Output');
    legend({'Ref', ...
            '\alpha = 0.1 filtered', '\alpha = 0.1 Y', ...
            '\alpha = 0.5 filtered', '\alpha = 0.5 Y', ...
            '\alpha = 0.9 filtered', '\alpha = 0.9 Y'}, ...
           'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);
    ylim([-2.1, 0.2]);

    % Input
    subplot(2,1,2); hold on;
    for i = 1:length(alphas)
        plot(results_nonlin{i}.time, results_nonlin{i}.U, colors{i}, 'LineWidth', 1.5);
    end
    if disturbanceShow
        xline(params.disturbance_start_time, 'k--', 'Dist Start', 'LabelVerticalAlignment', 'bottom');
    end
    title('Control Input (Nonlinear)');
    xlabel('Time (s)'); ylabel('Input');
    legend({'\alpha = 0.1', '\alpha = 0.5', '\alpha = 0.9'}, 'Location', 'best');
    grid on;
    xlim([0, params.N * params.Ts]);

end
