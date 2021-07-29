function f_map_raster(map_MAINLAND,  filter, select, x_centre, y_centre, X, ...
    cctitle, fig_panel, MapTitle1, MapTitle2, MIN, MAX, RANGE, RANGE_lab)

% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('white')); set(gcf, 'InvertHardcopy', 'off');
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('LightBlue')); set(gcf, 'InvertHardcopy', 'off');

% Graphical parameters
% AxisLimits = [142.5315 154.1010 -24.4985 -10.6819]; % Whole region (3,806 reefs)
% AxisLimits = [144.4 153 -24.5 -13]; % Exclude far-north and extreme south
% AxisLimits = [142 145 -14 -10.6819]; % far-north
% AxisLimits = [145 149 -20 -14]; % 
AxisLimits = [142.5315 153.6 -25 -10.32]; % eReefs doesn't go beyond 142.2 (western limit)

TitleFontsize = 18 ; 
SubTitleFontsize = 14 ; 
TitleBarFontSize = 13 ; %16
LabelBarFontSize = 12 ; %14

% Mapping
% geoshow(map2,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on% plot map and specify color of area and boundary
geoshow(map_MAINLAND,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1],'LineWidth',0.1); hold on% plot map and specify color of area and boundary

G = NaN(600,180);
G(select) = X(select);
G(filter(1).out)=NaN; G(filter(2).out)=NaN; G(filter(3).out)=NaN; G(filter(4).out)=NaN;

contourf(x_centre, y_centre, G, 100, 'LineStyle', 'none');

% Set-up axes
axis(AxisLimits);
xticks([141:2:153])
yticks([-24:2:-10])

set(gca,'Yticklabel',{'','22°S','','18°S','','14°S','','10°S'}) 
set(gca,'Xticklabel',{'','143°E','','147°E','','151°E',''})

box on

% Set-up colorbar (LOG)
caxis([log(MIN+1) log(MAX+1)]);
cc = colorbar('West','YTick',log(RANGE+1),'YTickLabel',RANGE_lab, 'FontSize',LabelBarFontSize);

% Set-up colorbar
% caxis([MIN MAX]);
% cc = colorbar('West','YTick',RANGE,'YTickLabel',RANGE_lab, 'FontSize',LabelBarFontSize);

a = get(cc); set(cc, 'Position', [1.4*a.Position(1) 1.2*a.Position(2) a.Position(3)/2  a.Position(4)/3])

title(cc,cctitle,'FontName', 'Arial', 'FontWeight','normal','FontSize',TitleBarFontSize)

text(142, -9.7, fig_panel,'FontName', 'Arial','FontWeight','bold','FontSize', TitleFontsize, 'HorizontalAlignment','left')
text(149.5, -12.5, MapTitle1, 'FontName', 'Arial', 'FontWeight','bold','FontSize',TitleFontsize-2,'HorizontalAlignment','center')
text(149.5, -14, MapTitle2, 'FontName', 'Arial', 'FontWeight','normal','FontSize',SubTitleFontsize,'HorizontalAlignment','center')
