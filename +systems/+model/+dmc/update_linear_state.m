function x_next = update_linear_state(sys_d, x, u)
    x_next = sys_d.A * x + sys_d.B * u;
end
