%__________________________________________________________________________
%
% CALCULATE AND PLOT ANNUAL CHANGES
% 
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

SaveDir = ''

load('HINDCAST_METRICS.mat')
load('GBR_REEF_POLYGONS.mat')

%% Graphic parameters
FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) ABSOLUTE cover losses (mortality as cover) for each stressor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxY = 0;
minY = -26;

minX = 0.2;
maxX = 13.8;

x_positions = [1:4:13]; x_labels = {'2008', '2012', '2016', '2020'};

filename= ['FIG_4B_ABSOLUTE_LOSSES'] ; 
hfig = figure;
width=1000; height=150; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

Ylabel = {'Cover loss (%)'};

subplot(1,4,1)
h=bar([MEAN_ANNUAL_MORT.Co_GBR' ; MEAN_ANNUAL_MORT.Cy_GBR' ; MEAN_ANNUAL_MORT.Bl_GBR']','stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
pos = get(gca, 'Position'); pos(1) = 0.13; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
xlim([minX maxX])
ylim([minY maxY])
xticks(x_positions)
xticklabels(x_labels)
ylabel(Ylabel,'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
% title({'GBR'},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelTitles)

% text(0.5, 2.3, 'B','FontName', 'Arial','FontWeight','bold','FontSize', 16, 'HorizontalAlignment','left')
% text(-3.5, 1, 'B','FontName', 'Arial','FontWeight','bold','FontSize', 16, 'HorizontalAlignment','left')
htext = annotation('textbox', [0.095 1 0 0], 'String', 'B', 'FitBoxToText', 'off','FontName', 'Arial','FontWeight','bold','FontSize', 16);

hLegend = legend(h([1 2 3]),{'CoTS';'Cyclones';'Bleaching'},'Location','southwest','FontName', 'Arial','FontSize',FontSizeLabelTicks);
hLegend.ItemTokenSize = [5 5];
hLegend.Box='off';

subplot(1,4,2)
h=bar([MEAN_ANNUAL_MORT.Co_NORTH' ; MEAN_ANNUAL_MORT.Cy_NORTH' ; MEAN_ANNUAL_MORT.Bl_NORTH']','stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
pos = get(gca, 'Position'); pos(1) = 0.31; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
xlim([minX maxX])
ylim([minY maxY])
xticks(x_positions)
xticklabels(x_labels)
% ylabel(Ylabel,'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
% title({'North'},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelTitles)

subplot(1,4,3)
h=bar([MEAN_ANNUAL_MORT.Co_CENTER' ; MEAN_ANNUAL_MORT.Cy_CENTER' ; MEAN_ANNUAL_MORT.Bl_CENTER']','stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
pos = get(gca, 'Position'); pos(1) = 0.49; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
xlim([minX maxX])
ylim([minY maxY])
xticks(x_positions)
xticklabels(x_labels)
% ylabel(Ylabel,'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
% title({'Center'},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelTitles)

subplot(1,4,4)
h=bar([MEAN_ANNUAL_MORT.Co_SOUTH' ; MEAN_ANNUAL_MORT.Cy_SOUTH' ; MEAN_ANNUAL_MORT.Bl_SOUTH']','stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
pos = get(gca, 'Position'); pos(1) = 0.67; %[x y width height]
set(gca, 'Position', pos,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
xlim([minX maxX])
ylim([minY maxY])
xticks(x_positions)
xticklabels(x_labels)
% ylabel(Ylabel,'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
% title({'South'},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelTitles)

IMAGENAME = [SaveDir filename];
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20); close(hfig);


%% MEAN ANNUAL RELATIVE LOSSES PER REGION AND SHELF POSITION (FIGURE 7D)
REL_MORT_ANNUAL_COTS = squeeze(mean(IND_REL_MORT_ANNUAL_COTS,1));
REL_MORT_ANNUAL_CYCLONES = squeeze(mean(IND_REL_MORT_ANNUAL_CYCLONES,1));
REL_MORT_ANNUAL_BLEACHING = squeeze(mean(IND_REL_MORT_ANNUAL_BLEACHING,1));

ID_shelf = [1 2 3];
select_tmp(1,1).REEFS = [select.GBR_IN] ; select_tmp(1,2).REEFS = [select.GBR_MID] ; select_tmp(1,3).REEFS = [select.GBR_OUT]; select_tmp(1,4).REEFS = [select.GBR];
select_tmp(2,1).REEFS = [select.North_IN] ; select_tmp(2,2).REEFS = [select.North_MID] ; select_tmp(2,3).REEFS = [select.North_OUT]; select_tmp(2,4).REEFS = [select.North];
select_tmp(3,1).REEFS = [select.Centre_IN] ; select_tmp(3,2).REEFS = [select.Centre_MID] ; select_tmp(3,3).REEFS = [select.Centre_OUT]; select_tmp(3,4).REEFS = [select.Centre];
select_tmp(4,1).REEFS = [select.South_IN] ; select_tmp(4,2).REEFS = [select.South_MID] ; select_tmp(4,3).REEFS = [select.South_OUT]; select_tmp(4,4).REEFS = [select.South];

ALLS(1).MEAN = [];
for i=1:4 % for 1:GBR, 2:North, 3:Center, 4:South
    
    rB_in = weighted_mean(-REL_MORT_ANNUAL_BLEACHING,area_w,select_tmp(i,1).REEFS);
    rB_ms = weighted_mean(-REL_MORT_ANNUAL_BLEACHING,area_w,select_tmp(i,2).REEFS);
    rB_os = weighted_mean(-REL_MORT_ANNUAL_BLEACHING,area_w,select_tmp(i,3).REEFS);
    rB_cs = weighted_mean(-REL_MORT_ANNUAL_BLEACHING,area_w,select_tmp(i,4).REEFS);
    
    rS_in = weighted_mean(-REL_MORT_ANNUAL_CYCLONES,area_w,select_tmp(i,1).REEFS);
    rS_ms = weighted_mean(-REL_MORT_ANNUAL_CYCLONES,area_w,select_tmp(i,2).REEFS);
    rS_os = weighted_mean(-REL_MORT_ANNUAL_CYCLONES,area_w,select_tmp(i,3).REEFS);
    rS_cs = weighted_mean(-REL_MORT_ANNUAL_CYCLONES,area_w,select_tmp(i,4).REEFS);
    
    rC_in = weighted_mean(-REL_MORT_ANNUAL_COTS,area_w,select_tmp(i,1).REEFS);
    rC_ms = weighted_mean(-REL_MORT_ANNUAL_COTS,area_w,select_tmp(i,2).REEFS);
    rC_os = weighted_mean(-REL_MORT_ANNUAL_COTS,area_w,select_tmp(i,3).REEFS);
    rC_cs = weighted_mean(-REL_MORT_ANNUAL_COTS,area_w,select_tmp(i,4).REEFS);
    
    ALLS(i).MEAN = [mean(rB_cs) mean(rS_cs) mean(rC_cs) ; mean(rB_in) mean(rS_in) mean(rC_in) ; ...
                      mean(rB_ms)  mean(rS_ms) mean(rC_ms); mean(rB_os)  mean(rS_os) mean(rC_os)];
    
end


filename= ['FIG_8D_RELATIVE_LOSSES_SHELF-REGION'] ; 
hfig = figure;
width=160; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
% set(hfig, 'Resize', 'off')

subplot(5,1,2) % GBR
h=barh(flipud(fliplr(ALLS(1).MEAN)),'stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on %Bleaching
set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
yticks([1 2 3 4])
yticklabels({'Outer','Mid', 'Inner', 'Cross-shelf'})
axis([0 23 0.5 4.5])
xlabel({''},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelAxes)
htitle = title({'GBR'},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelTitles)
htitle.HorizontalAlignment = 'left';
htitle.Position = [0 4.5990 0];

lgd = legend({'CoTS';'Cyclones';'Bleaching'}');
lgd.ItemTokenSize = [5 5];
legend('boxoff')
set(lgd,'Units', 'points')
myOldLegendPos=get(lgd,'Position');
hold on
h=subplot(5,1,1)
text(-0.15, -0.4, 'D','FontName', 'Arial','FontWeight','bold','FontSize', 21, 'HorizontalAlignment','left')
set(h,'Units', 'points')
myPosition=get(h,'Position');
% set(lgd,'Position',[myPosition(1)+25 myPosition(2)-40 myOldLegendPos(3)/3 myOldLegendPos(4)/5])
set(lgd,'Position',[myPosition(1)+100 myPosition(2)-40 myOldLegendPos(3)/3 myOldLegendPos(4)/5])
set(h,'Visible', 'off')

subplot(5,1,3) % North
h=barh(flipud(fliplr(ALLS(2).MEAN)),'stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
yticks([1 2 3 4])
yticklabels({'Outer','Mid', 'Inner', 'Cross-shelf'})
axis([0 23 0.5 4.5])
xlabel({''},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelAxes)
htitle = title({'North'},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelTitles)
htitle.HorizontalAlignment = 'left';
htitle.Position = [0 4.5990 0];

subplot(5,1,4)
h=barh(flipud(fliplr(ALLS(3).MEAN)),'stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
yticks([1 2 3 4])
yticklabels({'Outer','Mid', 'Inner', 'Cross-shelf'})
axis([0 23 0.5 4.5])
% legend({'CoTS';'Cyclones';'Bleaching'})
xlabel({''},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelAxes)
htitle = title({'Center'},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelTitles)
htitle.HorizontalAlignment = 'left';
htitle.Position = [0 4.5990 0];

subplot(5,1,5)
h=barh(flipud(fliplr(ALLS(4).MEAN)),'stacked'); 
set(h(1),'FaceColor',rgb('Peru')); hold on % COTS
set(h(2),'FaceColor',rgb('DarkKhaki')); hold on % Storms
set(h(3),'FaceColor',rgb('ForestGreen')); hold on % Bleaching
set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
yticks([1 2 3 4])
yticklabels({'Outer','Mid', 'Inner', 'Cross-shelf'})
axis([0 23 0.5 4.5])
% legend({'CoTS';'Cyclones';'Bleaching'})
xlabel({'Proportional coral loss (%)';''},'FontName', 'Arial', 'FontSize',FontSizeLabelAxes)
htitle = title({'South'},'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelTitles);
htitle.HorizontalAlignment = 'left';
htitle.Position = [0 4.5990 0];

IMAGENAME = [SaveDir filename];
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20); close(hfig);
