function f_plot_map(shapefile,X)

colormap(parula)
% colormap(magma)

%         hfig1 = pcolor(x_centre,y_centre,0*tmp+1); set(hfig1,'EdgeColor','none'); hold on

        hfig2 = pcolor(x_centre,y_centre,G); shading flat; axis equal; 
%         hcb=colorbar('NorthOutside'); title(hcb,TITLE)
        f_mapping_towns(3)
        caxis([MIN MAX])
%         axis(All_sections)
        axis([142 154 -24.6 -10.1])
        set(gca,'color','none')