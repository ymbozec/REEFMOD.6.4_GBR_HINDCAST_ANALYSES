%__________________________________________________________________________
%
% PLOT ERROR INTERVALS FOR FIG S18
% (called in script S1_DEVIANCE_CALCULATIONS.m)
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________


hfig = figure;
width=1200; height=1000; set(hfig,'color','w','units','points','position',[0,0,width,height])
set(hfig, 'Resize', 'off')

regionlabel={'Northern' ; 'Central' ; 'Southern'};
shelflabel = {'inshore';'mid-shelf';'outer-shelf'};
ListReefNames = GBR_REEFS.ReefName;

hh = tight_subplot(3,3,[0.025 0.1],0.08,0.1);
count = 0;
offset = 0;
ColorPred = rgb('Crimson');
ColorObs = rgb('DarkSlateGrey');
ColorRect = rgb('Lavender');

TitleFontSize = 20;
LabelFontSize = 14;
AxisFontSize = 10;

lwidth = 1.5;
Xmin = -70;
Xmax = 70;

for region=1:3
    
    for shelf=1:3
        
        count = count+1;
        myselect2 = SELECTION_REEF(SELECTION_REEF.AIMS_SHELF==shelf & SELECTION_REEF.REGION==region,:);
        [~,J] = sort(GBR_REEFS.LAT(myselect2.KarloID),'ascend');
        myselect3 = myselect2(J,:);
        D = size(myselect3,1);
        axes(hh(count));
        
        if isempty(myselect3)~=0
            
            plot([],[])
            axis([Xmin Xmax 0 offset+K+1])
            set(gca, 'FontName','Arial')
            line([0 0] , [0 offset+K+1], 'LineStyle', '--','Color','k','LineWidth',1)
            yticklabels([]); yticks([])
            
            continue
            
        else
            
            rectangle('Position',[Xmin 0 Xmax offset+D+1], 'FaceColor', ColorRect,'EdgeColor','none'); hold on
%             line([0 0] , [0 offset+D+1], 'LineStyle', '--','Color','k','LineWidth',1); hold on
            
            for K=1:D

                line([myselect3.DEV_OBS_lo(K) myselect3.DEV_OBS_hi(K)], [K K], 'Color', ColorObs,'LineWidth',lwidth); hold on
                plot([myselect3.DEV_OBS_lo(K) myselect3.DEV_OBS_hi(K)], [K K], 'o','MarkerFaceColor',ColorObs,'MarkerEdgeColor',ColorObs)
                line([myselect3.DEV_MOD_lo(K) myselect3.DEV_MOD_hi(K)], 0.1+[K K], 'Color', ColorPred,'LineWidth',lwidth); hold on
                plot([myselect3.DEV_MOD_lo(K) myselect3.DEV_MOD_hi(K)], 0.1+[K K], 'o','MarkerFaceColor',ColorPred,'MarkerEdgeColor',ColorPred)
                
                % Choose to plot median or mean error on top of the interval
                switch select_metrics
                    case 'median'
                plot(myselect3.MEDIAN_ERROR(K), 0.1+K, 'o','MarkerFaceColor','white','MarkerEdgeColor',ColorPred)
                    case 'mean'
                plot(myselect3.MEAN_ERROR(K), 0.1+K, 'o','MarkerFaceColor','white','MarkerEdgeColor',ColorPred)
                end
                
                % Add reef labels
                line( [max([myselect3.DEV_MOD_hi(K) myselect3.DEV_OBS_hi(K)])+5 Xmax], 0.05+[K K],'LineWidth',0.5)
                text(Xmax+3, 0.05+K, ListReefNames(myselect3.KarloID(K)),'FontName','Arial','Fontsize',7)
                
            end
            
            rectangle('Position',[Xmin 0 2*Xmax offset+D+1], 'FaceColor', 'none','EdgeColor','black')

            axis([Xmin Xmax 0 offset+K+1])
            set(gca, 'FontName','Arial','TickDir','out')
            yticklabels([]); yticks([])
            
        end
    end
end

for j=[7 8 9]
%     hh(j).XLabel.String={'';'$X - \bar{X_{t}}$'};
%     hh(j).XLabel.Interpreter='Latex';
    hh(j).XLabel.String={'';'Prediction and observation errors'};
    hh(j).XLabel.FontSize=LabelFontSize;
end

for j=[1:9]
    hh(j).XTick = [-50:20:50]
    hh(j).XTickLabel = num2cell(hh(j).XTick);
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
    hh(j).Title.String={shelflabel{j},''};
    hh(j).Title.FontSize=TitleFontSize;
    hh(j).Title.FontWeight='bold';
end
