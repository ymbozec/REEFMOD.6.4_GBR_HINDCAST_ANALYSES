function [hmap,cc]=f_map(map, RANGE, RANGE_lab, LON, LAT, X, cctitle, MapTitle1, MapTitle2, MyPalette)

% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 8, 'color',rgb('white')); set(gcf, 'InvertHardcopy', 'off');
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 9, 'color',rgb('LightSkyBlue')); set(gcf, 'InvertHardcopy', 'off');
% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 9, 'color',rgb('LightBlue')); set(gcf, 'InvertHardcopy', 'off');

% Graphical parameters
% AxisLimits = [142 154 -24.8 -10.2]; 
% AxisLimits = [142.1942 153.1491 -24.6428 -10.3526]; % Exacts LON LAT limits of the 3,806 reefs
% AxisLimits = [142.5315 154.1010 -24.4985 -10.6819]; % Whole region of the
% GBRMPA shapefile Marine_Bioregions_of_the_Great_Barrier_Reef__Reef_.shp
% AxisLimits = [144.4 153 -24.5 -13]; % Exclude far-north and extreme south
% AxisLimits = [136 162 -28 -6]; % Whole region (3,806 reefs)
AxisLimits = [142.5315 153.6 -25 -10.32]; % FINAL CHOICE FOR THE PAPER - eReefs doesn't go beyond 142.2 (western limit)

% AxisLimits = [151.2 152.9 -22.7 -21.2 ]; % SWAINS

DotSize = 6 ;
TitleFontsize = 18 ; 
SubTitleFontsize = 16 ; 
TitleBarFontSize = 13 ; %14
LabelBarFontSize = 12 ;

% Mapping
hmap=geoshow(map,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on % plot map and specify color of area and boundary
scatter(LON,LAT, DotSize, X,'filled') ;

colormap(MyPalette);

% Set-up axes
axis(AxisLimits);
xticks([141:2:153])
yticks([-24:2:-10])
caxis([min(RANGE) max(RANGE)])

% Remove axis labels
% set(gca,'Yticklabel',[]) 
% set(gca,'Xticklabel',[])

% Or impose the following ones
set(gca,'Yticklabel',{'','22°S','','18°S','','14°S','','10°S'}) 
set(gca,'Xticklabel',{'','143°E','','147°E','','151°E',''})

set(gca,'Yticklabel',{'','','','','','','',''}) 
set(gca,'Xticklabel',{'','','','','','',''})

box on

%%% Set-up colorbar %%%%%%%%%
cc = colorbar('West','YTick',RANGE,'YTickLabel',RANGE_lab, 'FontSize',LabelBarFontSize);

% LOG SCALE
% caxis([log(MIN+1) log(MAX+1)]);
% cc = colorbar('West','FontName', 'Arial', 'FontSize', 14, 'FontWeight','normal','YTick',log(RANGE+1),'YTickLabel',RANGE_lab);

% [left bottom width height]
a = get(cc); set(cc, 'Position', [4.5*a.Position(1) 2.5*a.Position(2) a.Position(3)/2  a.Position(4)/2.7])
% a = get(cc); set(cc, 'Position', [2.5*a.Position(1) 2.2*a.Position(2) a.Position(3)/2  a.Position(4)/2.7])

title(cc,cctitle,'FontName', 'Arial', 'FontWeight','normal','FontSize',TitleBarFontSize)

text(148, -11, MapTitle1, 'FontName', 'Arial', 'FontWeight','bold','FontSize',TitleFontsize,'HorizontalAlignment','center')
text(148, -14.2, MapTitle2, 'FontName', 'Arial', 'FontWeight','bold','FontSize',SubTitleFontsize,'HorizontalAlignment','center')
% text(145, -23.7, 'Bozec et al. (in prep.)', 'FontName', 'Arial', 'FontWeight','normal','FontSize',10, 'HorizontalAlignment','left')


