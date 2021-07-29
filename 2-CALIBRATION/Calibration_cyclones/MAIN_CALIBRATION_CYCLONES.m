%__________________________________________________________________________
%
% REEFMOD-GBR MAIN SCRIPT FOR CALIBRATION OF CYCLONE MORTALITY
% requires uploading the model in the workspace:
% /data
% /functions
% /outputs
% /settings
%
% Parameters tuned in the script f_single_reef_for_calibration_cyclones
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear


%% CALIBRATION
NB_TIME_STEPS = 1;
NB_SIMULATIONS = 40;

warming_scenario = ''
% warming_scenario = '2p6'
% warming_scenario = '8p5'

SCENARIO = 'CYCLONE_CALIBRATION' 

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
    
    [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_cyclones(RESTORATION, warming_scenario,...
        do_adaptation, do_rubble, ADAPT(1,1),ADAPT(1,2),ADAPT(1,3), NB_TIME_STEPS, i);
    
    OUTPUTS(i).RESULT = RESULT ;
    OUTPUTS(i).RECORD = RECORD ;
    
end
                
coral_cover_per_taxa = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1,META.nb_coral_types);
rubble_cover = zeros(NB_SIMULATIONS,META.nb_reefs,META.nb_time_steps+1);

for s = 1:NB_SIMULATIONS
    coral_cover_per_taxa(s,:,:,:) = squeeze(cat(4,OUTPUTS(s).RESULT.coral_pct2D));
    rubble_cover(s,:,:) = OUTPUTS(s).RESULT.rubble_cover_pct2D ;   
end

%% FORMAT OUTPUTS
Coral_cover_tot = squeeze(sum(coral_cover_per_taxa,4));
Coral_tot_M = squeeze(mean(Coral_cover_tot, 1)) ;
Coral_tot_SD = squeeze(std(Coral_cover_tot, 0, 1)) ;
Rubble_M = squeeze(mean(rubble_cover, 1)) ;
Rubble_SD = squeeze(std(rubble_cover, 0, 1)) ;

%% PLOT
load('AIMS_LTMP_transects_calibration_cyclones.mat');
load('AIMS_LTMP_transects_calibration_cyclones_SITE_MEAN.mat');

select_before = find(AIMSLTMPtransectscalibrationcyclones.STORM_DATE == 'BEFORE');
select_after = find(AIMSLTMPtransectscalibrationcyclones.STORM_DATE == 'AFTER');

OBS_BEFORE = AIMSLTMPtransectscalibrationcyclones.AllCorals(select_before);
OBS_AFTER = AIMSLTMPtransectscalibrationcyclones.AllCorals(select_after);

OBS_SP_BEFORE = table2array(AIMSLTMPtransectscalibrationcyclones(select_before,7:12));
OBS_SP_AFTER = table2array(AIMSLTMPtransectscalibrationcyclones(select_after,7:12));

select_before_MEAN = find(AIMSLTMPtransectscalibrationcyclonesSITEMEAN.STORM_DATE == 'BEFORE');
select_after_MEAN = find(AIMSLTMPtransectscalibrationcyclonesSITEMEAN.STORM_DATE == 'AFTER');

OBS_MEAN_BEFORE = AIMSLTMPtransectscalibrationcyclonesSITEMEAN.AllCorals(select_before_MEAN);
OBS_MEAN_AFTER = AIMSLTMPtransectscalibrationcyclonesSITEMEAN.AllCorals(select_after_MEAN);

Change_AllCorals = (Coral_tot_M(:,2)-Coral_tot_M(:,1))./Coral_tot_M(:,1);


CAT = AIMSLTMPtransectscalibrationcyclones.CATEGORY(select_before);
CAT_MEAN = AIMSLTMPtransectscalibrationcyclonesSITEMEAN.CATEGORY(select_before_MEAN);


FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;

hfig = figure;
width=1200; height=400; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');

subplot(1,3,1)
plot(Coral_cover_tot(:,CAT==1,1),Coral_cover_tot(:,CAT==1,2),'.','Markersize',20,'Color',rgb('DarkGray'))
hold on; plot(OBS_BEFORE(CAT==1),OBS_AFTER(CAT==1),'.','Markersize',36,'Color',rgb('Black')) 
% hold on; plot(OBS_MEAN_BEFORE(CAT_MEAN==1),OBS_MEAN_AFTER(CAT_MEAN==1),'o','Markersize',10,'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('White')) 
plot([0 70],[0 70],'--','Color','k')
axis([0 70 0 70]); xticks([0:10:70]); yticks([0:10:70])
xlabel('Pre-cyclonic coral cover (%)','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
ylabel({'Post-cyclonic coral cover (%)';''},'FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
axis square

subplot(1,3,2)
plot(Coral_cover_tot(:,CAT==2,1),Coral_cover_tot(:,CAT==2,2),'.','Markersize',20,'Color',rgb('DarkGray'))
hold on; plot(OBS_BEFORE(CAT==2),OBS_AFTER(CAT==2),'.','Markersize',36,'Color',rgb('Black')) 
% hold on; plot(OBS_MEAN_BEFORE(CAT_MEAN==2),OBS_MEAN_AFTER(CAT_MEAN==2),'o','Markersize',10,'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('White')) 
plot([0 70],[0 70],'--','Color','k')
axis([0 50 0 50]); xticks([0:10:50]); yticks([0:10:50])
xlabel('Pre-cyclonic coral cover (%)','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
ylabel({'Post-cyclonic coral cover (%)';''},'FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
axis square

subplot(1,3,3)
plot(Coral_cover_tot(:,CAT==4,1),Coral_cover_tot(:,CAT==4,2),'.','Markersize',20,'Color',rgb('DarkGray'))
hold on; plot(OBS_BEFORE(CAT==4),OBS_AFTER(CAT==4),'.','Markersize',36,'Color',rgb('Black'))
% hold on; plot(OBS_MEAN_BEFORE(CAT_MEAN==4),OBS_MEAN_AFTER(CAT_MEAN==4),'o','Markersize',10,'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',rgb('White')) 
plot([0 70],[0 70],'--','Color','k')
axis([0 50 0 50]); xticks([0:10:50]); yticks([0:10:50])
xlabel('Pre-cyclonic coral cover (%)','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
ylabel({'Post-cyclonic coral cover (%)';''},'FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
axis square


%% EXPORT DATA TO PLOT WITH R
% csvwrite('OUTPUT_BEFORE_CYCL.csv',Coral_cover_tot(:,:,1)')
% csvwrite('OUTPUT_AFTER_CYCL.csv',Coral_cover_tot(:,:,2)')
% csvwrite('OUTPUT_CYCL_CAT.csv',CAT)
