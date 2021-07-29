%__________________________________________________________________________
%
% REEFMOD-GBR MAIN SCRIPT FOR CALIBRATION OF CORAL RECRUITMENT
% requires uploading the model in the workspace:
% /data
% /functions
% /outputs
% /settings
%
% Parameters tuned in the script f_single_reef_for_calibration_recruitment
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

%% CALIBRATION
NB_TIME_STEPS = 40; 
NB_SIMULATIONS = 100;

warming_scenario = ''
% warming_scenario = '2p6'
% warming_scenario = '8p5'

SCENARIO = 'RECRUITMENT_CALIBRATION' 

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
%     parfor i=1:NB_SIMULATIONS
    
    i
    
    [META, REEF, RESULT, RECORD] = f_single_reef_for_calibration_recruitment(RESTORATION, warming_scenario,...
        do_adaptation, do_rubble, ADAPT(1,1),ADAPT(1,2),ADAPT(1,3), NB_TIME_STEPS, i);
    
    OUTPUTS(i).RESULT = RESULT ;
    OUTPUTS(i).RECORD = RECORD ;
%     META = META;
    
end

%% FORMAT OUTPUTS
NB_REEFS = size(OUTPUTS(1).RESULT.coral_pct2D,1);

larval_supply = zeros(NB_SIMULATIONS,NB_REEFS,NB_TIME_STEPS+1,6);
nb_recruits = larval_supply ;
nb_juveniles = larval_supply ;
nb_adol_5cm = larval_supply ;
nb_adol = larval_supply;
nb_adult = larval_supply;
coral_cover = larval_supply;

% Juv = 0 to 4cm so include recruits (need to exclude them for comparison with Trapon et al 2103
% Need to add first two classes of adol (bin centres 0 and 20cm2) to get Juv <5cm 
for i = 1:NB_SIMULATIONS    
    larval_supply(i,:,:,:) = squeeze(cat(4,OUTPUTS(i).RESULT.coral_larval_supply));
    nb_recruits(i,:,:,:) = squeeze(cat(4,OUTPUTS(i).RESULT.coral_settler_count));
    nb_juveniles(i,:,:,:) = squeeze(sum(cat(4,OUTPUTS(i).RESULT.coral_juv_count(:,:,:,:)),4))-squeeze(nb_recruits(i,:,:,:));
    nb_adol_5cm(i,:,:,:) = squeeze(cat(4,OUTPUTS(i).RESULT.coral_adol_count(:,:,:,1)));
    nb_adol(i,:,:,:) = squeeze(sum(cat(4,OUTPUTS(i).RESULT.coral_adol_count(:,:,:,2:end)),4)); 
    nb_adult(i,:,:,:) = squeeze(sum(cat(4,OUTPUTS(i).RESULT.coral_adult_count(:,:,:,1:end)),4));   
    coral_cover(i,:,:,:) = squeeze(OUTPUTS(i).RESULT.coral_pct2D);
end

Tot_larval_input = squeeze(sum(larval_supply,4))/400;
Tot_recruits = squeeze(sum(nb_recruits,4))/400;
Tot_juv = squeeze(sum(nb_juveniles,4))/400; % (recruits excluded) 
Tot_nb_adol_5cm = squeeze(sum(nb_adol_5cm,4))/400; 
Tot_nb_adol = squeeze(sum(nb_adol,4))/400; 
Tot_nb_adult = squeeze(sum(nb_adult,4))/400; 
Tot_cover = squeeze(sum(coral_cover,4));

% hfig = figure;
% width=500; height=200; set(hfig,'color','w','units','points','position',[0,0,width,height])
% set(gcf, 'InvertHardcopy', 'off');
% 
% subplot(1,2,1)
% plot(Tot_cover(:),Tot_nb_adol(:),'o','Color',rgb('gray'))
% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color','White')
% xlabel('Total coral cover (%)','FontName', 'Arial' , 'FontSize', 12)
% ylabel('Adolescent density (m^{-2})','FontName', 'Arial' , 'FontSize', 12)
% 
% subplot(1,2,2)
% plot(Tot_cover(:),Tot_nb_adult(:),'o','Color',rgb('gray'))
% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color','White')
% xlabel('Total coral cover (%)','FontName', 'Arial' , 'FontSize', 12)
% ylabel('Adult density (m^{-2})','FontName', 'Arial' , 'FontSize', 12)
% axis([0 80 0 7])
% LM = fitlm(Tot_cover(:),Tot_nb_adult(:));
% hold on; plot([0:80],LM.Coefficients.Estimate(1,1)+LM.Coefficients.Estimate(2,1)*[0:80],'-k','LineWidth',2)
% text(10,6,['Y = 0.08 X - 0.04'],'FontName', 'Arial' , 'FontSize', 12)
% 
% print(hfig, ['-r' num2str(400)], ['Relationship_cover_colonies.png' ], ['-d' 'png']); 
% crop(['Relationship_cover_colonies.png'],0,10);
% close(hfig);

%% SAVE OUTPUTS
% save 'CALIBRATION_RECRUITMENT_NEW.mat'

%% PLOTS
years = (1:(NB_TIME_STEPS+1))/2 ;
load('Trapon_Juveniles.mat')
load('Emslie_Recovery.mat')

start_step = 10;
timeframe = years(start_step:2:(start_step+2*length(Emslierecovery.Year)-1));

FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;

hfig = figure;
width=1200; height=400; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off')
start=3
X = Tot_cover(:,[start:NB_TIME_STEPS+1]);
Y = Tot_juv(:,[start:NB_TIME_STEPS+1])+Tot_nb_adol_5cm(:,[start:NB_TIME_STEPS+1]);

subplot(1,2,1)
plot(X(:),Y(:),'.','Markersize',10,'Color',rgb('DarkGray'))
hold on ; plot(Traponjuveniles.CoralCover,Traponjuveniles.JuvDens, '.','Markersize',36,'Color',rgb('Black'))
axis([0 80 0 15]) ; yticks([0:3:18]); xticks([0:20:80])
xlabel('Total coral cover (%)','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
ylabel({'Juvenile density m^{-2}';''},'FontName', 'Arial', 'FontSize',FontSizeLabelAxes)

subplot(1,2,2)
plot(years,Tot_cover,'-','Color',rgb('DarkGray')); hold on
plot(timeframe,Emslierecovery.CB(1:length(timeframe)),'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)
plot(timeframe,Emslierecovery.CL(1:length(timeframe)),'o','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10)
axis([0 20 0 80]) ; yticks([0:20:80]); xticks([0:5:20])
xlabel('Years','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
ylabel('Total coral cover (%)','FontName', 'Arial', 'FontSize',FontSizeLabelAxes)


%% EXPORT DATA TO PLOT WITH R
% csvwrite('OUTPUT_TOT_COVER_new.csv',Tot_cover)
% csvwrite('OUTPUT_NB_JUV_new.csv',Tot_juv+Tot_nb_adol_5cm)
