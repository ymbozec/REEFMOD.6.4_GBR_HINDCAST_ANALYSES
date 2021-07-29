clear
load('GBR_ssc_middepth.mat')
load('EREEFS_physical.mat') %% Load bathymetry etc.
load('GBR_centroids.mat')
load('GBR_MAPS.mat')

SaveDir = '';

map1 = shaperead('Great_Barrier_Reef_Features.shp','UseGeoCoords', true);
map2 = shaperead('Great_Barrier_Reef_Marine_Park_Boundary.shp','UseGeoCoords', true);

id_Island=~cellfun('isempty',strfind({map1.FEAT_NAME},'Island'));
id_Rock=~cellfun('isempty',strfind({map1.FEAT_NAME},'Rock'));
id_Land=~cellfun('isempty',strfind({map1.FEAT_NAME},'Land'));
map_land = map1(id_Island + id_Rock + id_Land==1);
% geoshow(map_land,'FaceColor',0.8*[1 1 1],'EdgeColor',0.8*[1 1 1],'LineWidth',0.1); hold on % plot map and specify color of area and boundary

% Spatial filters
select = find(botz<=0 & botz>=-120);
filter(1).out = find(y_centre<-10 & y_centre>-16 & x_centre<154 & x_centre>146.5);
filter(2).out = find(y_centre<-14 & y_centre>-18 & x_centre<154 & x_centre>147.5);
filter(3).out = find(y_centre<-16 & y_centre>-20 & x_centre<154 & x_centre>151);
filter(4).out = find(y_centre<-20 & y_centre>-22 & x_centre<154 & x_centre>153.5);

Years = [2011:2018];
Nb_years = length(Years);

%% 1) MAP of SSC values (already converted into mg/L)
% SSC monthly averages (4-days) are in MIDDEPTH_SUMMER and MIDDEPTH_WINTER
% 600 x 180 x 6 months for each season
MIN = 0; MAX = 50;
RANGE = [0 10 50];
RANGE_lab = {' 0';'10'; '50'};

MEAN_SSC_SUMMER = NaN(600,180,Nb_years); % to store the annual maps of SSC
MEAN_SSC_WINTER = NaN(600,180,Nb_years); % to store the annual maps of SSC

my.res = 400 ; %resolution
my.margins = 10 ;
cctitle = {'SSC' ;'(mg/L)'; ''} ;

for k = 1:Nb_years
    
    %--- SUMMER FIGURE
    X = nanmean(MIDDEPTH_SUMMER(k).SSC,3); % mean over 6 months
    X(X<0.001)=0.001; %lower bound to avoid issues with logarithmic mean
    
    IMAGENAME = [SaveDir 'FIG_SSC_MIDDEPTH_SUMMER' num2str(Years(k))];
    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = '';
    MapTitle1 = 'Mid-depth sediments';
    MapTitle2 = ['Nov ' num2str(Years(k)-1) '- April ' num2str(Years(k))];
    f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X+1), cctitle, fig_panel,...
        MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    f_mapping_towns(4,8)

text(149, -19.9, MapTitle2, 'FontName', 'Arial', 'FontWeight','normal','FontSize',16,'HorizontalAlignment','center')

    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
    
    MEAN_SSC_SUMMER(:,:,k) = X ;
    
    %--- WINTER FIGURE
    X = nanmean(MIDDEPTH_WINTER(k).SSC,3); % mean over 6 months
    X(X<0.001)=0.001; %lower bound to avoid issues with logarithmic mean
    
    IMAGENAME = [SaveDir 'FIG_SSC_MIDDEPTH_WINTER' num2str(Years(k))];
    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = '';
    MapTitle1 = 'Mid-depth sediments';
    MapTitle2 = ['May - Oct ' num2str(Years(k))];
    f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X+1), cctitle, fig_panel,...
        MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    f_mapping_towns(4,8)  

text(149, -19.9, MapTitle2, 'FontName', 'Arial', 'FontWeight','normal','FontSize',16,'HorizontalAlignment','center')

    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
    
    MEAN_SSC_WINTER(:,:,k) = X ;
    
end

%% MAP of SSC avreages (already converted into mg/L)
%--- SUMMER SSC averaged over the 8 years (logarithmic averaging)%%
MIN = 0; MAX = 50;
RANGE = [0 10 50];
RANGE_lab = {' 0';'10'; '50'};
my.margins = 10 ;

X1 = prod(MEAN_SSC_SUMMER,3).^(1/size(MEAN_SSC_SUMMER,3));

cctitle = {'SSC' ;'(mg/L)'; ''} ;
IMAGENAME = [SaveDir 'FIG_SSC_MIDDEPTH_MEAN_SUMMER'];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
fig_panel = 'A';
MapTitle1 = {'Mid-depth (-6m)';'suspended sediments'};
MapTitle2 = 'Nov - Apr (2010-2018)';
f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X1+1), cctitle, fig_panel,...
    MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);

    
%--- WINTER SSC averaged over the 6 years %%
MIN = 0; MAX = 50;
RANGE = [0 10 50];
RANGE_lab = {' 0';'10'; '50'};
my.margins = 10 ;

X2 = prod(MEAN_SSC_WINTER,3).^(1/size(MEAN_SSC_WINTER,3));

cctitle = {'SSC' ;'(mg/L)'; ''} ;
IMAGENAME = [SaveDir 'FIG_SSC_MIDDEPTH_MEAN_WINTER'];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
fig_panel = 'B';
MapTitle1 = {'Mid-depth (-6m)';'suspended sediments'};
MapTitle2 = 'May - Oct (2011-2018)';
f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X2+1), cctitle, fig_panel,...
    MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);


%--- ANNUAL SSC averaged over the 6 years %%
X = (X1.*X2).^(1/2);
cctitle = {'SSC' ;'(mg/L)'; ''} ;
IMAGENAME = [SaveDir 'FIG_SSC_MIDDEPTH_MEAN_ANNUAL'];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
fig_panel = '';
MapTitle1 = 'Mid-depth sediments';
MapTitle2 = '(2010-2018)';
f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X+1), cctitle, fig_panel,...
    MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);



%% 2) Map of Post-settlement survival (potential) - only from Summer SSC
load('GBR_RECRUIT_SURVIVAL.mat')
my.res = 400 ; %resolution
my.margins = 10 ;

MIN = 60;
MAX = 100;
RANGE = [MIN:10:MAX];
RANGE_lab = {' 60';' 70';' 80';' 90';'100'};
cctitle = {'Coral recruit' ; 'survival potential (%)';''} ;
MyPalette = hot ;

for k=1:Nb_years
    
    Y = REEF_RECRUIT_SURVIVAL(:,k);
    [x,o]=sort(Y,'descend');

    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = ['Nov ' num2str(Years(k)-1) '- April ' num2str(Years(k))];
    IMAGENAME = [SaveDir 'FIG_RECRUIT_SURVIVAL_' num2str(Years(k))];
    f_map_reefs(map_MAINLAND, centr(o,:), 100*Y(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    f_mapping_towns(4,8)
    
    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
end

    
% Averaged over the 6 years %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y = prod(REEF_RECRUIT_SURVIVAL,2).^(1/size(REEF_RECRUIT_SURVIVAL,2));

hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
my.margins = 0;
fig_panel = {''};
cctitle = {'Coral recruit' ; 'survival potential (%)';''} ;

IMAGENAME = [SaveDir 'FIG_RECRUIT_SURVIVAL_MEAN'];
f_map_reefs(map_MAINLAND, centr(o,:), 100*Y(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);

%% 3) Map of Post-settlement growth (potential)
load('GBR_JUV_GROWTH.mat')
my.res = 400 ; %resolution
my.margins = 10 ;

MIN = 40;
MAX = 100;
RANGE = [MIN:20:MAX];
RANGE_lab = {' 40';' 60';' 80';'100'};
cctitle = {'Coral juvenile' ; 'growth potential (%)' ;''} ;
MyPalette = hot ;

for k=1:Nb_years
    
    % Summer growth %%%%%%%%%%%
    Z = REEF_JUV_GROWTH_SUMMER(:,k);
    [x,o]=sort(Z,'descend');

    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = ['Nov ' num2str(Years(k)-1) '- April ' num2str(Years(k))];
    IMAGENAME = [SaveDir 'FIG_JUV_GROWTH_SUMMER_' num2str(Years(k))];
    f_map_reefs(map_MAINLAND, centr(o,:), 100*Z(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    f_mapping_towns(4,8)
    
    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
    
    % Winter growth %%%%%%%%%%%
    Z = REEF_JUV_GROWTH_WINTER(:,k);
    [x,o]=sort(Z,'descend');

    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = ['May - Oct ' num2str(Years(k))];
    IMAGENAME = [SaveDir 'FIG_JUV_GROWTH_WINTER_' num2str(Years(k))];
    f_map_reefs(map_MAINLAND, centr(o,:), 100*Z(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    f_mapping_towns(4,8)
    
    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
    
end

% Averaged over all years %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z = ( (prod(REEF_JUV_GROWTH_SUMMER,2).^(1/size(REEF_JUV_GROWTH_SUMMER,2))).*(prod(REEF_JUV_GROWTH_WINTER,2).^(1/size(REEF_JUV_GROWTH_WINTER,2))) ).^0.5;
[x,o]=sort(Z,'descend');

hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
my.margins = 0;
fig_panel = {''};
cctitle = {'Coral juvenile' ; 'growth potential (%)';''} ;

IMAGENAME = [SaveDir 'FIG_JUV_GROWTH_MEAN'];
f_map_reefs(map_MAINLAND, centr(o,:), 100*Z(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);
