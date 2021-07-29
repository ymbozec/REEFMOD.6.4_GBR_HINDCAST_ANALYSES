%__________________________________________________________________________
%
% PLOT REEF TRAJECTORIES + MEAN TRAJECTORIES PER SPECIES
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear
SaveDir = ''

load('HINDCAST_METRICS.mat')
load('GBR_REEF_POLYGONS.mat')

%% Load AIMS LTMP observations for the whole GBR
StartDate = 2006;

load('AIMS_LTMP_Transect_sites.mat')
select_TR = find(LTMP_Transect_sites.YEAR_Reefmod>=StartDate);
AIMS_TR = LTMP_Transect_sites(select_TR,[19 20 3 18 11]); %19: REEF_ID, 20: SectorCode, 3: shelf (AIMS), 11: cover tot, 18: YEAR_Reefmod
AIMS_TR.Properties.VariableNames = {'KarloID','SECTOR','SHELF','YEAR','CCOVER'};

% Corrections of wrong year assignements (when start of a season falls between two surveys of the same campaign)
AIMS_TR.YEAR(AIMS_TR.KarloID==805 & AIMS_TR.YEAR==2011)=2011.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==845 & AIMS_TR.YEAR==2006)=2006.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==930 & AIMS_TR.YEAR==2010.5)=2011;
AIMS_TR.YEAR(AIMS_TR.KarloID==944 & AIMS_TR.YEAR==2007.5)=2008;
AIMS_TR.YEAR(AIMS_TR.KarloID==944 & AIMS_TR.YEAR==2014.5)=2015;
AIMS_TR.YEAR(AIMS_TR.KarloID==1478 & AIMS_TR.YEAR==2014)=2014.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==1756 & AIMS_TR.YEAR==2014)=2014.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==1332 & AIMS_TR.YEAR==2009)=2008.5;

% Rename shelf position
AIMS_TR.SHELF2(AIMS_TR.SHELF=='I')=1;
AIMS_TR.SHELF2(AIMS_TR.SHELF=='M')=2;
AIMS_TR.SHELF2(AIMS_TR.SHELF=='O')=3;
AIMS_TR = AIMS_TR(:,[1 2 6 4 5]); 

% Average across sites
AIMS_TR2 = varfun(@mean, AIMS_TR, 'GroupingVariables',{'KarloID','SECTOR','SHELF2', 'YEAR'},'InputVariables','CCOVER');

AIMS_TR = AIMS_TR2(:,[1,2,3,4,6]);
AIMS_TR.Properties.VariableNames = {'KarloID','SECTOR','AIMS_SHELF','CCOVER','YEAR'};

%% MANTA TOW DATA (up to 2020)
load('AIMS_MantaTow_1985_2020.mat')
select_MT = find(MantaTow_1985_2020.YearReefMod>=StartDate);
AIMS_MT = MantaTow_1985_2020(select_MT,[16 3 8 10]); % select AIMS shelf classification
AIMS_MT.AIMS_SHELF(char(AIMS_MT.SHELF)=='I')=1;
AIMS_MT.AIMS_SHELF(char(AIMS_MT.SHELF)=='M')=2;
AIMS_MT.AIMS_SHELF(char(AIMS_MT.SHELF)=='O')=3;

% convert Manta tows into transect equivalent
load('LTMP_Transect2Tow_NEW.mat')
AIMS_MT.MEAN_LIVE_CORAL_EQ = predict(LTMP_Transect2Tow_Model,AIMS_MT.MEAN_LIVE_CORAL);

AIMS_MT.SECTOR = GBR_REEFS.Sector(AIMS_MT.KarloID);
AIMS_MT = AIMS_MT(:,[1 7 5 6 3]);
AIMS_MT.Properties.VariableNames = {'KarloID','SECTOR','AIMS_SHELF','CCOVER','YEAR'};

AIMS_ALL = [AIMS_MT ; AIMS_TR];
omean = @(x) mean(x,'omitnan');

%% Graphic parameters
FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;

DotSize = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot mean trajectoires for each region (Northern, Central, Southern)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename= 'FIG_4A_NEW_HINDCAST_TRAJECTORIES_PER_REGION' ;

hfig = figure;
width=1000; height=200; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

%-- GBR
subplot(1,4,1) ; TitleReefSelection = {'GBR'};
f_plot_reef_trajectory(select.GBR, years, Coral_tot.M, area_w, [], [],[], TitleReefSelection,'')
ylabel({'Coral cover (%)'},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
pos = get(gca, 'Position'); pos(1) = 0.13; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
htext = annotation('textbox', [0.095 1 0 0], 'String', 'A', 'FitBoxToText', 'off','FontName', 'Arial','FontWeight','bold','FontSize', 16);

%-- NORTHERN
subplot(1,4,2) ; TitleReefSelection = {'North'};
select_OBS = find(AIMS_ALL.SECTOR>=1 & AIMS_ALL.SECTOR<4);
f_plot_reef_trajectory(select.North, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.31; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
% AIMSmean = table2array(varfun(omean, AIMS_ALL(select_OBS,:),'GroupingVariables',{'YEAR'},'InputVariables',{'CCOVER'}));
% plot(AIMSmean(:,1),AIMSmean(:,3),'-','Color','k') % add manta tow surveys (already scaled to transect equivalent)

%-- CENTRAL
subplot(1,4,3) ; TitleReefSelection = {'Center'};
select_OBS = find(AIMS_ALL.SECTOR>=4 & AIMS_ALL.SECTOR<9);
f_plot_reef_trajectory(select.Centre, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.49; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
% AIMSmean = table2array(varfun(omean, AIMS_ALL(select_OBS,:),'GroupingVariables',{'YEAR'},'InputVariables',{'CCOVER'}));
% plot(AIMSmean(:,1),AIMSmean(:,3),'-','Color','k') % add manta tow surveys (already scaled to transect equivalent)

%-- SOUTHERN
subplot(1,4,4) ; TitleReefSelection = {'South'};
select_OBS = find(AIMS_ALL.SECTOR>=9);
f_plot_reef_trajectory(select.South, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.67; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
% AIMSmean = table2array(varfun(omean, AIMS_ALL(select_OBS,:),'GroupingVariables',{'YEAR'},'InputVariables',{'CCOVER'}));
% plot(AIMSmean(:,1),AIMSmean(:,3),'-','Color','k') % add manta tow surveys (already scaled to transect equivalent)

%-- EXPORT --------------------
IMAGENAME = [SaveDir filename];
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20); close(hfig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot mean trajectoires for shelf position in each region (Northern, Central, Southern)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename= 'FIG_S15_NEW_HINDCAST_TRAJECTORIES_PER_SHELF-REGION' ; 

hfig = figure;
width=1000; height=800; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

%-- NORTHERN
subplot(3,3,1) ; TitleReefSelection = {'North inshore'};
select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==1 & GBR_REEFS.LAT<lat_cutoff);
select_OBS = find(AIMS_ALL.SECTOR>=1 & AIMS_ALL.SECTOR<4 & AIMS_ALL.AIMS_SHELF==1);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
ylabel({'Coral cover (%)';''},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.75;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,2) ; TitleReefSelection = {'North mid-shelf'};
select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==2 & GBR_REEFS.LAT<lat_cutoff);
select_OBS = find(AIMS_ALL.SECTOR>=1 & AIMS_ALL.SECTOR<4 & AIMS_ALL.AIMS_SHELF==2);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.75;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,3) ; TitleReefSelection = {'North outer shelf'};
select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==3 & GBR_REEFS.LAT<lat_cutoff);
select_OBS = find(AIMS_ALL.SECTOR>=1 & AIMS_ALL.SECTOR<4 & AIMS_ALL.AIMS_SHELF==3);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.75;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

%-- CENTRAL
subplot(3,3,4) ; TitleReefSelection = {'Center inshore'};
select_reefs = find(GBR_REEFS.KarloShelf==1&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
select_OBS = find(AIMS_ALL.SECTOR>=4 & AIMS_ALL.SECTOR<9 & AIMS_ALL.AIMS_SHELF==1);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
ylabel({'Coral cover (%)';''},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.49;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,5) ; TitleReefSelection = {'Center mid-shelf'};
select_reefs = find(GBR_REEFS.KarloShelf==2&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
select_OBS = find(AIMS_ALL.SECTOR>=4 & AIMS_ALL.SECTOR<9 & AIMS_ALL.AIMS_SHELF==2);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.49;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,6) ; TitleReefSelection = {'Center outer shelf'};
select_reefs = find(GBR_REEFS.KarloShelf==3&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
select_OBS = find(AIMS_ALL.SECTOR>=4 & AIMS_ALL.SECTOR<9 & AIMS_ALL.AIMS_SHELF==3);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.49;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

%-- SOUTHERN
subplot(3,3,7) ; TitleReefSelection = {'South inshore'};
select_reefs = find(GBR_REEFS.KarloShelf==1&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
select_OBS = find(AIMS_ALL.SECTOR>=9 & AIMS_ALL.AIMS_SHELF==1);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
ylabel({'Coral cover (%)';''},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.23;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,8) ; TitleReefSelection = {'South mid-shelf'};
select_reefs = find(GBR_REEFS.KarloShelf==2&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
select_OBS = find(AIMS_ALL.SECTOR>=9 & AIMS_ALL.AIMS_SHELF==2);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.23;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

subplot(3,3,9) ; TitleReefSelection = {'South outer shelf'};
select_reefs = find(GBR_REEFS.KarloShelf==3&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
select_OBS = find(AIMS_ALL.SECTOR>=9 & AIMS_ALL.AIMS_SHELF==3);
f_plot_reef_trajectory(select_reefs, years, Coral_tot.M, area_w, [], [], [],TitleReefSelection,'')
plot(AIMS_ALL.YEAR(select_OBS),AIMS_ALL.CCOVER(select_OBS),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.23;  %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
N = ['(n = ' num2str(length(select_reefs)) ')'];
text(2019,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')


%-- EXPORT --------------------
IMAGENAME = [SaveDir filename];
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20); close(hfig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Plot trajectoires per species
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
subplot(2,3,1); plot(years,Coral_sp(1).M,'k-','LineWidth',1, 'Color', rgb('OrangeRed')); axis([2007 2020 0 60]);
subplot(2,3,2); plot(years,Coral_sp(2).M,'k-','LineWidth',1, 'Color', rgb('DarkOrange'));axis([2007 2020 0 60]);
subplot(2,3,3); plot(years,Coral_sp(3).M,'k-','LineWidth',1, 'Color', rgb('Gold'));axis([2007 2020 0 60]);
subplot(2,3,4); plot(years,Coral_sp(4).M,'k-','LineWidth',1, 'Color', rgb('ForestGreen'));axis([2007 2020 0 60]);
subplot(2,3,5); plot(years,Coral_sp(5).M,'k-','LineWidth',1, 'Color', rgb('Magenta'));axis([2007 2020 0 60]);
subplot(2,3,6); plot(years,Coral_sp(6).M,'k-','LineWidth',1, 'Color', rgb('DodgerBlue'));axis([2007 2020 0 60]);

select_steps = 3:2:27;
list_reefs = GBR_REEFS.KarloID;
list_shelf = GBR_REEFS.KarloShelf;
list_region = nan(length(list_reefs),1);
list_region(select.North)=1;
list_region(select.Centre)=2;
list_region(select.South)=3;

list_years = years(select_steps)-0.5;
X0 = repmat(list_reefs, length(list_years),1);
X = X0(:);
Y0 = repmat(list_years, length(list_reefs),1);
Y = Y0(:);
S0 = repmat(list_shelf, length(list_years),1);
S = S0(:);
R0 = repmat(list_region, length(list_years),1);
R = R0(:);

Z1 = Coral_sp(1).M(:,select_steps);
Z2 = Coral_sp(2).M(:,select_steps);
Z3 = Coral_sp(3).M(:,select_steps);
Z4 = Coral_sp(4).M(:,select_steps);
Z5 = Coral_sp(5).M(:,select_steps);
Z6 = Coral_sp(6).M(:,select_steps);

figure
plot(list_years, mean(Z1,1)); hold on
plot(list_years, mean(Z2,1));
plot(list_years, mean(Z3,1));
plot(list_years, mean(Z4,1));
plot(list_years, mean(Z5,1));
plot(list_years, mean(Z6,1));

%% EXPORT REEF TRAJECTORIES PER SPECIES FOR COMMUNITY COMPO ANALYSIS (using R)
COVER_SP = [ Z1(:) Z2(:) Z3(:) Z4(:) Z5(:) Z6(:) ];

COVER_TOT = sum(COVER_SP,2);
COMM_COMPO = COVER_SP./COVER_TOT(:,ones(1,6));
COMM_COMPO(isnan(COMM_COMPO)==1)=0;

EXPORT = array2table([ X Y S R COMM_COMPO ],'VariableNames',{'ReefID','Year','Shelf', 'Region','SP1','SP2','SP3','SP4','SP5','SP6'});
writetable(EXPORT,'DATA_COMPO_ANALYSIS.csv')

EXPORT = array2table([ X Y S R COVER_SP ],'VariableNames',{'ReefID','Year','Shelf', 'Region','SP1','SP2','SP3','SP4','SP5','SP6'});
writetable(EXPORT,'DATA_COVER_ANALYSIS.csv')