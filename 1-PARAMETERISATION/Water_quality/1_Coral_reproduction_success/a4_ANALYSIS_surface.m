clear
load('GBR_ssc_surface.mat') %in kg/m-3
load('GBR_dispersal.mat')
load('EREEFS_physical.mat') %% Load bathymetry etc.
load('GBR_centroids.mat')
load('GBR_sectors.mat')
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

Years = [2011 2012 2013 2014 2015 2016];
Nb_years = length(Years);

%% 1) MAP of SSC values
% SSC averages (4-days) are in S(k).SSC
% 600 x 180 x 3 sector x 3 spawn with NaN when no spawning
MIN = 0; MAX = 5;
RANGE = [0 1 2 3 4 5];
RANGE_lab = {'0';'1'; '2'; '3'; '4'; '5'};

MEAN_SSC = NaN(600,180,6); % to store the annual maps of SSC (averaged across spawning events)

my.res = 400 ; %resolution
my.margins = 10 ;
cctitle = {'SSC' ;'(mg/L)'; ''} ;

for k = 1:Nb_years
    
    X = (1e6/1000)*nanmean(nanmean(S(k).SSC,4),3); % average across spawning events then across sector
    X(X<0.001)=0.001; %lower bound to avoid issues with logarithmic mean
 
%     IMAGENAME = [SaveDir 'FIG_SSC_SURFACE_NEW' num2str(Years(k))];
%     hfig = figure;
%     width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
%     set(hfig, 'Resize', 'off')
%     fig_panel = '';
%     MapTitle1 = 'Near-surface sediments';
%     MapTitle2 = ['spawning season ' num2str(Years(k))];
%     f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X+1), cctitle, fig_panel,...
%         MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
%     geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
%     
%     print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
%     crop([IMAGENAME '.png'],0,my.margins); close(hfig);
 
    MEAN_SSC(:,:,k) = X ;
    
end

% Averaged over the 6 years %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X = nanmean(MEAN_SSC,3); % Global average
X = (MEAN_SSC(:,:,1).*MEAN_SSC(:,:,2).*MEAN_SSC(:,:,3).*MEAN_SSC(:,:,4).*MEAN_SSC(:,:,5).*MEAN_SSC(:,:,6)).^(1/6);
cctitle = {'SSC' ;'(mg/L)'; ''} ;
IMAGENAME = [SaveDir 'FIG_SSC_SURFACE_NEW_MEAN'];
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
fig_panel = '';
MapTitle1 = {'Near-surface';'suspended sediments'};
MapTitle2 = {'Coral spawning seasons'; '2011-2016'};
f_map_raster(map_MAINLAND, filter, select, x_centre, y_centre, log(X+1), cctitle, fig_panel,...
    MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);

%% 2) Map of reproduction success (potential)
my.res = 400 ; %resolution
my.margins = 10 ;

MIN = 50;
MAX = 100;
RANGE = [MIN:10:MAX];
RANGE_lab = {' 50';' 60';' 70';' 80';' 90'; '100'};
MyPalette = hot;
cctitle = {'Coral reproduction' ;'potential (%)';''} ;

MEAN_POTENT_SEED = NaN(size(POTENT_SEED,1),6); % to store the annual maps of POTENTIAL SEEDING (averaged across spawning events)
    
for k=1:Nb_years
    
    Y = 100*nanmean(squeeze(POTENT_SEED(:,:,k)),2);
    [x,o]=sort(Y,'descend');
    
    hfig = figure;
    width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    fig_panel = ['Coral spawning ' num2str(Years(k))];
    IMAGENAME = [SaveDir 'FIG_REPRO_' num2str(Years(k))];
    f_map_reefs(map_MAINLAND, centr(o,:), Y(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
    geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
    
    f_mapping_towns(4,8)
    
    print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,my.margins); close(hfig);
   
    MEAN_POTENT_SEED(:,k) = 100*nanmean(squeeze(POTENT_SEED(:,:,k)),2);
    
end

% Averaged over the 6 years %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y = (MEAN_POTENT_SEED(:,1).* MEAN_POTENT_SEED(:,2).* MEAN_POTENT_SEED(:,3).* MEAN_POTENT_SEED(:,4).* MEAN_POTENT_SEED(:,5).* MEAN_POTENT_SEED(:,6)).^(1/6);
[x,o]=sort(Y,'descend');
MIN = 60;
MAX = 100;
RANGE = [MIN:10:MAX];
RANGE_lab = {' 60';' 70';' 80';' 90'; '100'};

hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
my.margins = 0;
fig_panel = {''};
cctitle = {'Coral reproduction' ;'potential (%)';''} ;

IMAGENAME = [SaveDir 'FIG_REPRO_MEAN'];
f_map_reefs(map_MAINLAND, centr(o,:), Y(o), cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)
geoshow(map_land,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary
f_mapping_towns(4,8)

print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); close(hfig);



%% Calculate frequencies for the whole GBR %%%%%%%%%%%%%
bins = [0.5:0.01:1];
select_bin = 26; % 11 for 60% success and below; 21 for 70% and below; 26 for 75% and below
freqs = hist(mean(Y,2),bins);
100*sum(freqs(1:select_bin))/3806

%% Calculate frequencies per GBR sector %%%%%%%%%%%%%
load('GBR_sectors.mat')
count_reefs = ones(size(sectors));
for s = 1:3
    freq_sector = hist(mean(Y(sectors==s,:),2),bins);
    100*sum(freq_sector(1:select_bin))/sum(count_reefs(sectors==s))
end

%% Calculate frequencies per GBR sector per year %%%%%%%%%%%%%
system_stats = zeros(3,length(Years));
for k=1:length(Years)    
    for s = 1:3
        freq_sector = hist(Y(sectors==s,k),bins);
        system_stats(s,k)=100*sum(freq_sector(1:select_bin))/sum(count_reefs(sectors==s));
    end
end


%% TEST: compare with a SSC averaged over 3 months
% RANGE = [0:20:100];
% figure
% for k=1:5
%     subplot(1,5,k)
% %     hfig = figure;
% %     set(hfig, 'Color', [1 1 1]); % Sets figure background
% %     gbrmap = geoshow(map2,'FaceColor',[.5 .5 .5],'EdgeColor',[.5 .5 .5]); hold on% plot map and specify color of area and boundary
% 
%     scatter(centr(:,1),centr(:,2),10,100*POTENT_SEED_3M(:,k),'filled')
%     colorbar('WestOutside','FontName', 'Arial', 'FontWeight','bold','FontSize',16,'YTick',RANGE,'YTickLabel',RANGE);    
%     caxis([20 100])
%     f_mapping_towns(3)
%     axis([142 154 -24.6 -10.1])
%     
%     text(146.5, -15.5, num2str(Years(k)), 'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
% %     IMAGENAME = [SaveDir 'FIG_REPRO_' num2str(Years(k))];
% %     print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
% %     crop([IMAGENAME '.png']);
% %         
% %     close(hfig);   
% end


%% 4) Map the sectors for the 3806 reefs
% x_reef = centr(:,2);
% y_reef = centr(:,1);
% 
% hfig = figure;
% size_marker = 3;
% gbrmap = geoshow(map3,'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]); hold on% plot map and specify color of area and boundary
% addpoints = geoshow(x_reef(sectors==1),y_reef(sectors==1), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('DodgerBlue'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
% addpoints = geoshow(x_reef(sectors==2),y_reef(sectors==2), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('Orange'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
% addpoints = geoshow(x_reef(sectors==3),y_reef(sectors==3), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('ForestGreen'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
% f_mapping_towns(3)
% axis([142 154 -24.6 -10.1])
% set(gca,'Layer', 'top');
% 
% IMAGENAME = [SaveDir 'FIG_GBR_sectors'];
% print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
% crop([IMAGENAME '.png']);
% 
% close(hfig);

%% 5) Map the dispersal success(supply)
% MIN = 50;
% MAX = 100;
% RANGE = [MIN:10:MAX];
% 
% for k=1:5
% %     subplot(1,5,k)
%     hfig = figure;
%     set(hfig, 'Color', [1 1 1]); % Sets figure background
%     gbrmap = geoshow(map2,'FaceColor',greyscale*[1 1 1],'EdgeColor',greyscale*[1 1 1]); hold on% plot map and specify color of area and boundary
% 
%     scatter(centr(:,1),centr(:,2),10,100*POTENT_DISPERSAL(:,k),'filled')
%     colorbar('WestOutside','FontName', 'Arial', 'FontWeight','bold','FontSize',16,'YTick',RANGE,'YTickLabel',RANGE);    
%     caxis([MIN MAX])
%     f_mapping_towns(3)
%     axis([142 154 -24.6 -10.1])
%     
%     text(146.5, -15.5, num2str(Years(k)), 'FontName', 'Arial', 'FontWeight','bold','FontSize',12)
%     IMAGENAME = [SaveDir 'FIG_DISPERSAL' num2str(Years(k))];
%     print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
%     crop([IMAGENAME '.png']);
%         
%     close(hfig);   
% end

%% 6) Map the overall mean DISPERSAL SUCCESS
% MIN = 50;
% MAX = 100;
% RANGE = [MIN:50:MAX];
% 
% hfig = figure;
% gbrmap = geoshow(map2,'FaceColor',greyscale*[1 1 1],'EdgeColor',greyscale*[1 1 1]); hold on% plot map and specify color of area and boundary
% scatter(centr(:,1),centr(:,2),10,100*nanmean(POTENT_DISPERSAL,2),'filled')
% colorbar('NorthOutside','FontName', 'Arial', 'FontWeight','bold','FontSize',6,'YTick',RANGE,'YTickLabel',RANGE);    
% axis([142 154 -24.6 -10.1])
% caxis([MIN MAX])
% f_mapping_towns(3)
% 
% set(gca, 'FontSize', 6, 'FontName', 'Arial');
% 
% IMAGENAME = [SaveDir 'FIG_DISPERSAL_MEAN'];
% print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
% crop([IMAGENAME '.png']);
% 
% close(hfig);   

%% Calculate frequencies for the whole GBR %%%%%%%%%%%%%
% bins = [0.5:0.01:1];
% select_bin = 26; % 11 for 60% success and below; 21 for 70% and below; 26 for 75% and below
% freqs = hist(mean(POTENT_DISPERSAL,2),bins);
% disp('GBR wide')
% 100*sum(freqs(1:select_bin))/3806
% 
% % Calculate frequencies per GBR sector %%%%%%%%%%%%%
% count_reefs = ones(size(sectors));
% disp('Per sector')
% for s = 1:3
%     Z=POTENT_DISPERSAL(sectors==s,:);
%     freq_sector = hist(Z(:),bins);
%     100*sum(freq_sector(1:select_bin))/(5*sum(count_reefs(sectors==s)))
% end


%% Calculate frequencies per GBR sector per year %%%%%%%%%%%%%
% system_stats = zeros(4,length(Years));
% disp('Per sector per year')
% for k=1:length(Years) 
%     freqs = hist(POTENT_DISPERSAL(:,k),bins);
%     system_stats(1,k)=100*sum(freqs(1:select_bin))/3806;
%     for s = 1:3
%         freq_sector = hist(POTENT_DISPERSAL(sectors==s,k),bins);
%         system_stats(s+1,k)=100*sum(freq_sector(1:select_bin))/sum(count_reefs(sectors==s));
%     end
% end


%% 5) For connectivity network figure
% map2 = shaperead('Great_Barrier_Reef_Marine_Park_Boundary.shp','UseGeoCoords', true);
% gbrmap = geoshow(map2,'FaceColor',[.94 .94 .94],'EdgeColor',[.94 .94 .94]); hold on% plot map and specify color of area and boundary
% IMAGENAME = [SaveDir 'FIG_PARK_BOUNDARIES_'];
% hfig=figure(1)
% print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
% crop([IMAGENAME '.png']);
% close(hfig)
