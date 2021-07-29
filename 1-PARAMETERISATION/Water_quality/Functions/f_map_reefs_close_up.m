function f_map_reefs_close_up(map2, map_MAINLAND, centr, Y, cctitle, fig_panel, MIN, MAX, RANGE, RANGE_lab, IMAGENAME, MyPalette)

hfig = figure;
width=400; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'off');
% set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 8, 'color',rgb('LightSkyBlue')); set(gcf, 'InvertHardcopy', 'off');

% geoshow(map2,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on% plot map and specify color of area and boundary
geoshow(map2,'FaceColor',rgb('LightBlue'),'EdgeColor',rgb('LightBlue')); hold on% plot map and specify color of area and boundary
geoshow(map_MAINLAND,'FaceColor',0.7*[1 1 1],'EdgeColor',0.7*[1 1 1]); hold on% plot map and specify color of area and boundary

colormap(MyPalette)
% colormap(hot)
% colormap(flipud(hot)) % from white to red-black
% colormap(makeColorMap([1 0 0] , [1 1 0] , [0 0.5 0.1]));

scatter(centr(:,1),centr(:,2), 10, Y,'filled')

% caxis([MIN MAX]);
% cc = colorbar('West','FontName', 'Arial', 'FontSize', 14, 'FontWeight','normal','YTick',RANGE,'YTickLabel',RANGE_lab);

caxis([log(MIN+1) log(MAX+1)]);
cc = colorbar('West','FontName', 'Arial', 'FontSize', 14, 'FontWeight','normal','YTick',log(RANGE+1),'YTickLabel',RANGE_lab);

a = get(cc); set(cc, 'Position', [4.5*a.Position(1) 1.9*a.Position(2) a.Position(3)/2  a.Position(4)/2.7]) % [left bottom width height]
title(cc, cctitle, 'FontName', 'Arial', 'FontWeight','normal','FontSize', 16)
text((min(map2.Lon)+max(map2.Lon))/2, max(map2.Lat)+0.5, fig_panel,'FontName', 'Arial','FontWeight','bold','FontSize', 18, 'HorizontalAlignment','center')

axis([min(map2.Lon) max(map2.Lon)+0.1 min(map2.Lat) max(map2.Lat)]);

set(gca,'Yticklabel',[]) 
set(gca,'Xticklabel',[])

box on

print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']); 
crop([IMAGENAME '.png'],0,0);

close(hfig);
