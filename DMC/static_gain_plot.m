% Plot Static Gain
y = linspace(-2, 5, 2000);
u = y .* 0.33 .* exp(-y);

plot(u, y, 'b-', 'LineWidth', 2);
xlabel('u');
ylabel('y');
title('Plot of $u = 0.33 y e^{-y} $', 'Interpreter', 'latex');
grid on;
