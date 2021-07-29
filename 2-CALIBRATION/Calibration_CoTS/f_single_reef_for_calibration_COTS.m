
function [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_COTS(RESTORATION, warming_scenario, ...
    do_adaptation, do_rubble, sigma_cold, sigma_hot, esd, nb_time_steps, simul)

%__________________________________________________________________________
%
% TEMP script for running only one reef for calibration of COTS damages
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 06/2018
%__________________________________________________________________________
PARAMETERS

META.nb_time_steps = nb_time_steps;
META.max_colonies = 40 ; %Maximum number of colonies per species per cell

load('GBR_REEF_POLYGONS.mat')


%% Initial conditions for CoTS calibration
META.nb_reefs = 1;

% 1312, Lizard Island Reef (North West) (14-116a)
% 1313, Lizard Island Reef (North East) (14-116b)
% 1314, Lizard Island Reef (Lagoon) (14-116d)
% 1332, Lizard Island Reef (Coconut Bay) (14-116c)

% Force init cover to the one observed by Pratchett (2010)
M = mean([32.16 29.2])/100; % mean of Oct 96, Dec 96

rel_prop = [0.15 0.15 0.20 0.10 0.20 0.20];

varSD = 0.01*ones(1,6);
init_coral_cover = M*rel_prop;

CYCLONE_CAT = zeros(META.nb_reefs,META.nb_time_steps);
META.reef_ID = 1312; % select Lizard reefs(1 reef)
META.area_habitat = 0.01*ones(length(META.nb_reefs),1); %in km2 -> 1 hectare

% ALSO: in run_model, need to change option for generating random density
% population at initial step -> use normal distribution here.
% Need to force the outbreak duration (L.567) to 2 years

%% Automatic generations
for s=1:6
    init_coral_cover(:,s) = normrnd(init_coral_cover(:,s), varSD(1,s));
end

init_coral_cover(init_coral_cover<0)=0.01;

% Now populate random rubble and sand covers
init_rubble = 0.1;
init_sand = 0.30;

varSDother = 0.2;

init_rubble_cover = normrnd(init_rubble*100, varSDother*init_rubble*100, length(META.reef_ID), 1)/100 ;
init_rubble_cover(init_rubble_cover<0) = 0.01;

init_sand_cover = normrnd(init_sand*100, varSDother*init_sand*100, length(META.reef_ID), 1)/100 ;
init_sand_cover(init_sand_cover<0) = 0.01;

CHECK = sum(init_coral_cover,2) + init_sand_cover;
init_sand_cover(CHECK>0.95) = 0.95 - sum(init_coral_cover(CHECK>0.95,:),2); % always leave 5% free space to avoid conflicts


%% Bleaching
META.doing_bleaching = 0 ;
META.deterministic_bleaching = 0;

%% Cyclones
META.doing_hurricanes = 0 ;
META.random_hurricanes = 0; % put 0 to apply a specific scenario (1 imposes random occurence)
META.deterministic_hurricane_mortality = 0; % option for generating deterministic (1) or random (0) mortalites from cyclone cat

%% CoTS and Water quality
META.doing_water_quality = 0;
META.randomize_WQ_chronology = 0;

META.doing_COTS = 1 ;
META.doing_COTS_control = 0 ;
REEF_COTS =[];

%% Connectivity
META.doing_coral_connectivity = 0 ;
META.doing_size_frequency = 0;

META.recruitment_type = 1; % turn into 0 for fixed recruitment (but then connect and genetics don't work)

CORAL.prop_settlers = [ 0.05 0.25 0.25 0.15 0.15 0.15];
CORAL.BH_alpha = 15*CORAL.prop_settlers;
CORAL.BH_beta = 5e6*ones(1,6); % with META.coral_min_selfseed = 0.28
META.coral_min_selfseed = 0.28 ; % relative proportion of produced larvae that stay on the reef (Helix experiment)

META.coral_immigration = rand(1)*0.2*CORAL.BH_beta(1)*ones(1,META.nb_time_steps) ; % Forced larval input for a 400m2 area - only works if connectivity is OFF

%% Rubble options (do_rubble forced to 1)
META.tracking_rubble = 1;
META.rubble_decay_rate = 0.0830 ;
META.rubble_decay_rate = 0.128 ; % 2/3 stabilized after 4 years
META.convert_rubble = 1;%1/sin(45); % multiplication factor to get rubble cover from lost cover of live corals

RESTORATION.cooling = 0;
META.nb_restored_reefs = 0;
META.doing_genetics = do_adaptation ;

rng('shuffle')

%% NON-SPECIFIC REEF PARAMETERS
REEF.herbivory = 1 ; % full grazing
REEF.dictyota_declines_seasonally = 0 ;
ALGAL.nb_step_algal_dynamics = 1; %%%%% ONLY TO SPEED_UP THE CODE WITH FULL GRAZING


%% INITIALISATION
INITIALISATION ;


%% Then populate REEF parameters
for n = 1:length(META.reef_ID)
    
    reef = META.reef_ID(n);
    
    REEF(n).initial_coral_cover = init_coral_cover(n,:);
    REEF(n).initial_algal_cover = 0.1*[ 0 ; 0.05 ; 0.05 ; 0 ] ; 
    REEF(n).nongrazable_substratum = init_sand_cover(n,1) ;
    REEF(n).initial_rubble_pct = 100*init_rubble_cover(n,1) ;
    
    % Default values (modified by WQ in runmodel)
    REEF(n).juv_whole_mortality_rate = CORAL.juv_whole_mortality_rate;
    REEF(n).adol_whole_mortality_rate = CORAL.adol_whole_mortality_rate;
    REEF(n).adult_whole_mortality_rate = CORAL.adult_whole_mortality_rate;
    
    % Default values for herbivory
    REEF(n).diadema = REEF(1).diadema ;
    REEF(n).herbivory = REEF(1).herbivory ;
    REEF(n).dictyota_declines_seasonally = REEF(1).dictyota_declines_seasonally ;
    
    % Store the bleaching scenario
    REEF(n).predicted_DHWs = zeros(META.nb_time_steps);
    REEF(n).Topt_baseline = 0;
    REEF(n).predicted_SST = zeros(META.nb_time_steps);
    REEF(n).SST_baseline =  0;
    
    % Store the scenario of cyclones
    REEF(n).hurricane_chronology = CYCLONE_CAT(n,:);
   
end

%% Initialisation COTS
META.COTS_outbreak_duration = 2 ;
META.randomize_initial_COTS_densities = 1 ; % 1 for Gaussian (for calibration), 2 for Poisson

META.doing_COTS_connectivity = 0 ;
META.COTS_immigration = 0*ones(1, META.nb_time_steps) ;

REEF_COTS.densities_M = nan(1,META.nb_time_steps);
REEF_COTS.densities_M(1,1)=2*(0.775 + 1.025 )/2; % (first 2 surveys averaged, for a 400m2 area)
REEF_COTS.densities_SD(1,1)=0.2; % Pratchett (2005)

% load('Pratchett_COTS_size_distri.mat') % freq of size classes for eahc season in 'Dates'
load('Pratchett_COTS_size_distri_NEW.mat') % freq of size classes for eahc season in 'Dates'

OBS_TOT = sum(Pratchett_freqsize,2);
OBS_FREQ1 = Pratchett_freqsize(1,:)/OBS_TOT(1);
OBS_FREQ2 = Pratchett_freqsize(2,:)/OBS_TOT(2);

AGE_FREQ = 0*META.COTS_init_age_distri_OUTBREAK(1,:);
AGE_FREQ(2)=(OBS_FREQ2(2)/(1-META.COTS_mortality(2))); % extrapolate from the next size class at the next step 
AGE_FREQ(4)=OBS_FREQ1(2);
AGE_FREQ(6)=OBS_FREQ1(3)+OBS_FREQ1(4);
AGE_FREQ(8)=OBS_FREQ1(5)+OBS_FREQ1(6);
AGE_FREQ(10)=OBS_FREQ1(7)+OBS_FREQ1(8)/2;
AGE_FREQ(12)=OBS_FREQ1(8)/2;
AGE_FREQ(14)=OBS_FREQ1(9)/2;
AGE_FREQ(16)=(OBS_FREQ1(9)/2)+OBS_FREQ1(10)+OBS_FREQ1(11);

META.COTS_init_age_distri_OUTBREAK(2,:) = AGE_FREQ ;

% obs_Oct96 = [ 0 0 0 25 36 28 37 12 7 4 2 2 2 0 0 0]/155;
% obs_Dec96 = [ 0 0 7 19 34 28 39 28 15 15 7 5 3 2 2 1]/205;
% 
% Pratchett           | 1   |  2  |  3  |  4  |  5  |  6  |  6  |  7  |  7  | 8   | 8   | 9   |  9  |  10  |  11 |
% size                     150   200   250   300   350         400         450         500         550    600   650
% YM        | 1  | 2  | 3   |  4  |  5  |  6  |  7  |  8  |  9  |  10 | 11  | 12  | 13  |  14 | 15  |  16  
% size      | 10 | 69 | 126 | 179 | 229 | 275 | 318 | 358 | 394 | 427 | 457 | 483 | 506 | 525 | 542 | 554

META.COTS_BH_alpha = 4*1e4 ; % which is 100 settlers per m2
META.COTS_BH_beta = 0.5*1e7 ; % which is 12,500 larva/m2 = calibrated parameter, after reduction of consumption and adult mortality

clear sigma_hot sigma_cold esd
clear CYCLONE_CAT DHW GBR_REEF_POP SST_GBR SST_baseline GBR_REEFS reef n 
clear init_coral_cover init_rubble_cover init_sand_cover

[RESULT, RECORD] = f_runmodel(META, REEF, CORAL, ALGAL, CONNECT, REEF_POP, REEF_COTS) ;
