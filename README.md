# REEFMOD.6.4 (GBR HINDCAST) ANALYSES

Scripts and analyses to assess the cumulative impacts of multiple stressors across Australia’s Great Barrier Reef between 2008-2020.

Citation: Bozec, Y.-M., K. Hock, R. A. Mason, M. E. Baird, C. Castro-Sanguino, S. A. Condie, M. Puotinen, A. Thompson, and P. J. Mumby. 2021. Cumulative impacts across Australia’s Great Barrier Reef: A mechanistic evaluation. Ecological Monographs.

---------------------

Requires the scripts of ReefMod-GBR which can be found in 
https://github.com/ymbozec/REEFMOD.6.4_GBR_HINDCAST

You will need to run the model to create the file R0_HINDCAST_GBR.mat (~500MB) which is used in most analyses of the hincast.

---------------------

1) Parameterisation

Includes the development of demographic parameters from the literature and the production of spatial layers for the underlying forcings:
- cyclones
- bleaching
- water quality

The folder 'Water_quality' contains scripts to extract biogeochemical variables from eReefs GBR4 (not archived here due to size limits of GitHub repositories), 
which are then processed to calculate impacts on coral and CoTS demographics. This creates the temporal/spatial layers (GBR_REEF_POP.mat) 
underlying coral demographics in ReefMod-GBR. These scripts also allow to produce the water quality maps (fig 3D-F, fig 4A,  fig S1-S6, fig S8, fig S9)


2) Calibration

Scripts used to calibrate the processes of coral recruitment and mortality due to CoTS, cyclones and bleaching. 
Requires uploading REEFMOD.6.4_GBR in the workspace (see companion repository). 
Each calibration can be run from the associated front script 'MAIN_CALIBRATION_...'. 
Parameters can be changed in f_single_reef_calibration.m to run the model on a per reef basis. 
Each calibration produces output csv files for plotting in R (R_plot_calibration.R) to obtain fig 2, fig 3C,D, and fig S12.
EXPLORE_RELATIONSHIP_LTMP.m builds the linear relationship between transect and manta tow estimates of coral cover 
(conversion used in ReefMod to intialize reefs and to validate the model).


3) Hindcast analyses

- S1_HINDCAST_ANALYSIS.m calculates summary metrics (rates of change, annual mortalities,..) from the output file R0_HINDCAST_GBR.mat.
This would produce the file 'HINDCAST_METRICS.mat' to be used by the other scripts listed below
- S2_HINDCAST_ANNUAL_CHANGES.m to summarize annual losses per region, shelf position etc. (fig 4B, 8D)
- S3_HINDCAST_TRAJECTORIES.m to plot reef trajectories over time (fig 4A, fig S15)
- S4_HINDCAST_MAPS.m to map outputs across the entire GBR (fig 7, fig 8, fig 10, fig 11)
- S5_HINDCAST_TRAJECTORIES_REEFbyREEF.m to plot individual reef trajectories for validation (fig 5, fig S17)
- ANALYSIS_COMMUNITY_COMPO.R runs the Correspondence Analysis of temporal changes in community composition (fig S16) 
- ANNUAL_LOSS.ods summarizes mean annual losses (absolute and relative) for each stressor/region (Table 1, Table 2)
- MEAN_TRAJECTORIES.ods gives the average coral cover per time step in each region/shelf position with annual absolute/proportional cover changes (Table S3)

The other scripts are functions needed by those listed above.

The folder 'DRIVER_ANALYSIS' contains
- S1_EXTRACT_DRIVERS_FOR_GROWTH.m to set up the values of the predictors of coral growth for building the GLMs in ANALYSIS_DRIVERS.R
- ANALYSIS_DRIVERS.R for fitting coral growth with GLMs and simulate recovery curve from environmental drivers (Fig 9). This also simulates
the recovery potential for every reef (recovery rates exported in Predicted_Growth_from_R.mat to be used in S4_HINDCAST_MAPS.m for fig 10A)
- S2_EXTRACT_MORTALITY_FOR_RESILIENCE.m for deriving relationship between coral cover loss and stress intensity (cyclones and bleaching, fig S14)
- ANALYSIS_RESILIENCE.R for calculating equilibrial values exported as ALL_EQUILIBRIA_FROM_R.mat to be used in HINDCAST_MAPS.m' for fig 10C

The folder 'SENSITIVITY' contains the scripts for calculating model and observation errors for each hindcast scenario (fig 6, fig S18)
