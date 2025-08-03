% Plot Static Gain
y = linspace(-3, 3, 20000);
u = y .* 0.33 .* exp(-y) ;
v = y .* 0.33 .* exp(-y) + y;

plot(v, y, 'b-', 'LineWidth', 2);
xlabel('v');
ylabel('y');
title('Static Gain Plot');
grid on;
