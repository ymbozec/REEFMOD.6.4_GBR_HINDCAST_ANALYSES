function f_map_reefs(map_MAINLAND, centr, Y, cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)

% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('LightBlue')); set(gcf, 'InvertHardcopy', 'off');
% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 9, 'color',rgb('LightSkyBlue')); set(gcf, 'InvertHardcopy', 'off');

% Graphical parameters
% AxisLimits = [142 154 -24.8 -10.2]; 
% AxisLimits = [142.1 153.6 -25 -10.32];
AxisLimits = [142.5315 153.6 -25 -10.32]; % eReefs doesn't go beyond 142.2 (western limit)

DotSize = 6 ;
TitleFontsize = 18 ; 
SubTitleFontsize = 16 ; 
TitleBarFontSize = 16; %13 ; %16
LabelBarFontSize = 14; %12 ; %14

% Mapping
% geoshow(map2,'FaceColor',rgb('LightBlue'),'EdgeColor',rgb('LightBlue')); hold on% plot map and specify color of area and boundary
geoshow(map_MAINLAND,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on% plot map and specify color of area and boundary

colormap(MyPalette)

% Set-up axes
axis(AxisLimits);
xticks([141:2:153])
yticks([-24:2:-10])
caxis([min(RANGE) max(RANGE)])
scatter(centr(:,1),centr(:,2), DotSize, Y,'filled')

% set(gca,'Yticklabel',{'','22°S','','18°S','','14°S','','10°S'}) 
% set(gca,'Xticklabel',{'','143°E','','147°E','','151°E',''})

set(gca,'Yticklabel',{'','','','','','','',''}) 
set(gca,'Xticklabel',{'','','','','','',''})

box on

%%% Set-up colorbar %%%%%%%%%
cc = colorbar('West','FontName', 'Arial', 'FontSize', LabelBarFontSize, 'FontWeight','normal','YTick',RANGE,'YTickLabel',RANGE_lab);

% LOG SCALE
caxis([log(MIN+1) log(MAX+1)]);
cc = colorbar('West','FontName', 'Arial', 'FontSize', LabelBarFontSize, 'FontWeight','normal','YTick',log(RANGE+1),'YTickLabel',RANGE_lab);

a = get(cc); set(cc, 'Position', [4.25*a.Position(1) 2.52*a.Position(2) a.Position(3)/2  a.Position(4)/2.7])
% a = get(cc); set(cc, 'Position', [4.5*a.Position(1) 1.9*a.Position(2) a.Position(3)/2  a.Position(4)/2.7]) % [left bottom width height]
title(cc, cctitle, 'FontName', 'Arial', 'FontWeight','normal','FontSize', TitleBarFontSize)

% text((min(map2.Lon)+max(map2.Lon))/2, max(map2.Lat)+0.5, fig_panel,'FontName', 'Arial','FontWeight','bold','FontSize', TitleFontsize, 'HorizontalAlignment','center')
text((142+154)/2, -9.7, fig_panel,'FontName', 'Arial','FontWeight','bold','FontSize', TitleFontsize, 'HorizontalAlignment','center')

% axis([min(map2.Lon) max(map2.Lon)+0.1 min(map2.Lat) max(map2.Lat)]);
% xticks([143:2:153])
% yticks([-24:2:-12])
% set(gca,'Yticklabel',{'','22°S','','18°S','','14°S',''}) 
% set(gca,'Xticklabel',{'143°E','','147°E','','151°E',''})
