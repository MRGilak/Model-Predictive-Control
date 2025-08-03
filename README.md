# Model-Predictive-Control
This repo includes the MATLAB codes for a DMC and an EPFC controller.

## DMC


## EPFC
An extended PFC controller is implemented to control a nonlinear system. The exemplar system considered is a cart with a spring attached to it, as shown in [[images/cart-with-spring.jpg|this image]]. The system state space representation is as follows:
$$
\dot{x}_1 = x_2
\dot{x}_2 = -0.33 e^{- x_1} x_1 - 1.1 x_2 + u
y = x_1
$$
Any other system can be used instead. It's simply a matter of system definition in one function, which will be shown later.
A change of variables is considered as
$$
v = u + x_1
$$
This change of variables allows the new system to have a one-to-one relationship between $v$ and $y$. If a system does not need a change of variables, line 162 of run_simulation can simply be changed to
```
u = v;
```

a