%__________________________________________________________________________
%
% REEFMOD-GBR MAIN SCRIPT FOR CALIBRATION OF BLEACHING MORTALITY
% requires uploading the model in the workspace:
% /data
% /functions
% /outputs
% /settings
%
% Parameters tuned in the script f_single_reef_for_calibration_bleaching
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

%% CALIBRATION
NB_TIME_STEPS = 1; 
NB_SIMULATIONS = 40;

warming_scenario = ''
% warming_scenario = '2p6'
% warming_scenario = '8p5'

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
    
    [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_bleaching(RESTORATION, warming_scenario,...
        do_adaptation, do_rubble, ADAPT(1,1),ADAPT(1,2),ADAPT(1,3), NB_TIME_STEPS, i);
    
    OUTPUTS(i).RESULT = RESULT ;
    OUTPUTS(i).RECORD = RECORD ;
    OUTPUTS(i).REEF = REEF ;
    
end
                
coral_cover_per_taxa = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1,META.nb_coral_types);
rubble_cover = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1);
reefs_DHW = zeros(NB_SIMULATIONS,META.nb_reefs);

for s = 1:NB_SIMULATIONS
    coral_cover_per_taxa(s,:,:,:) = squeeze(cat(4,OUTPUTS(s).RESULT.coral_pct2D));
    rubble_cover(s,:,:) = OUTPUTS(s).RESULT.rubble_cover_pct2D ;
    for n=1:META.nb_reefs
        reefs_DHW(s,n) = OUTPUTS(s).REEF(n).predicted_DHWs;
    end
end

%% FORMAT OUTPUTS
Coral_cover_tot = squeeze(sum(coral_cover_per_taxa,4));
Coral_tot_M = squeeze(mean(Coral_cover_tot, 1)) ;
Coral_tot_SD = squeeze(std(Coral_cover_tot, 0, 1)) ;
Rubble_M = squeeze(mean(rubble_cover, 1)) ;
Rubble_SD = squeeze(std(rubble_cover, 0, 1)) ;

%% PLOT
load('Hughes_cover_change.mat')

CoverChange = 100*(Coral_cover_tot(:,:,2)-Coral_cover_tot(:,:,1))./Coral_cover_tot(:,:,1);

FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;

hfig = figure;
width=400; height=400; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');

plot(reefs_DHW(:),CoverChange(:),'o'); hold on
plot(Hughescoverchange.DHW,Hughescoverchange.CoverChange,'o','Markersize',10,'MarkerEdgeColor',rgb('Red'),'MarkerFaceColor',rgb('Red'))

axis([0 10.5 -100 10]); xticks([0:2:10]); yticks([-100:20:20])


%% Check coral cover frequency distributions

% Hughes' obs (110 reefs)
F1_OBS = 100*[ 0 ; 12 ; 25 ; 39 ; 24 ; 6 ; 4 ]/110;
F2_OBS = 100*[ 24 ; 31 ; 27 ; 13 ; 8 ; 3 ; 4 ]/110;

% Simulated
CoverBefore = Coral_cover_tot(:,:,1);
CoverAfter = Coral_cover_tot(:,:,2);
centerbins = [5 15 25 35 45 55 65];
F1 = 100*hist(CoverBefore',centerbins)/110;
F2 = 100*hist(CoverAfter',centerbins)/110;

% plot observed frequency distri
figure
bar([F1_OBS F2_OBS])
hold on
plot([1:7]-0.15,mean(F1,2),'o','MarkerFaceColor',rgb('Blue'))
plot([1:7]+0.15,mean(F2,2),'o','MarkerFaceColor',rgb('Red'))

xticklabels({'0-10' , '10-20' , '20-30' , '30-40' , '40-50 ' , '50-60' , '60-100'})


%% EXPORT DATA TO PLOT WITH R
% COVER_CHANGE = table(reefs_DHW(:), CoverChange(:),'VariableNames', {'DHW' 'CoverChange'});
% FREQ_DISTRI = table(F1_OBS, F2_OBS, mean(F1,2), mean(F2,2), std(F1,[],2), std(F2,[],2),...
%     'VariableNames', {'BeforeObs' 'AfterObs' 'BeforeMeanModel' 'AfterMeanModel'	'BeforeSDModel'	'AfterSDModel'});
% 
% writetable(COVER_CHANGE,'OUTPUT_BLEACHING_COVER_CHANGE.csv')
% writetable(FREQ_DISTRI,'OUTPUT_BLEACHING_FREQ_DISTRI.csv')
