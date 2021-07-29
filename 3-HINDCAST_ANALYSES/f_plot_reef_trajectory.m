function f_plot_reef_trajectory(select_reefs, years, ...
    coral_cover_mean, area_w, AIMS_time, AIMS_MT,AIMS_TR ,TitleReefSelection,fig_panel)


FontSizeLabelTicks = 9;
FontSizeLabelAxes = 11;
FontSizeLabelTitles = 13;
DotSize = 3;

maxCover = 80;

plot(years, coral_cover_mean(select_reefs,:),'-','Color',rgb('LightBlue')); hold on
plot(years, area_w(select_reefs,1)'*coral_cover_mean(select_reefs,:)/sum(area_w(select_reefs,1)),'-','Color',rgb('Crimson'),'LineWidth',2)
% 
% if isempty(AIMS_time)~=1
%     plot(AIMS_time,AIMS_MT,'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
%     
%     select_AIMS_TR =find(AIMS_TR(:,5)>=2007.5 & AIMS_TR(:,5)<=2017.5);
%     plot(AIMS_TR(select_AIMS_TR,5),AIMS_TR(select_AIMS_TR,4),'o','MarkerSize',DotSize,'MarkerFaceColor','w','MarkerEdgeColor','k') % add manta tow surveys (already scaled to transect equivalent)
% 
%     %% add observed mean per year
%     
% %     AIMSmt = [AIMS_time ; nanmean(AIMS_MT,1)]';
% %     AIMStr = [AIMS_TR(select_AIMS_TR,5)  AIMS_TR(select_AIMS_TR,4)];
% %     AIMS = [AIMSmt ; AIMStr ];
% %     AIMStable = array2table(AIMS);
% %     omean = @(x) mean(x,'omitnan');
% % 
% %     AIMSmean = table2array(varfun(omean, AIMStable,'GroupingVariables',{'AIMS1'},'InputVariables',{'AIMS2'}));
% % 
% %     J=isnan(AIMSmean(:,3));
% %     plot(AIMSmean(J==0,1),AIMSmean(J==0,3),'-','Color','k') % add manta tow surveys (already scaled to transect equivalent)
% %    
% end

% axis([2007.5 2017.5 0 maxCover]);
% axis([2007.2 2017.8 0 maxCover]);
axis([2007.2 2020.8 0 maxCover]);
xticks([2008:4:2020])

set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
% xlabel({'';'Years'},'FontName', 'Arial', 'FontWeight','bold','FontSize',10)
% ylabel({'Coral cover (%)';''},'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelAxes)
yticks([0:20:80])
title(TitleReefSelection,'FontName', 'Arial', 'FontWeight','bold','FontSize',FontSizeLabelTitles)

% N = [' (n = ' num2str(length(select_reefs)) ')'];
% % title(['\fontsize{13} fontweight{bold} TitleReefSelection' '\fontsize{11} N]'],'interpreter','tex');
% %     '\fontsize{20} Mixed_{\fontsize{8} underscore}'],'interpreter','tex');
% title([TitleReefSelection N],'FontName', 'Arial', 'FontWeight','normal','FontSize',FontSizeLabelTitles)
% 
% % text(2011,75,N,'FontName', 'Arial', 'FontSize',FontSizeLabelTicks,'HorizontalAlignment','center')

text(2004, 85, fig_panel,'FontName', 'Arial','FontWeight','bold','FontSize', 16, 'HorizontalAlignment','left')