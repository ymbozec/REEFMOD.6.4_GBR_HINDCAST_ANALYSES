%__________________________________________________________________________
%
% PLOT DEMO METHOD FOR CALCULATING PREDICTION AND OBSERVATION ERRORS
% (APPENDIX S1 FIGURE S2)
% 
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________


hfig = figure;
width=1200; height=400; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')


minX = -40;
maxX = 40;
hh = tight_subplot(1,4,0.03,0.25,0.15);

axes(hh(1)) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxY = 75;
offset = 0.5;
rectangle('Position',[2009 offset 2020.5-0.1-2009 maxY-(offset*2)],'FaceColor',rgb('PaleTurquoise'),'EdgeColor',rgb('PapayaWhip'))
hold on

plot(years,traject_all,'-','Color',rgb('SlateGray'))
plot(years,traject_mean,'-' ,'Color', rgb('Crimson'),'LineWidth',2)
line([2007.5 2007.5], [0 85],'LineStyle','--')

plot(M_tmp.YEAR,M_tmp.CC_OBS,'+','Color',rgb('black'))
% plot(M_tmp.YEAR,M_tmp.CC_OBS_MEAN,'o','MarkerSize',8,'LineWidth',1,'MarkerFaceColor',rgb('white'),'MarkerEdgeColor',rgb('black'))
select_reefID = find(AIMS_ALL_mean.KarloID==SELECTION_REEF.KarloID(reef));
plot(AIMS_ALL_mean.YEAR(select_reefID),AIMS_ALL_mean.mean_CCOVER(select_reefID),'o','MarkerSize',8,'LineWidth',1,'MarkerFaceColor',rgb('white'),'MarkerEdgeColor',rgb('black'))

% set(gca,'FontName', 'Arial' ,'FontSize',8);
set(gca,'FontName', 'Arial' ,'FontSize',8, 'Xtick', 2005:3:2020, 'XTickLabel',2005:3:2020, 'Ytick',0:10:70, 'YTickLabel',0:10:70);

ylabel('Total coral cover (%)','FontName','Arial','FontSize',12)
title(GBR_REEFS.ReefName(SELECTION_REEF.KarloID(reef)),'FontName','Arial','FontSize',12)
axis([2004.5 2020.5 0 maxY])

box on

axes(hh(2)) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z1 = M_tmp.CC_OBS-M_tmp.CC_OBS_MEAN;
histogram(M_tmp.CC_OBS-M_tmp.CC_OBS_MEAN,[-60:5:60],'FaceColor',rgb('white'))
set(gca,'FontName', 'Arial' ,'FontSize',8);
xlabel('$x_{i,t} - \mu_{t}$','Interpreter','Latex','FontName','Arial','FontSize',16)
ylabel('Frequency','FontName','Arial','FontSize',12)
title(['Observation errors (n = ' num2str(length(Z1)) ')'],'FontName','Arial','FontSize',12)

xlim([minX maxX])

axes(hh(3)) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z2 = M_tmp.CC_PRED-M_tmp.CC_OBS_MEAN;
histogram(Z2,[-60:5:60],'FaceColor',rgb('Crimson'),'FaceAlpha',1)
set(gca,'FontName', 'Arial' ,'FontSize',8);
title(['Prediction errors (n = ' num2str(length(Z2)) ')'],'FontName','Arial','FontSize',12)
xlabel('$y_{j,t} - \mu_{t}$','Interpreter','Latex','FontName','Arial','FontSize',16)
ylabel('Frequency','FontName','Arial','FontSize',12)
xlim([minX maxX])

axes(hh(4)) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
line([prctile(Z1,lo_pct) prctile(Z1,hi_pct)], [1 1], 'Color', rgb('black'),'LineWidth',2); hold on
plot([prctile(Z1,lo_pct) prctile(Z1,hi_pct)], [1 1], 'o','MarkerFaceColor',rgb('black'),'MarkerEdgeColor',rgb('black'))
line([prctile(Z2,lo_pct) prctile(Z2,hi_pct)], 0.1+[1 1], 'Color', rgb('Crimson'),'LineWidth',2); hold on
plot([prctile(Z2,lo_pct) prctile(Z2,hi_pct)], 0.1+[1 1], 'o','MarkerFaceColor',rgb('Crimson'),'MarkerEdgeColor',rgb('Crimson'))

line([0 0] , [0 2], 'LineStyle', '--')
plot(mean(Z2), 0.1+[1 1], 'o','MarkerFaceColor','white','MarkerEdgeColor',rgb('Crimson'))

axis([-60 60 0.6 1.5])
set(gca,'FontName', 'Arial' ,'FontSize',8);
title([num2str(lo_pct) '^{th} - ' num2str(hi_pct) '^{th} percentiles'],'FontName','Arial','FontSize',12)
xlabel({'$y_{j,t} - \mu_{t}$'; '$x_{i,t} - \mu_{t}$'},'Interpreter','Latex','FontName','Arial','FontSize',16)

yticks([])
% yticklabels([]);
xlim([minX maxX])
xticklabels([-40:20:40])
box on

% IMAGENAME = ['METHOD_DEMO_ONE_REEF_' num2str(region) '-' num2str(shelf) '-' num2str(n)];
reefname = GBR_REEFS.ReefName(SELECTION_REEF.KarloID(reef));
IMAGENAME = ['METHOD_DEMO_ONE_REEF_' char(reefname) ];

print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20);
close(hfig);