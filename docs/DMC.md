# DMC
A DMC controller is implemented to control a linear system. The linear system is actually the linearized version of a nonlinear system, which as an example is considered to be a cart with a nonlinear spring, as that used for the EPFC controller in [here](EPFC.md). 

A very simple explanation of DMC is included in [this file](DMC.pdf).

## DMC functions
The functions and scripts are as follows:
- [simulate_linear_system](../utils/dmc/simulate_linear_system.m) and [simulate_nonlinear_system](../utils/dmc/simulate_nonlinear_system.m) simulate the systems by running the whole simulation, calling the MPC controller at each timestep to get the control input, applying the control input to the systems and moving the dynamics forward.
- The DMC logic is in [this controller class](../+controllers/+dmc/DMCController.m).
- [update_linear_state](../+systems/+model/+dmc/update_linear_state.m) moves the linear system's dynamics forward one step. You can insert your linear system dynamics here.
- [update_nonlinear_state](../+systems/+model/+dmc/update_nonlinear_state.m) moves the nonlinear system's dynamics forward one step. You can insert your nonlinear system dynamics here.

A considerably smaller step size (compared to control sample time) should be considered when simulating the nonlinear system itself. The `substeps` parameter can be tuned for that (keep it at least at 10 for a realistic simulation).
- [plot_simulation_results](../utils/dmc/plot_simulation_results.m), [plot_comparison_results](../utils/dmc/plot_comparison_results.m), [plot_comparison_results_for_Q](../utils/dmc/plot_comparison_results_for_Q.m) and [plot_comparison_results_for_alpha](../utils/dmc/plot_comparison_results_for_alpha.m) are used for plotting the results.
- [plot_static_gain](../utils/dmc/plot_static_gain.m) is used for analyzing the nonlinear system's static gain at a given point 

## DMC scripts

- [plot_step_response](../utils/dmc/plot_step_response.m) is used to analyzing the linearized system's step response to obtain a reliable model horizon N
- [main](../scripts/dmc/main.m) runs the simulation with the set parameters and saves the results. Parameters include:
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
- [compare_Ms](../scripts/dmc/compare_Ms.m) compares different values of M. 
- [compare_Ns](../scripts/dmc/compare_Ns.m) compares different values of N. 
- [compare_Ps](../scripts/dmc/compare_Ps.m) compares different values of P. 
- [compare_Qs](../scripts/dmc/compare_Qs.m) compares different values of Q. 
- [compare_Rs](../scripts/dmc/compare_Rs.m) compares different values of R.
- [compare_alphas](../scripts/dmc/compare_alphas.m) compares different values of alpha. 
- [pulse](../scripts/dmc/pulse.m) pulse reference signal
- [sinusoid](../scripts/dmc/sinusoid.m) sinusoid reference signal