function f_plot_export(hfig,SaveName)

FontSize = 10;
FontName = 'Arial'; 
% % FontName = 'MyriadPro-Regular';
% 
% % figure dimensions in cm
% figure_width = 14;  
% figure_height = 10;
% set(hfig, 'units', 'centimeters', 'pos', [5 5 figure_width figure_height])
% 
% % setup axis plot properties
% % shading interp; % interpolate pixels
% % shading flat; % do not interpolate pixels
% % axis on;
% % axis off;
% % set properties for all handles
% set(gca, 'FontSize', FontSize, 'FontName', FontName);
% 
% % bring axis on top again (fix matlab bug)
% set(gca,'Layer', 'top');

% export
% drawnow
SaveDir = '';
% SaveName = 'TEMP';
 
IMAGENAME = [SaveDir SaveName]; 
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png']);    
crop([IMAGENAME '.png']);

close(hfig);