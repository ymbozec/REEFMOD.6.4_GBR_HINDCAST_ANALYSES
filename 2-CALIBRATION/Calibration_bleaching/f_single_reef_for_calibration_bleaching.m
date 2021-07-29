
function [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_bleaching(RESTORATION, warming_scenario, ...
    do_adaptation, do_rubble, sigma_cold, sigma_hot, esd, nb_time_steps, simul)

%__________________________________________________________________________
%
% TEMP script for running only one reef for calibration
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 06/2018
%__________________________________________________________________________
PARAMETERS

META.nb_time_steps = nb_time_steps;
META.max_colonies = 40 ; %Maximum number of colonies per species per cell

load('GBR_REEF_POLYGONS.mat')


%% Initial conditions for bleaching calibration
load('Hughes_cover_change.mat')
META.nb_reefs = 110; % 110 reefs with reported change in Extended Fig3 of Hughes et al (2018) 
% Note that only 63 appears on Fig. 3c, which is a subset of the 110 reefs
META.reef_ID = randi(3806,META.nb_reefs,1);
META.area_habitat = 0.01*ones(length(META.nb_reefs),1); %in km2 -> 1 hectare
init_tot = zeros(META.nb_reefs,1);
init_tot(1:12,1) = randi([10,20],12,1);
init_tot(13:37,1) = randi([20,30],25,1);
init_tot(38:76,1) = randi([30,40],39,1);
init_tot(77:100,1) = randi([40,50],24,1);
init_tot(101:106,1) = randi([50,60],6,1);
init_tot(107:110,1) = randi([60,65],4,1);
% From Hughes et al 2018 Extended Fig3 - pre-bleaching coral cover on 110 reefs
% 00-10:	0
% 10-20:	12
% 20-30:	25
% 30-40:	39
% 40-50:	24
% 50-60:	6
% 60-100:	4

init_tot = init_tot(randperm(META.nb_reefs),1);
rel_prop = [0.15 0.15 0.20 0.10 0.20 0.20];
init_coral_cover = zeros(META.nb_reefs,6);

for s=1:6
    init_coral_cover(:,s) = init_tot.*rel_prop(1,s)/100;
end

varSD = 0.005*ones(1,6);
CYCLONE_CAT = zeros(META.nb_reefs,META.nb_time_steps);
 

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
META.doing_bleaching = 1 ;
META.deterministic_bleaching = 0;
CORAL.sensitivity_bleaching = [1.5 ; 1.6 ; 1.4 ; 1.7 ; 0.25 ; 0.25];
CORAL.bleaching_partial_extent = [0.05 ; 0.05 ; 0.05 ; 0.05 ; 0.4 ; 0.2]; % minimal for branching
META.DHW_threshold = 3 ; %DHW threshold that triggers bleaching (was 6 DHW for GBRF)
META.bleaching_whole_offset = 6 ; % extrapolates Hughes' initial mortality to whole colony mortality for the entire event
META.bleaching_partial_offset = 6 ; % extrapolates Hughes' initial mortality to partial mortality for the entire event

%% Cyclones
META.doing_hurricanes = 0 ;
META.random_hurricanes = 0; % put 0 to apply a specific scenario (1 imposes random occurence)
META.deterministic_hurricane_mortality = 0; % option for generating deterministic (1) or random (0) mortalites from cyclone cat

%% CoTS and Water quality
META.doing_water_quality = 0;!
META.randomize_WQ_chronology = 0;

META.doing_COTS = 0 ;
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


% Initialisation Bleaching
for n=1:META.nb_reefs
    
    REEF(n).predicted_DHWs = Hughescoverchange.DHW(randi(length(Hughescoverchange.DHW)));
    
end

clear sigma_hot sigma_cold esd
clear CYCLONE_CAT DHW GBR_REEF_POP SST_GBR SST_baseline GBR_REEFS reef n 
clear init_coral_cover init_rubble_cover init_sand_cover

[RESULT, RECORD] = f_runmodel(META, REEF, CORAL, ALGAL, CONNECT, REEF_POP, REEF_COTS) ;
