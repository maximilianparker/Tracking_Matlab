# Tracking_Matlab

These codes fit a PCT position control model to some sample tracking data.

'test_opt_pos.m': Loads the data and optimises the parameters of the model, plots position and velocity outputs (cursor vs model cursor).
'test_model_pos.m': Is a function called within the optimisation script which contains the PCT model and the objective function.

The optimisation file is set up to estimate the best fitting parameters given a delay value (T)

The position model takes as input the difference between the target and cursor, delayed by a constant value.
The model comprises three free parameters: Gain (proportional), damping constant (leaky integrator) and reference value (set point).

This model has been used extensively in PCT research and is approximately equivalent to the model used in the following paper:

Parker, M. G., Tyson, S. F., Weightman, A. P., Abbott, B., Emsley, R., & Mansell, W. (2017). Perceptual control models of pursuit manual tracking demonstrate individual specificity and parameter consistency. Attention, Perception, & Psychophysics, 79(8), 2523-2537.

The article can be found here (open access): https://link.springer.com/article/10.3758/s13414-017-1398-2

