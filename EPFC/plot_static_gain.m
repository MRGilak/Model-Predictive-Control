% Plot Static Gain
y = linspace(-3, 3, 20000);
u = y .* 0.33 .* exp(-y) ;
v = y .* 0.33 .* exp(-y) + y;

figure();
plot(u, y, 'b-', 'LineWidth', 2);
xlabel('u');
ylabel('y');
title('Static Gain Plot without Change of Variables');
grid on;

figure();
plot(v, y, 'r-', 'LineWidth', 2);
xlabel('v');
ylabel('y');
title('Static Gain Plot with Change of Variables');
grid on;
