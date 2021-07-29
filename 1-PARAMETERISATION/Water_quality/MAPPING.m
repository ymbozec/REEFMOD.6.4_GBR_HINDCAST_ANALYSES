clear
load('GBR_ssc_surface.mat')
load('GBR_dispersal.mat')
load('EREEFS_physical.mat') %% Load bathymetry etc.
load('GBR_centroids.mat')
load('GBR_sectors.mat')
load('GBR_MAPS.mat')

% SaveDir = '/home/ym/Desktop/';
SaveDir = '';

map1 = shaperead('Marine_Bioregions_of_the_Great_Barrier_Reef__Reef_.shp','UseGeoCoords', true);
map2 = shaperead('Great_Barrier_Reef_Marine_Park_Boundary.shp','UseGeoCoords', true);
map3 = shaperead('Great_Barrier_Reef_Features.shp','UseGeoCoords', true);

% Map of coastline + reefs
figure
gbrmap = geoshow(map3,'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]); hold on% plot map and specify color of area and boundary
f_mapping_towns(3)

% With map of marine park boundary
figure
gbrmap = geoshow(map2,'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]); hold on% plot map and specify color of area and boundary
f_mapping_towns(3)

% With map of reefs
figure
gbrmap = geoshow(map1,'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]); hold on% plot map and specify color of area and boundary


%% Plot reef contours for export
% REEF_LAT1 = cat(3,map1.BoundingBox);
% REEF_LAT2a = squeeze(REEF_LAT1(1,2,:));
% REEF_LAT2b = squeeze(REEF_LAT1(2,2,:));
% REEF_LAT = (REEF_LAT2a+REEF_LAT2b)/2;
% ---- reef contours
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');

geoshow(map1,'FaceColor',rgb('LightBlue'),'EdgeColor',rgb('LightBlue')); hold on% plot map and specify color of area and boundary
% axis([min(map2.Lon) max(map2.Lon)+0.1 min(map2.Lat) max(map2.Lat)]);
% 
% xticks([143:2:153])
% yticks([-24:2:-12])
% set(gca,'Yticklabel',{'','22°S','','18°S','','14°S',''}) 
% set(gca,'Xticklabel',{'143°E','','147°E','','151°E',''})

% geoshow(map3,'FaceColor',rgb('LightBlue'),'EdgeColor',rgb('LightBlue')); hold on% plot map and specify color of area and boundary
% geoshow(map_MAINLAND,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on % plot map and specify color of area and boundary
axis([142 154 -24.8 -10.2]); 

xticks([142:2:154])
yticks([-24:2:-12])
set(gca,'Yticklabel',{'','22°S','','18°S','','14°S',''}) 
set(gca,'Xticklabel',{'142°E','','146°E','','150°E','','154°E'})

box on

% plot2svg

% ---- coastline
hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');

geoshow(map_MAINLAND,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on% plot map and specify color of area and boundary
f_mapping_towns(3)

% axis([min(map2.Lon) max(map2.Lon)+0.1 min(map2.Lat) max(map2.Lat)]);
axis([142 154 -24.8 -10.2]); 

% xticks([143:2:153])
% yticks([-24:2:-12])
% set(gca,'Yticklabel',{'','','','','','',''}) 
% set(gca,'Xticklabel',{'1','','147°E','','151°E',''})
axis off
box off

print(hfig, ['-r' num2str(400)], ['Coastline2.png' ], ['-d' 'png']); 
% crop(['Coastline2.png'],0,0);

close(hfig);





%% Map the sectors for the 3806 reefs
% (REPLICATES OF THE CODE IN a4_ANALYSIS_SURFACE.m (ACRS 2018)
x_reef = centr(:,2);
y_reef = centr(:,1);

hfig = figure;
size_marker = 3;
gbrmap = geoshow(map3,'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8]); hold on% plot map and specify color of area and boundary
addpoints = geoshow(x_reef(sectors==1),y_reef(sectors==1), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('DodgerBlue'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
addpoints = geoshow(x_reef(sectors==2),y_reef(sectors==2), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('Orange'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
addpoints = geoshow(x_reef(sectors==3),y_reef(sectors==3), 'DisplayType', 'Point', 'Marker', 'o', 'MarkerFaceColor', rgb('ForestGreen'),'MarkerEdgeColor', 'none','MarkerSize',size_marker); % add point locations
f_mapping_towns(3)
axis([142 154 -24.6 -10.1])
set(gca,'Layer', 'top');

IMAGENAME = [SaveDir 'FIG_GBR_sectors'];
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);
crop([IMAGENAME '.png']);

close(hfig);
