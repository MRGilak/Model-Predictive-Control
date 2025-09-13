function plot_simulation_results(results_lin, results_nonlin, params, disturbanceShow)
    
    % Outputs and inputs
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



    % States
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

end
