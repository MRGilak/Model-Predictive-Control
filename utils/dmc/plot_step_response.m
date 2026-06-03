function plot_step_response(params, sr)
    % Step Response Coefficients
    figure;
    stem((0:length(sr)-1), sr, 'b', 'filled', 'LineWidth', 1.5);
    title('System Step Response Coefficients');
    xlabel('Sample');
    ylabel('Step Response');
    grid on;
    xlim([0, params.N_model]);
end