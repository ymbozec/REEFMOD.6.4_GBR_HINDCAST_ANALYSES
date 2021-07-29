%__________________________________________________________________________
%
% SENSITIVITY ANALYSIS (FIGURE 6)
% 
% Requires the estimated deviances (prediction and observation errors) for
% each hindcast scenario
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 05/2021
%__________________________________________________________________________

clear

load('DEVIANCES_ALL_STRESSORS.mat')
M = MYDATA;

load('DEVIANCES_NO_CYCLONES.mat')
M.CC_PRED1 = MYDATA.CC_PRED;

load('DEVIANCES_NO_BLEACHING.mat')
M.CC_PRED2 = MYDATA.CC_PRED;

load('DEVIANCES_NO_COTS.mat')
M.CC_PRED3 = MYDATA.CC_PRED;

load('DEVIANCES_NO_WQ.mat')
M.CC_PRED4 = MYDATA.CC_PRED;

lo_pct = 10;
hi_pct = 90;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DEVIANCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

regionlabel={'Northern' ; 'Central' ; 'Southern'};
shelflabel = {'Inshore';'Mid-shelf';'Outer-shelf'};

offset = 0.25;
K = 6;
Xmin = -60;
Xmax = 60;

ColorPred4 = rgb('Yellowgreen');
ColorPred3 = rgb('DarkSlateBlue');
ColorPred2 = rgb('DarkOrange');
ColorPred1 = rgb('LightSkyBlue');
ColorPred = rgb('Crimson');
ColorObs = rgb('DarkSlateGrey');

TitleFontSize = 12;
LabelFontSize = 8;
AxisFontSize = 6;

lwidth = 1;

hfig = figure;
width=700; height=600; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')
hh = tight_subplot(3,3,[0.025 0.01],0.2,0.13); % [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)

DotSize =4;
count = 0;

for region=1:3
    
    for shelf=1:3
        
        count = count+1;
        axes(hh(count));
        
        myselect = find(M.AIMS_SHELF==shelf & M.REGION==region);
        
        DEV_OBS_lo = prctile(M.CC_OBS(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_OBS_hi = prctile(M.CC_OBS(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        DEV_MOD_lo = prctile(M.CC_PRED(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_MOD_hi = prctile(M.CC_PRED(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        DEV_MOD1_lo = prctile(M.CC_PRED1(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_MOD1_hi = prctile(M.CC_PRED1(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        DEV_MOD2_lo = prctile(M.CC_PRED2(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_MOD2_hi = prctile(M.CC_PRED2(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        DEV_MOD3_lo = prctile(M.CC_PRED3(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_MOD3_hi = prctile(M.CC_PRED3(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        DEV_MOD4_lo = prctile(M.CC_PRED4(myselect) - M.CC_OBS_MEAN(myselect),lo_pct);
        DEV_MOD4_hi = prctile(M.CC_PRED4(myselect) - M.CC_OBS_MEAN(myselect),hi_pct);
        
        plot([],[]); hold on
        rectangle('Position',[Xmin+0.5 4.25 Xmax-Xmin-1 2], 'FaceColor', rgb('Gainsboro'),'EdgeColor','none')
        axis([Xmin Xmax 0 0+K+1.5])
        set(gca, 'FontName','Arial', 'FontSize',AxisFontSize)

        line([0 0] , [0 0+K+offset], 'LineStyle', '--','Color','k','LineWidth',1)
        yticklabels([]); yticks([]);
        nb_reefs = length(unique(M.REEF_ID(myselect)));
        text(0, 6.75, ['n = ' num2str(nb_reefs) ' reefs'],'FontName','Arial', 'FontSize',AxisFontSize+1,'HorizontalAlignment', 'center')
        box on
        
        line([DEV_OBS_lo DEV_OBS_hi], [6 6]-offset, 'Color', ColorObs,'LineWidth',lwidth); hold on
        plot([DEV_OBS_lo DEV_OBS_hi], [6 6]-offset, 'o','MarkerFaceColor',ColorObs,'MarkerEdgeColor',ColorObs,'MarkerSize',DotSize)
        line([DEV_MOD_lo DEV_MOD_hi], [5 5]-offset, 'Color', ColorPred,'LineWidth',lwidth); hold on
        plot([DEV_MOD_lo DEV_MOD_hi], [5 5]-offset, 'o','MarkerFaceColor',ColorPred,'MarkerEdgeColor',ColorPred,'MarkerSize',DotSize)
        line([DEV_MOD1_lo DEV_MOD1_hi], [4 4]-offset, 'Color', ColorPred1,'LineWidth',lwidth); hold on
        plot([DEV_MOD1_lo DEV_MOD1_hi], [4 4]-offset, 'o','MarkerFaceColor',ColorPred1,'MarkerEdgeColor',ColorPred1,'MarkerSize',DotSize)
        line([DEV_MOD2_lo DEV_MOD2_hi], [3 3]-offset, 'Color', ColorPred2,'LineWidth',lwidth); hold on
        plot([DEV_MOD2_lo DEV_MOD2_hi], [3 3]-offset, 'o','MarkerFaceColor',ColorPred2,'MarkerEdgeColor',ColorPred2,'MarkerSize',DotSize)
        line([DEV_MOD3_lo DEV_MOD3_hi], [2 2]-offset, 'Color', ColorPred3,'LineWidth',lwidth); hold on
        plot([DEV_MOD3_lo DEV_MOD3_hi], [2 2]-offset, 'o','MarkerFaceColor',ColorPred3,'MarkerEdgeColor',ColorPred3,'MarkerSize',DotSize)
        line([DEV_MOD4_lo DEV_MOD4_hi], [1 1]-offset, 'Color', ColorPred4,'LineWidth',lwidth); hold on
        plot([DEV_MOD4_lo DEV_MOD4_hi], [1 1]-offset, 'o','MarkerFaceColor',ColorPred4,'MarkerEdgeColor',ColorPred4,'MarkerSize',DotSize)
         
    end
end

for j =[3 6 9]
    axes(hh(j));
    text(63, 6-offset, 'Observations','FontName','Arial','Fontsize',LabelFontSize)
    text(63, 5-offset, 'All stressors','FontName','Arial','Fontsize',LabelFontSize)
    text(63, 4-offset, 'Without cyclones','FontName','Arial','Fontsize',LabelFontSize)
    text(63, 3-offset, 'Without bleaching','FontName','Arial','Fontsize',LabelFontSize)
    text(63, 2-offset, 'Without CoTS','FontName','Arial','Fontsize',LabelFontSize)
    text(63, 1-offset, 'Without WQ','FontName','Arial','Fontsize',LabelFontSize)
end

for j=[7 8 9]
%     hh(j).XLabel.String={'';'$X - \bar{X_{t}}$'};
%     hh(j).XLabel.Interpreter='Latex';
    hh(j).XLabel.String={'Observation or prediction error';'(percent coral cover)'};
    hh(j).XLabel.FontSize=LabelFontSize;
end

for j=[1:9]
    hh(j).XTick = [-50:10:50];
    hh(j).XTickLabel = num2cell(hh(j).XTick);
%     hh(j).XLabel.FontSize=TitleFontSize;
%     hh(j).YAxis.Visible = 'off';
end

count2 = 0;
for j=[1 4 7]
    count2 = count2+1;
    hh(j).YLabel.String=regionlabel{count2};
    hh(j).YLabel.FontSize=TitleFontSize;
    hh(j).YLabel.FontWeight='bold';
%     hh(j).YLabel.Rotation=0;
%     hh(j).YLabel.HorizontalAlignment = 'right'
end

for j=[1 2 3]
    hh(j).Title.String={shelflabel{j}};
    hh(j).Title.FontSize=TitleFontSize;
    hh(j).Title.FontWeight='bold';
end

IMAGENAME = 'SENSITIVITY';
print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,20);
close(hfig);
