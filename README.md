# Model-Predictive-Control
This repo includes the MATLAB codes for a DMC and an EPFC controller.

## DMC
A DMC controller is implemented to control a linear system. The linear system is actually the linearized version of a nonlinear system, which as an example is considered to be a cart with a nonlinear spring, as that used for the EPFC controller in [here](#epfc). 
A very simple explanation of DMC is included in [this file](docs/DMC.pdf).

The functions and scripts are as follows:
### DMC functions
- [simulate_linear_system](DMC/simulate_linear_system.m) and [simulate_nonlinear_system(DMC/simulate_nonlinear_system) simulate the systems by running the whole simulation, calling the MPC controller at each timestep to get the control input, applying the control input to the systems and moving the dynamics forward.
- [dmc_linear](DMC/dmc_linear.m) determines the control input for the linear system using the DMC logic
- [dmc_nonlinear](DMC/dmc_nonlinear.m) is the same as [dmc_linear](DMC/dmc_linear.m) with the difference that it moves the nonlinear system's dynamics forward to calculate `Ypast`.
- [update_linear_state](DMC/update_linear_state.m) moves the linear system's dynamics forward one step. You can insert your linear system dynamics here.
- [update_nonlinear_state](DMC/update_nonlinear_state.m) moves the nonlinear system's dynamics forward one step. You can insert your nonlinear system dynamics here.
A considerably smaller step size (compared to control sample time) should be considered when simulating the nonlinear system itself. The `substeps` parameter can be tuned for that (keep it at least at 10 for a realistic simulation).
- [plot_simulation_results](DMC/plot_simulation_results.m), [plot_comparison_results](DMC/plot_comparison_results.m), [plot_comparison_results_for_Q](DMC/plot_comparison_results_for_Q.m) and [plot_comparison_results_for_alpha](DMC/plot_comparison_results_for_alpha.m) are used for plotting the results.
- [plot_static_gain](DMC/plot_static_gain.m) is used for analyzing the nonlinear system's static gain at a given point 

### DMC scripts

- [plot_step_response](DMC/plot_step_response.m) is used to analyzing the linearized system's step response to obtain a reliable model horizon N
- [general](DMC/general.m) runs the simulation with the set parameters and saves the results. Parameters include:
    - `Ts` sampling time
    - `tf` final simulation time
    - `N` model horizon
    - `u0_nonlinear` the nonlinear system's operating point control input
    - `u0_linear` initial value of the linearized system's control input 
    - `bias` and `span` used for generating the reference signal
    - `P` prediction horizon
    - `M` control horizon
    - `alpha` filter coefficient for filtering the desired reference
    - `Q` weight of each future output sample (set not as a matrix, but as a vector. This will be later used to construct a diagonal Q)
    - `R` weight of each future input sample (set not as a matrix, but as a vector. This will be later used to construct a diagonal Q)
    - `N_model` not actually used. Set it equal to `N`
    - `x0` initial condition of the system
    - `is_programmed` if set to true, the reference will be considered programmed, meaning that the controller is aware of the future values of the reference signal.
    - `is_open_loop` if set to true, the disturbance `D` term will not be 
    - `noise_power` power of white noise on the output (in dB)
    - `dist_amp` the amplitude of disturbance on the output. The disturbance is considered to be a pulse signal.
    - `dist_start_time` the time when the disturbance is applied
- [compare_Ms](DMC/compare_Ms.m) compares different values of M. 
- [compare_Ns](DMC/compare_Ns.m) compares different values of N. 
- [compare_Ps](DMC/compare_Ps.m) compares different values of P. 
- [compare_Qs](DMC/compare_Qs.m) compares different values of Q. 
- [compare_Rs](DMC/compare_Rs.m) compares different values of R.
- [compare_alphas](DMC/compare_alphas.m) compares different values of alpha. 
- [pulse](DMC/pulse0 pulse reference signal
- [sinusoid](DMC/sinusoid.m) sinusoid reference signal


## EPFC
An extended PFC controller is implemented to control a nonlinear system. The exemplar system considered is a cart with a nonlinear spring attached to it, as shown in the image:
<div align="left">
  <img
    width="500"
    height="400"
    alt="cart-with-spring"
    src="https://github.com/user-attachments/assets/05ea10e7-072e-4275-8c02-80a70bdfcb7c"
  />
</div>

The system state space representation is as follows:

$$
    \begin{align}
        \dot{x}_1 = x_2 \\
        \dot{x}_2 = -0.33 e^{-x_1} x_1 - 1.1 x_2 + u
        y = x_1
    \end{align}
$$

Any other system can be used instead. It's simply a matter of system definition in one function, which will be shown later.
A change of variables is considered as:

$$
    v = u + x_1
$$

This change of variables allows the new system to have a one-to-one relationship between `v` and `y`. If a system does not need a change of variables, line 162 of `run_simulation` can simply be changed to:
```matlab
u = v;
```
A very simple explanation of EPFC is included in [this file](docs/EPFC.pdf).

The functions and scripts are as follows:
### EPFC functions
- [run_simulation](EPFC/run_simulation.m) runs the simulation given
linearization method: set to 'perturbation' or 'jacobian'. Jacobian uses the provided Jacobian of the system (which should be provided in [linearize_dynamics](EPFC/linearize_dynamics.m)). The perturbation method uses the predictive model and applies two inputs. One where the input is kept unchanged as it is at this sample time, and one with a small change in the control input value. By dividing the change of the output in the two cases by the change of the input, a linearized model is achieved.
- [linearize_dynamics](EPFC/linearize_dynamics.m) provides the jacobian for the 'jacobian' lineariztion method. You should set this function according to your system's dynamics.
- [get_step_response_nonlinear](EPFC/get_step_response_nonlinear.m) provides the outputs for a given constant input. It is used in 'perturbation' linearization technique.
- [update_nonlinear_state](EPFC/update_nonlinear_state.m) moves the nonlinear system's dynamics forward one step. You can insert your system dynamics here.
A considerably smaller step size (compared to control sample time) should be considered when simulating the nonlinear system itself. The `substeps` parameter can be tuned for that (keep it at least at 10 for a realistic simulation).
- [update_nonlinear_state_actual](EPFC/update_nonlinear_state_actual.m) is used when model mismatch is considered. You can skip setting up this function if your model is exact. If not, use the model at hand in [update_nonlinear_state](EPFC/update_nonlinear_state.m) and in [update_nonlinear_state_actual](EPFC/update_nonlinear_state_actual.m) write the actual system model (unknown). 
- [plot_simulation_results](EPFC/plot_simulation_results.m) and [plot_comparison_results](EPFC/plot_comparison_results.m) are used for plotting and saving the outputs. The outputs are saved in a folder called `simulation_results` in `downloads`. If no such folder exists, one will be created.

### EPFC scripts
- [plot_static_gain](EPFC/plot_static_gain.m) is used for analyzing the nonlinear system static gain and consider a change of variables if necessary
- [main](EPFC/main.m) runs the simulation with the set parameters and saves the results. Parameters include:
    - `Ts` sampling time
    - `tf` final simulation time
    - `N-model` not actually used in PFC, but set it to something larger than all the `mu`s
    - `mu` output coincidence points
    - `m` input coincidence points (degrees of freedom)
    - `q` weight of each output coincidence point (same size as `mu`)
    - `r` weight of each input coincidence point (same size as `m`)
    - `psi` filter coefficients for filtering the desired reference (same size as 'mu')
    - `u_min`, `u_max` control input saturation lower and higher limits. Note that no saturation is actually applied to the input, but these are passed to the MPC controller which then calculates the control input as to not violate these constraints.
    - `x0` initial condition of the system
    - `u0` initial control input
    - `beta`, `Ni` and `TOL` are used when finding `D_nonlinar`. 
    - `method` determines the linearization method: 'jacobian' or 'perturbation'
    - `is_programmed_ref`: if set to true, the reference will be considered programmed, meaning that the controller is aware of the future values of the reference signal.
    - `noise_power` power of white noise on the output
    - `dist_amp` the amplitude of disturbance on the output. The disturbance is considered to be a pulse signal.
    - `dist_time` the time when the disturbance is applied
    - `dist_duration` the duration of the disturbance
- [one_input_one_output](EPFC/one_input_one_output.m) simulates the system for one input and one output coincidence points.
- [one_input_three_outputs](EPFC/one_input_three_outputs.m) simulates the system for one input and three output coincidence points.
- [one_input_three_outputs](EPFC/one_input_three_outputs.m) simulates the system for three input and three output coincidence points.
- [compare_coincidence_points](EPFC/compare_coincidence_points.m) compares the three cases above.
- [compare_input_coincidence_points](EPFC/compare_input_coincidence_points.m) compare different sets of input coincidence points.
- [compare_output_coincidence_points](EPFC/compare_output_coincidence_points.m) compare different sets of output coincidence points.
- [compare_constrained_vs_unconstrained](EPFC/compare_constrained_vs_unconstrained.m) compares the controller performance in presence and absence of input constraints
- [compare_linearization_methods](EPFC/compare_linearization_methods.m) compares 'perturbation' and 'jacobian' linearization methods.
- [compare_q_values](EPFC/compare_q_values.m) compares different values of q. 
- [compare_r_values](EPFC/compare_r_values.m) compares different values of r.
- [compare_psi_values](EPFC/compare_psi_values.m) compares different values of psi.
- [compare_nominal_vs_uncertainty](EPFC/compare_nominal_vs_uncertainty.m) compares the controller performance in presence and absence of uncertainty in the model.
- [compare_programmed](EPFC/compare_programmed.m) compares programmed vs unprogrammed reference signal.
- [noise_and_disturbance](EPFC/noise_and_disturbance.m) is just [main](EPFC/main.m) with more noise and disturbance to see their effects.
- [initial_condition](EPFC/initial_condition.m) is just [main](EPFC/main.m) with different initial conditions to see their effects.



