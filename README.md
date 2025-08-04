# Model-Predictive-Control
This repo includes the MATLAB codes for a DMC and an EPFC controller.

## DMC
<!-- Add content here -->

## EPFC
An extended PFC controller is implemented to control a nonlinear system. The exemplar system considered is a cart with a spring attached to it.

The system state space representation is as follows:
```
x1_dot = x2
x2_dot = -0.33 * exp(-x1) * x1 - 1.1 * x2 + u
y = x1
```

Any other system can be used instead. It's simply a matter of system definition in one function, which will be shown later.
A change of variables is considered as:
```
v = u + x1
```

This change of variables allows the new system to have a one-to-one relationship between `v` and `y`. If a system does not need a change of variables, line 162 of `run_simulation` can simply be changed to:
```matlab
u = v;
```


