function plot_static_gain(y0)
    % Define the nonlinear curve
    y = linspace(-2, 5, 2000);
    u = 0.33 * y .* exp(-y);

    % Plot the curve
    plot(u, y, 'b-', 'LineWidth', 2);
    xlabel('u');
    ylabel('y');
    title('System Static Gain Plot');
    grid on;
    hold on;

    % Evaluate nonlinear function at y0
    u0 = 0.33 * y0 * exp(-y0);

    % Compute derivative du/dy at y0
    du_dy = 0.33 * exp(-y0) * (1 - y0);

    % Plot short tangent line at (u0, y0)
    dy = 0.4;  % Length of tangent in y-direction
    y_tangent = linspace(y0 - dy, y0 + dy, 10);
    u_tangent = u0 + du_dy * (y_tangent - y0);

    plot(u_tangent, y_tangent, 'k-', 'LineWidth', 2);
    plot(u0, y0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6); 
    text(u0 + 0.2, y0, 'linearization point', 'FontSize', 10, 'Color', 'k');

    hold off;
end
