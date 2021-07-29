clear

load('GBR_REEF_POLYGONS.mat')

%% Load AIMS LTMP observations for the whole GBR
% StartDate = 1992;
EndDate = 2018;

load('AIMS_LTMP_Transect_means.mat') 
select_TR = find(LTMP_Transects_means.YEAR_Reefmod<=EndDate);
AIMS_TR = LTMP_Transects_means(select_TR,[16 17 3 9 5]); %5: Years, 10: cover tot, 9: YEAR_reefmod
AIMS_TR.Properties.VariableNames = {'KarloID','SECTOR','SHELF','CCOVER','YEAR'};

AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='I')=1;
AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='M')=2;
AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='O')=3;
AIMS_TR = AIMS_TR(:,[1 2 6 4 5]); 

load('AIMS_MantaTow_1992_2018.mat')
AIMS_MTtmp = struct2table(MantaTow_1992_2018);
select_MT = find(AIMS_MTtmp.YearReefMod<=EndDate);
AIMS_MT = AIMS_MTtmp(select_MT,[1 2 5 6]);
AIMS_MT.SECTOR = GBR_REEFS.Sector(AIMS_MT.YM_Reef_matposition);
AIMS_MT = AIMS_MT(:,[1 5 2 4 3]);
AIMS_MT.Properties.VariableNames = {'KarloID','SECTOR','AIMS_SHELF','CCOVER','YEAR'};

% Combine manta tows and transects to find relationship
AIMS_ALL = outerjoin(AIMS_TR,AIMS_MT,'LeftKeys', [1,2,3,5],'RightKeys', [1,2,3,5]);

select = find(isnan(AIMS_ALL.YEAR_AIMS_TR)==0 & isnan(AIMS_ALL.YEAR_AIMS_MT)==0);

% DOn't get confused here: we want to predict transects from manta tows, so
% that manta tows estimates can be converted into transect equivalent
LTMP_Transect2Tow_Model = fitlm(AIMS_ALL.CCOVER_AIMS_MT(select),AIMS_ALL.CCOVER_AIMS_TR(select));
% LTMP_Transect2Tow_Model = fitlm(sqrt(AIMS_ALL.CCOVER_AIMS_MT(select)), sqrt(AIMS_ALL.CCOVER_AIMS_TR(select)));
% LTMP_Transect2Tow_Model = fitlm(AIMS_ALL.CCOVER_AIMS_MT(select), log(1+AIMS_ALL.CCOVER_AIMS_TR(select)));
% LTMP_Transect2Tow_Model = fitlm(log(1+AIMS_ALL.CCOVER_AIMS_MT(select)), AIMS_ALL.CCOVER_AIMS_TR(select));

INTERCEPT = LTMP_Transect2Tow_Model.Coefficients(1,1)
SLOPE = LTMP_Transect2Tow_Model.Coefficients(2,1)
R2 = LTMP_Transect2Tow_Model.Rsquared

% figure
% subplot(1,2,1); hist(AIMS_ALL.CCOVER_AIMS_MT(select))
% subplot(1,2,2); hist(AIMS_ALL.CCOVER_AIMS_TR(select))
% 
% figure
% subplot(1,2,1); hist(sqrt(AIMS_ALL.CCOVER_AIMS_MT(select)))
% subplot(1,2,2); hist(sqrt(AIMS_ALL.CCOVER_AIMS_TR(select)))
% 

%% FIGURE
IMAGENAME = ['FIG_AIMS_LTMP_RELATIONSHIP'];
hfig = figure;
width=400; height=400; set(hfig,'color','w','units','points','position',[0,0,width,height])
line([0 79],[0 79],'Color','k','LineStyle','--'); hold on
% datacolor = [96 101 219]/255;
datacolor = [150 150 150]/255;

% scatter(AIMS_ALL.CCOVER_AIMS_MT(select),AIMS_ALL.CCOVER_AIMS_TR(select),20,datacolor,'filled')
scatter(AIMS_ALL.CCOVER_AIMS_MT(select),AIMS_ALL.CCOVER_AIMS_TR(select),'o')

line([0:10:60],predict(LTMP_Transect2Tow_Model,[0:10:60]'),'LineWidth',2)
% line([0:1:60],(predict(LTMP_Transect2Tow_Model,sqrt([0:1:60])')).^2,'Color',datacolor,'LineWidth',2)

set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 10, 'color',rgb('White')); set(gcf, 'InvertHardcopy', 'on');

text(80,81, {'1:1'},'FontName', 'Arial' , 'FontSize', 10 )
ylabel({'Coral cover (%) from transects';''},'FontName', 'Arial' , 'FontSize', 14)
xlabel({'Coral cover (%) from manta tows';''},'FontName', 'Arial' , 'FontSize', 14)
axis([0 80 0 80])
axis square
box on

%% EXPORT MODEL
save('LTMP_Transect2Tow_NEW.mat','LTMP_Transect2Tow_Model')


