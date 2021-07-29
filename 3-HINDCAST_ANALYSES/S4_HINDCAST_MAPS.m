%__________________________________________________________________________
%
% PLOT OUTPUT MAPS
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear
SaveDir = ''

load('HINDCAST_METRICS.mat')
load('GBR_REEF_POLYGONS.mat')

%% MAPPING DATA
load('GBR_MAPS.mat')
map = map_MAINLAND;
map1 = shaperead('Great_Barrier_Reef_Features.shp','UseGeoCoords', true); % Map of entire QLD with reefs
map2 = shaperead('Great_Barrier_Reef_Marine_Park_Boundary.shp','UseGeoCoords', true); % Map of GBR Marine Park, just to get min and max of Lat and Lon
map3 = shaperead('Marine_Bioregions_of_the_Great_Barrier_Reef__Reef_.shp','UseGeoCoords', true); % Map of reefs without coastline
map7 = shaperead('Great_Barrier_Reef_Marine_Park_Zoning.shp','UseGeoCoords', true);

%% Build map of lands and separate reefs for Norhtern, Central and southern
id_Reef=~cellfun('isempty',strfind({map1.FEAT_NAME},'Reef'));
id_Cay=~cellfun('isempty',strfind({map1.FEAT_NAME},'Cay'));

map_reef = map1(id_Reef+id_Cay==1);

ALLNames = cell2table({map_reef(:).LABEL_ID}');
[B,I]=sortrows(ALLNames);
map_reef_new = map_reef(I);
CROSSNames = outerjoin(ALLNames, GBR_REEFS,'LeftKeys', [1],'RightKeys', [2], 'LeftVariables',[1], 'RightVariables',[10],'Type','left');
NorthReefs = find(CROSSNames.Sector==1|CROSSNames.Sector==2|CROSSNames.Sector==3);
CentreReefs = find(CROSSNames.Sector==4|CROSSNames.Sector==5|CROSSNames.Sector==6|CROSSNames.Sector==7|CROSSNames.Sector==8);
SouthReefs = find(CROSSNames.Sector==9|CROSSNames.Sector==10|CROSSNames.Sector==11);

id_Island=~cellfun('isempty',strfind({map1.FEAT_NAME},'Island'));
id_Rock=~cellfun('isempty',strfind({map1.FEAT_NAME},'Rock'));
id_Land=~cellfun('isempty',strfind({map1.FEAT_NAME},'Land'));
map_land = map1(id_Island + id_Rock + id_Land==1);

% Parms to export maps with
my.res = 400 ; %resolution
my.margins = 10 ;


%% Calculate mean absolute loss for each stressor across 40 replicates
MORT_ANNUAL_COTS = squeeze(mean(IND_MORT_ANNUAL_COTS,1));
MORT_ANNUAL_CYCLONES = squeeze(mean(IND_MORT_ANNUAL_CYCLONES,1));
MORT_ANNUAL_BLEACHING = squeeze(mean(IND_MORT_ANNUAL_BLEACHING,1));

%% Calculate mean annual mortality (proportional coral loss) for each stressor
REL_MORT_ANNUAL_COTS = squeeze(mean(IND_REL_MORT_ANNUAL_COTS,1));
REL_MORT_ANNUAL_CYCLONES = squeeze(mean(IND_REL_MORT_ANNUAL_CYCLONES,1));
REL_MORT_ANNUAL_BLEACHING = squeeze(mean(IND_REL_MORT_ANNUAL_BLEACHING,1));


%% FIGURE 8ABC: ALL MEAN ANNUAL MORTALITITES AS PROPORTIONAL LOSS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RANGE = 0:5:25 ; RANGE_lab = {' 0';' 5';'10';'15';'20';'25'} ;
MyPalette = flipud(makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]));
IMAGENAME = [SaveDir 'FIG_8ABC_HINDCAST_MAP_RLOSS'];
LabelColorBar = {'Annual';'proportional';'coral loss (%)'; ''};
PanelLabxy = [141.5 -10.3];
StressLabxy = [145 -24.2];

hfig = figure;
width=1200; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

subplot(1,3,1)
[hm1,cc1]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -mean(REL_MORT_ANNUAL_COTS(:,3:end),2), LabelColorBar, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.13; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'A','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
text(StressLabxy(1),StressLabxy(2), 'CoTS','FontName', 'Arial','FontWeight','bold','FontSize', 12, 'HorizontalAlignment','center')
f_mapping_towns(4,8)
cc1.Position = [pos(1)+0.16 0.48 cc1.Position(3:4)];

subplot(1,3,2)
[hm2,cc2]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -mean(REL_MORT_ANNUAL_CYCLONES,2), LabelColorBar, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.37; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
text(StressLabxy(1),StressLabxy(2), 'cyclones','FontName', 'Arial','FontWeight','bold','FontSize', 12, 'HorizontalAlignment','center')
f_mapping_towns(4,8)
cc2.Position = [pos(1)+0.16 0.48 cc2.Position(3:4)];

subplot(1,3,3)
[hm3,cc3]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -mean(REL_MORT_ANNUAL_BLEACHING,2), LabelColorBar, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.61; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
text(StressLabxy(1),StressLabxy(2), 'bleaching','FontName', 'Arial','FontWeight','bold','FontSize', 12, 'HorizontalAlignment','center')
f_mapping_towns(4,8)
cc3.Position = [pos(1)+0.16 0.48 cc3.Position(3:4)];

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);


%% FIGURE 7: IMPACTS OF BLEACHING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('GBR_past_DHW_CRW_5km_1985_2020.mat')
DHW = GBR_PAST_DHW(:,24:36);

%% 1/3) DHW maps (Fig 7A)
hfig = figure;
width=1200; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
RANGE = 0:2:14 ; RANGE_lab = {' 0';' 2';' 4';' 6';' 8';'10';'12';'14'} ;
MyPalette1 = flipud(hot);
IMAGENAME = [SaveDir 'FIG_7_BLEACHING_A'];
PanelLabxy = [141.5 -10.3];

subplot(1,3,1)
[hm1,cc1]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, DHW(:,9), {'2016'; 'DHW';'(°C-weeks)';''}, '', '',MyPalette1);
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.15;%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'A','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc1.Position = [pos(1)+0.165 pos(2)+0.36 cc1.Position(3:4)];

subplot(1,3,2)
[hm2,cc2]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, DHW(:,10), {'2017'; 'DHW';'(°C-weeks)';''}, '', '',MyPalette1);
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.15;%[x y width height] %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc2.Position = [pos(1)+0.165 pos(2)+0.36 cc2.Position(3:4)];

subplot(1,3,3)
[hm3,cc3]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, DHW(:,13), {'2020'; 'DHW';'(°C-weeks)';''}, '', '',MyPalette1);
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.15;%[x y width height]%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc3.Position = [pos(1)+0.165 pos(2)+0.36 cc3.Position(3:4)];

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);

%% 2/3) Absolue cover loss  (Fig 7B)
hfig = figure;
width=1200; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
RANGE = -50:10:0 ; RANGE_lab = {'-50';'-40';'-30';'-20';'-10';'  0'} ;
MyPalette = makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]);
IMAGENAME = [SaveDir 'FIG_7_BLEACHING_B'];
PanelLabxy = [141.5 -10.3];

subplot(1,3,1)
[hm1,cc1]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, MORT_ANNUAL_BLEACHING(:,9), {'2016 absolute';'coral loss';'(% cover)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.16; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc1.Position = [pos(1)+0.165 pos(2)+0.36 cc1.Position(3:4)];

subplot(1,3,2)
[hm2,cc2]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, MORT_ANNUAL_BLEACHING(:,10), {'2017 absolute';'coral loss';'(% cover)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.16; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc2.Position = [pos(1)+0.165 pos(2)+0.36 cc2.Position(3:4)];

subplot(1,3,3)
[hm3,cc3]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, MORT_ANNUAL_BLEACHING(:,13), {'2020 absolute';'coral loss';'(% cover)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.16; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc3.Position = [pos(1)+0.165 pos(2)+0.36 cc3.Position(3:4)];

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);


%% 3/3) Relative loss (mortality) (Fig 7C)
hfig = figure;
width=1200; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
RANGE = 0:20:100 ; RANGE_lab = {'  0';' 20';' 40';' 60';' 80';'100'} ;
MyPalette = flipud(makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]));
IMAGENAME = [SaveDir 'FIG_7_BLEACHING_C'];
PanelLabxy = [141.5 -10.3];

subplot(1,3,1)
[hm1,cc1]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -REL_MORT_ANNUAL_BLEACHING(:,9), {'2016 proportional';'coral loss';'(%)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.15; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc1.Position = [pos(1)+0.165 pos(2)+0.36 cc1.Position(3:4)];

subplot(1,3,2)
[hm2,cc2]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -REL_MORT_ANNUAL_BLEACHING(:,10), {'2017 proportional';'coral loss';'(%)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.15;%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc2.Position = [pos(1)+0.165 pos(2)+0.36 cc2.Position(3:4)];

subplot(1,3,3)
[hm3,cc3]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -REL_MORT_ANNUAL_BLEACHING(:,13), {'2020 proportional';'coral loss';'(%)'; ''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.15;%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
% text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc3.Position = [pos(1)+0.165 pos(2)+0.36 cc3.Position(3:4)];

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);


%% Calculate footprint of bleaching event
MortThreshold = -20;
Bl2016=REL_MORT_ANNUAL_BLEACHING(:,9);
Bl2017=REL_MORT_ANNUAL_BLEACHING(:,10);
Bl2020=REL_MORT_ANNUAL_BLEACHING(:,13);
Pct_impacted_2016 = 100*length(Bl2016(Bl2016<MortThreshold))/3806
Pct_impacted_2017 = 100*length(Bl2017(Bl2017<MortThreshold))/3806
Pct_impacted_2020 = 100*length(Bl2020(Bl2020<MortThreshold))/3806
Bl_all = REL_MORT_ANNUAL_BLEACHING(:,[9 10 13]);
Pct_escaped = zeros(size(Bl_all));
Pct_escaped(Bl_all<MortThreshold)=1;
count_escaped = sum(Pct_escaped,2);
100*length(count_escaped(count_escaped==0))/3806

%% Calculate footprint of cyclone events
MortThreshold = -20;
Cy_all=zeros(size(REL_MORT_ANNUAL_CYCLONES));
Cy_all(REL_MORT_ANNUAL_CYCLONES<MortThreshold)=1;
count_escaped = sum(Cy_all,2);
100*length(count_escaped(count_escaped==0))/3806


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIG 9: CUMULATIVE IMPACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hfig = figure;
width=1200; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
MyPalette = makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]);
IMAGENAME = [SaveDir 'FIG_10_CUMULATIVE_IMPACTS'];
PanelLabxy = [141.5 -10.3];

%% 1/3) PREDICTIVE MAP OF NET GROWTH (Fig 10A)
load('DRIVER_ANALYSIS/Predicted_Growth_from_R.mat') % Spatial prediction of net growth over 1 year (% cover, all corals) 
% This is an output of the glm in 'ANALYSIS_DRIVERS.R'

% I = 1;  RANGE = 0:0.3:1.2 ;  RANGE_lab = {' 0';'+0.3';'+0.6';'+0.9';' +1.2'} ; % from a 5% coral cover everywhere
I = 2; RANGE = 2:0.5:4 ;  RANGE_lab = {'+2.0';'+2.5';'+3.0';'+3.5';'+4.0';} ; % from a 10% coral cover everywhere

s1 = subplot(1,3,1);
[hm1,cc1]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, PREDICTED_GROWTH(:,I),{'Standardized';'coral growth';'(%cover.yr^{\fontsize{8}-1})';''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.13; pos(2) = 0.15; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'A','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
text(144.3, -24, {'suspended';'sediment'},'FontName', 'Arial','FontWeight','bold','FontSize', 10, 'HorizontalAlignment','center')
text(147, -24, {'larval';'connectivity'},'FontName', 'Arial','FontWeight','bold','FontSize', 10, 'HorizontalAlignment','center')

f_mapping_towns(4,8)
cc1.Position = [pos(1)+0.16 pos(2)+0.36 cc1.Position(3:4)];
colormap(s1, makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]))

%% 2/3) MAP OF CUMULATIVE MORTALITY (PROBABILISTIC)  (Fig 10B)
% Load the mean annual mortalities modelled from Nick's cyclones and 1998-2020 bleaching
% Modelling is in 'EXTRACT_MORTALITY_FOR_RESILIENCE.m' 
load('MEAN_MORTALITIES_FOR_R.mat') % NEEDS TO BE MULTIPLIED BY 2 TO GET ANNUAL MORTALITIES
MEAN_TOT_MORT_annual = -100 .* (1 - (1+MEAN_BLEACHING_MORT/100) .* (1+MEAN_COTS_MORT/100) .* (1+MEAN_CYCLONE_MORT/100));

RANGE = 0:5:25 ;  RANGE_lab = {' 0';' 5';'10';'15';'20';'25'} ;

s2 = subplot(1,3,2);
[hm2,cc2]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, -MEAN_TOT_MORT_annual, {'Proportional';'coral loss';'(%.yr^{\fontsize{8}-1})';''}, '', '',flipud(MyPalette));
pos = get(gca, 'Position'); pos(1) = 0.37; pos(2) = 0.15;%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc2.Position = [pos(1)+0.16 pos(2)+0.36 cc2.Position(3:4)];
colormap(s2, flipud(makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1])))

%% 3/3) MAP OF EQUILIBRIAL STATES  (Fig 10C)
load('DRIVER_ANALYSIS/ALL_EQUILIBRIA_FROM_R') % Output of simulations in 'ANALYSIS_RESILIENCE.R'

RANGE = 5:20:75 ;  RANGE_lab = {' 5';'25';'50';'75'} ;

s3 = subplot(1,3,3);
[hm3,cc3]= f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, EQUILIBRIA(:,end), {'Equilibrial';'coral cover';'(%)';''}, '', '',MyPalette);
pos = get(gca, 'Position'); pos(1) = 0.61; pos(2) = 0.15;%[x y width height]
set(gca, 'Position', pos,'Layer', 'top');
text(PanelLabxy(1),PanelLabxy(2), 'C','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')
f_mapping_towns(4,8)
cc3.Position = [pos(1)+0.16 pos(2)+0.36 cc3.Position(3:4)];
colormap(s3, makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]))

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);


GR_IN = PREDICTED_GROWTH(find(GBR_REEFS.KarloShelf==1),I); mean(GR_IN)
GR_MID = PREDICTED_GROWTH(find(GBR_REEFS.KarloShelf==2),I); mean(GR_MID)
GR_OUT = PREDICTED_GROWTH(find(GBR_REEFS.KarloShelf==3),I); mean(GR_OUT)

EQ_IN = EQUILIBRIA(find(GBR_REEFS.KarloShelf==1),end); median(EQ_IN)
EQ_MID = EQUILIBRIA(find(GBR_REEFS.KarloShelf==2),end); median(EQ_MID)
EQ_OUT = EQUILIBRIA(find(GBR_REEFS.KarloShelf==3),end); median(EQ_OUT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CURRENT STATE AND PERFORMANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TARGET_STEP = 27;
FINAL_YEAR = floor(years(TARGET_STEP));

%% MAP OF CORAL COVER IN 2020
X = Coral_tot.M(:,TARGET_STEP);

IMAGENAME = [SaveDir 'FIG_11A_MAP_CORAL_COVER' num2str(FINAL_YEAR)];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

RANGE = 0:10:40 ; RANGE_lab = {' 0';'10';'20';'30';'40'} ;
RANGE = 0:15:60 ; RANGE_lab = {' 0';'15';'30';'45';'60'} ;
MyPalette = makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]);

f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, X, {'Coral cover';'in 2020'; '(%)';''}, '', '',MyPalette)

f_mapping_towns(4,8)
text(142, -10, 'A','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);

% State of the reef in 2020
X = Coral_tot.M(:,TARGET_STEP);
critical=100*length(X(X<10))/length(X)
low=100*length(X(X>=10 & X<20))/length(X)
moderate=100*length(X(X>=20 & X<30))/length(X)
high=100*length(X(X>=30))/length(X)


% selectReefs = [select.North];
selectReefs = [select.Centre];
% selectReefs = [select.South];
% selectReefs = [select.Centre_MID ; select.Centre_OUT];

X = Coral_tot.M(selectReefs,TARGET_STEP);

critical=100*length(X(X<10))/length(X)
low=100*length(X(X>=10 & X<20))/length(X)
moderate=100*length(X(X>=20 & X<30))/length(X)
high=100*length(X(X>=30))/length(X)

Xmt = X - 7;
critical=100*length(Xmt(Xmt<10))/length(X)
low=100*length(Xmt(Xmt>=10 & Xmt<20))/length(X)
moderate=100*length(Xmt(Xmt>=20 & Xmt<30))/length(X)
high=100*length(Xmt(Xmt>=30))/length(X)

% State of the reef in 2020 excluding inshore
Y = Coral_tot.M(GBR_REEFS.KarloShelf~=1,TARGET_STEP);
critical=100*length(Y(Y<10))/length(Y)
low=100*length(Y(Y>=10 & Y<20))/length(Y)
moderate=100*length(Y(Y>=20 & Y<30))/length(Y)
high=100*length(Y(Y>=30))/length(Y)

Ymt = Y - 7;
critical=100*length(Ymt(Ymt<10))/length(Ymt)
low=100*length(Ymt(Ymt>=10 & Ymt<20))/length(Ymt)
moderate=100*length(Ymt(Ymt>=20 & Ymt<30))/length(Ymt)
high=100*length(Ymt(Ymt>=30))/length(Ymt)


%% MAP OF CURRENT REEF PERFORMANCE
IMAGENAME = [SaveDir 'FIG_11B_MAP_REEF_PERFORMANCE'];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

RANGE = [-60:10:10] ;  RANGE_lab = {'-60';'-50';'-40';'-30'; '-20';'-10';'  0'; '+10'} ;

f_map(map_MAINLAND, RANGE, RANGE_lab, GBR_REEFS.LON, GBR_REEFS.LAT, Coral_tot.M(:,TARGET_STEP)-EQUILIBRIA(:,end),...
    {'Coral performance';'in 2020';'(\Delta cover %)';''}, '', '',flipud(colormap(plasma())))
f_mapping_towns(4,8)
text(142, -10, 'B','FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','left')

%-- EXPORT --------------------
print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);
