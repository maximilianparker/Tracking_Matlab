# Tracking_Matlab

These codes fit a couple of control models, based on PCT, to tracking data.

Step2_Optimisation is the code that sets the optimisation parameters, loads the data and fits the models
The model files are functions called by the optimisation file

The optimisation file is set up to collect best fitting parameters and associated statistics for the models at a range of delay values specified at the top of the file

The Pos_model uses only target and cursor position information to determine future predicted cursor position
The PosX_model also uses target velocity information in order to account for the speed and direction in which the target is moving.
