%__________________________________________________________________________
%
% REEFMOD-GBR MAIN SCRIPT FOR CALIBRATION OF COTS DAMAGES
% requires uploading the model in the workspace:
% /data
% /functions
% /outputs
% /settings
%
% Parameters tuned in the script f_single_reef_for_calibration_COTS
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

%% CALIBRATION
NB_TIME_STEPS = 6;
% first observation in Lizard is Oct 96, so inital step is winter 1996
% Last observation is Sept 99, so last step is winter 1999
% So 6 time steps:
% step 1 = summer 97
% step 2 = winter 97
% step 3 = summer 98
% step 4 = winter 98
% step 5 = summer 99
% step 6 = winter 99

NB_SIMULATIONS = 40;

warming_scenario = ''
% warming_scenario = '2p6'
% warming_scenario = '8p5'

SCENARIO = 'COTS_CALIBRATION' 

%% --------------------------------------------------------------------------------
% Options
do_adaptation = 0 ; % yes(1)/no(0)
do_rubble = 1 ;  % yes(1)/no(0)
RESTORATION.nb_reefs_restored = 0 ;
RESTORATION.doing_cooling = 0 ;
ADAPT = [ 0 0 0 ];

%% --------------------------------------------------------------------------------
OUTPUTS = struct('REEF', [],'RESULT', [],'RECORD', []);


for i=1:NB_SIMULATIONS
    
    i
    
    [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_COTS(RESTORATION, warming_scenario,...
        do_adaptation, do_rubble, ADAPT(1,1),ADAPT(1,2),ADAPT(1,3), NB_TIME_STEPS, i);
    
    OUTPUTS(i).RESULT = RESULT ;
    OUTPUTS(i).RECORD = RECORD ;
    
end
                
coral_cover_per_taxa = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1,META.nb_coral_types);
rubble_cover = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1);
nb_coral_outplanted = zeros(META.nb_simul,META.nb_reefs,META.nb_time_steps+1,META.nb_coral_types);
perceived_CoTS_per_tow = zeros(META.nb_simul,META.nb_reefs,META.nb_time_steps+1);
COTS_densities = zeros(META.nb_simul,META.nb_reefs,META.nb_time_steps+1);
COTS_distri = zeros(META.nb_simul,META.nb_reefs,META.nb_time_steps+1,META.COTS_maximum_age);

for s = 1:NB_SIMULATIONS
    coral_cover_per_taxa(s,:,:,:) = squeeze(cat(4,OUTPUTS(s).RESULT.coral_pct2D));
    rubble_cover(s,:,:) = OUTPUTS(s).RESULT.rubble_cover_pct2D ;
    perceived_CoTS_per_tow(s,:,:) = (0.22/0.6)*squeeze(cat(4,OUTPUTS(s).RESULT.COTS_total_perceived_density));
    COTS_densities(s,:,:) = squeeze(sum(OUTPUTS(s).RESULT.COTS_all_densities(:,:,3:end),3))/2; % Divide by 2 to get density for 200m2
    COTS_distri(s,:,:,:)= squeeze(OUTPUTS(s).RESULT.COTS_all_densities)/2; % for 200m2.
end

%% FORMAT OUTPUTS
Coral_cover_tot = squeeze(sum(coral_cover_per_taxa,4));
Coral_tot_M = squeeze(mean(Coral_cover_tot, 1)) ;
Coral_tot_SD = squeeze(std(Coral_cover_tot, 0, 1)) ;
Rubble_M = squeeze(mean(rubble_cover, 1)) ;
Rubble_SD = squeeze(std(rubble_cover, 0, 1)) ;

%% PLOT CHANGES IN COVER AND COTS
start_year = 1996.5 ;
years =  start_year + (0:META.nb_time_steps)/2 ;
years = [1996.8 years(2:end)];

area_w = META.area_habitat/sum(META.area_habitat); % weigh by habitat area

CoTS_M = squeeze(mean(COTS_densities,1));
CoTS_SD = squeeze(std(COTS_densities,[],1));

OBS_CORAL = [32.16 29.2 27.3 25.9 25.9 23.9 nan 22.4 22.2];
OBS_COTS = [0.775 1.025 0.945 0.995 0.855 1.1 0.825 0.275 0.07];
OBS_TIME = [1996.8 1996.9 1997.1 1997.4 1997.9 1998.1 1998.5 1998.9 1999.1];

hfig1 = figure;
filename= 'FIG_COTS_CALIBRATION_1';
SaveDir = ''

width=500; height=300; x0=10; y0=10;
set(hfig1,'color','w','units','points','position',[x0,y0,width,height])
minYear=1996.7;
maxYear=1999.5;

subplot(1,2,1)
minCover = 0 ;
maxCover = 40 ;
plot(years, squeeze(Coral_cover_tot),'-','Color',rgb('DarkGray'));hold on
plot(years, Coral_tot_M,'-','Color',rgb('Crimson'),'LineWidth',2);
plot(OBS_TIME, OBS_CORAL,'o','MarkerFaceColor',rgb('black'),'MarkerEdgeColor',rgb('black'),'MarkerSize',9);
set(gca,'Layer', 'top','FontName', 'Arial','FontSize',10);
xlabel({'Years';''},'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
ylabel({'';'Total coral cover (%)';''},'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
axis([minYear maxYear minCover maxCover]);
xticks([1997:1:1999])

subplot(1,2,2)
maxDens = 1.5 ;
plot(years, squeeze(COTS_densities),'-','Color',rgb('DarkGray'));hold on
plot(years, CoTS_M,'-','Color',rgb('Navy'),'LineWidth',2);
plot(OBS_TIME, OBS_COTS,'o','MarkerFaceColor',rgb('black'),'MarkerEdgeColor',rgb('black'),'MarkerSize',9);
set(gca,'Layer', 'top','FontName', 'Arial','FontSize',10);
xlabel({'Years';''},'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
ylabel({'';'Total CoTS density (200m2)';''},'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
axis([minYear maxYear 0 maxDens]);
xticks([1997:1:1999])

% IMAGENAME = [SaveDir filename];
% print(hfig1, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
% crop([IMAGENAME '.png'],0,20); close(hfig1);


%% PLOT SIZE DISTRIBUTION
% load('Pratchett_COTS_size_distri.mat') % freq of size classes for eahc season in 'Dates'
load('Pratchett_COTS_size_distri_NEW.mat') % freq of size classes for eahc season in 'Dates'
Dates = {'winter 96' 'summer 97' 'winter 97' 'summer 98' 'winter 98' 'summer 99'};
Dates_obs = {'Oct 96' 'Feb 97' 'Jun 97' 'Feb 98' 'Jun 98' 'Jan 99'};

hfig2 = figure;
width=1200; height=600; x0=10; y0=10;
set(hfig2,'color','w','units','points','position',[x0,y0,width,height])
barwidth = 0.6;
% classnames = {'<15cm','15-20','20-25','25-30','30-35','35-40','40-45','45-50','50-55','55-60', '>60'};
classnames = {'<15cm','','20-25','','30-35','','40-45','','50-55','', '>60'};
seasons = [1 2 1 2 1 2]; % 1 for winter, 2 for summer

simul_distri = squeeze(mean(COTS_distri,1));
OBS_COTS_SELECT = OBS_COTS([1 3 4 6 7 9]);% select the total density for the selected size distri

for t=1:6
    
    subplot(2,6,t)
    bar([1:1:11],OBS_COTS_SELECT(t)*Pratchett_freqsize(t,:)/sum(Pratchett_freqsize(t,:)),barwidth,'FaceColor',rgb('Crimson'))
    axis([0 12 0 0.4])
    title(Dates_obs(t))
    set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',10,'xticklabel',classnames);
    set(gca,'XTickLabelRotation',45)
    hold on; bar(1,OBS_COTS_SELECT(t)*Pratchett_freqsize(t,1)/sum(Pratchett_freqsize(t,:)),barwidth,'FaceColor',rgb('Black'))
    xlabel('Diameter (cm)') ; ylabel('CoTS per 200m2')
    
    subplot(2,6,t+6)
    simul = f_convert_age_size_distri(simul_distri(t,:),seasons(t));   
    bar([1:1:11],simul,barwidth,'FaceColor',rgb('Gray'));
    axis([0 12 0 0.4])
    title(Dates(t))
    set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',10,'xticklabel',classnames);
    set(gca,'XTickLabelRotation',45)   
    hold on; bar(1,simul(1),barwidth,'FaceColor',rgb('black'))
    xlabel('Diameter (cm)') ; ylabel('CoTS per 200m2') 
end

% IMAGENAME = [SaveDir 'COTS_size_distri'];
% print(hfig2, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
% crop([IMAGENAME '.png'],0,20); close(hfig2);


%% EXPORT DATA TO PLOT WITH R
csvwrite('OUTPUT_LIZARD_CORAL.csv',squeeze(Coral_cover_tot))
csvwrite('OUTPUT_LIZARD_COTS.csv',squeeze(COTS_densities))
