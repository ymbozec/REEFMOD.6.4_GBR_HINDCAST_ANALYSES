%__________________________________________________________________________
%
% Calculates probabilistic mortalities and mean mortalities from the hindcast
% to get equilibrial cover using Equation 9 in ANALYSIS_RESILIENCE.R
%
% Produces mean simulated mortalities for cyclones, bleaching and CoTS 
% exported in 'MEAN_MORTALITIES_FOR_R.mat'
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________


load('GBR_REEF_POLYGONS.mat')
reef_ID = GBR_REEFS.KarloID;

load('GBR_past_DHW_CRW_5km_1985_2020.mat')
GBR_PAST_DHW = GBR_PAST_DHW(:,24:36);
load('GBR_cyclones_2008-2020_NEW.mat')


load('HINDCAST_METRICS.mat')
ANNUAL_LOSS_REL_COTS = squeeze(mean(IND_REL_MORT_ANNUAL_COTS,1)); % Already converted into a yearly rate
ANNUAL_LOSS_REL_CYCLONES = squeeze(mean(IND_REL_MORT_ANNUAL_CYCLONES,1)); % Already converted into a yearly rate (but applies only in summer)
ANNUAL_LOSS_REL_BLEACHING = squeeze(mean(IND_REL_MORT_ANNUAL_BLEACHING,1));  % Already converted into a yearly rate (but applies only in summer)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODELLING MORTALITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X=[GBR_PAST_CYCLONES_NEW(:) ANNUAL_LOSS_REL_CYCLONES(:)];
X=[X GBR_PAST_DHW(:) ANNUAL_LOSS_REL_BLEACHING(:)];
X=[X ANNUAL_LOSS_REL_COTS(:)];

EXPORT = array2table(X,'VariableNames',{'CycloneCat','MortCyc','DHW','MortBleach','MortCOTS'});


%% Parms to export figures with
my.res = 200 ; %resolution
my.margins = 20 ;


%% 1) Modelling cyclone mortality on coral cover as a function of DHW
% bins=[0:1:100];
% histogram(-EXPORT.MortCyc(EXPORT.CycloneCat==1),bins)
% hold on; histogram(-EXPORT.MortCyc(EXPORT.CycloneCat==2),bins)
% hold on; histogram(-EXPORT.MortCyc(EXPORT.CycloneCat==3),bins)
% hold on; histogram(-EXPORT.MortCyc(EXPORT.CycloneCat==4),bins)

% CycloneMortModel = fitlm(EXPORT.CycloneCat(EXPORT.CycloneCat>0),-EXPORT.MortCyc(EXPORT.CycloneCat>0));
CycloneMortModel = fitlm(EXPORT.CycloneCat(EXPORT.CycloneCat>0),log(1-EXPORT.MortCyc(EXPORT.CycloneCat>0)));

nb_simul = 1000;
CyCat = zeros(nb_simul,1);
M1 = zeros(nb_simul,1);

for i=1:nb_simul
    CyCat(i,1) = randi(5);
    M1(i,1) = exp(random(CycloneMortModel,CyCat(i,1)))-1;
end

Rsquared = CycloneMortModel.Rsquared
Intercept = CycloneMortModel.Coefficients.Estimate(1)
slope = CycloneMortModel.Coefficients.Estimate(2)

x1 = [1 2 3 4];
y1 = (exp(x1*slope + Intercept)-1)/100

%% 2) Modelling bleaching mortality on coral cover as a function of DHW
% plot(EXPORT.DHW, EXPORT.MortBleach,'o')
% ylabel('Relative mortality (%)')
% xlabel('DHW')
% plot(log(1+EXPORT.DHW), log(1-EXPORT.MortBleach),'o')
% plot(log(1+EXPORT.DHW), -EXPORT.MortBleach,'o')

% BleachingMortModel = fitlm(log(1+EXPORT.DHW(EXPORT.MortBleach<0)),log(1-EXPORT.MortBleach(EXPORT.MortBleach<0)));
BleachingMortModel = fitlm(EXPORT.DHW(EXPORT.MortBleach<0),-EXPORT.MortBleach(EXPORT.MortBleach<0));

nb_simul = 1000;
DHW = zeros(nb_simul,1);
M2 = zeros(nb_simul,1);

for i=1:nb_simul
    DHW(i,1) = 2+randi(10);
%         M2(i,1) = exp(random(BleachingMortModel,log(1+DHW(i,1))))-1;
    M2(i,1) = random(BleachingMortModel,DHW(i,1));
end

Rsquared = BleachingMortModel.Rsquared
Intercept = BleachingMortModel.Coefficients.Estimate(1)
slope = BleachingMortModel.Coefficients.Estimate(2)

x2 = [3:14];
y2 = (x2*slope + Intercept)/100

%% PLOT THE GENERATED MORTALITIES
IMAGENAME = ['FIG_S13_CYCLONE_BLEACHING_PROBA_MODELS'];
hfig = figure;
width=1200; height=400; 
set(hfig,'color','w','units','points','position',[0,0,width,height])
set(gca,'Layer', 'top','FontName', 'Arial' , 'FontSize', 12, 'color',rgb('white')); set(gcf, 'InvertHardcopy', 'off');

DotSize = 80;

subplot(1,2,1)
sc1 = scatter(EXPORT.CycloneCat-0.05, -EXPORT.MortCyc,DotSize,'MarkerFaceColor',rgb('midnightblue'),'MarkerFaceAlpha',0.1,...
    'MarkerEdgeColor',rgb('midnightblue'),'MarkerEdgeAlpha',0.1);
hold on
sc2 = scatter(CyCat+0.05, M1, DotSize,'MarkerFaceColor',rgb('gold'),'MarkerFaceAlpha',0.1,...
    'MarkerEdgeColor',rgb('black'),'MarkerEdgeAlpha',0.1);
axis([0 4.5 0 100])
xticks([0:1:5])
yticks([0:20:100])
set(gca,'FontName', 'Arial' , 'FontSize', 12, 'color',rgb('white'));
set(gcf, 'InvertHardcopy', 'off');

ylabel('Proportional coral loss (%)','FontName', 'Arial' ,'FontSize',16)
xlabel('Cyclone category','FontName', 'Arial' ,'FontSize',16)
legend()
[l, hobj, hout, mout]=legend([sc1 sc2], '\fontsize{14}\fontname{Arial}individual-based simulations',...
    '\fontsize{14}\fontname{Arial}probabilistic predictions', 'Location','northwest');
MARKS = findobj(hobj,'type','patch');
set(MARKS,'MarkerSize', 10) %Calculate marker size based on size of scatter points
legend('boxoff')
tit1 = title('A','FontName', 'Arial', 'FontWeight','bold','FontSize',20); 
tit1.Position = [0 103 0];
tit1.HorizontalAlignment='left';

subplot(1,2,2)
sc3 = scatter(EXPORT.DHW(EXPORT.MortBleach<0),-EXPORT.MortBleach(EXPORT.MortBleach<0), DotSize,'MarkerFaceColor',rgb('midnightblue'),'MarkerFaceAlpha',0.1,...
    'MarkerEdgeColor',rgb('midnightblue'),'MarkerEdgeAlpha',0.1)
hold on
sc4 = scatter(DHW, M2, DotSize,'MarkerFaceColor',rgb('gold'),'MarkerFaceAlpha',0.1,...
    'MarkerEdgeColor',rgb('gold'),'MarkerEdgeAlpha',0.1)
axis([0 14 0 100])
xticks([0:2:14])
yticks([0:20:100])
set(gca,'FontName', 'Arial' , 'FontSize', 12, 'color',rgb('white'));
set(gcf, 'InvertHardcopy', 'off');

ylabel('Proportional coral loss (%)','FontName', 'Arial' ,'FontSize',16)
xlabel('DHW','FontName', 'Arial' ,'FontSize',16)
[l, hobj, hout, mout]=legend([sc3 sc4], '\fontsize{14}\fontname{Arial}individual-based simulations',...
    '\fontsize{14}\fontname{Arial}probabilistic predictions', 'Location','northwest');
MARKS = findobj(hobj,'type','patch');
set(MARKS,'MarkerSize', 10) %Calculate marker size based on size of scatter points
legend('boxoff')
tit2 = title('B','FontName', 'Arial', 'FontWeight','bold','FontSize',20); 
tit2.Position = [0 103 0];
tit2.HorizontalAlignment='left';


print(hfig, ['-r' num2str(my.res)], [IMAGENAME '.png' ], ['-d' 'png'] );
crop([IMAGENAME '.png'],0,my.margins); 
close(hfig);


%% 3) Modelling COTS mortality on coral cover (mean and sd)
% CotsMort.mean = mean(ANNUAL_LOSS_REL_COTS(:,3:end),2);
% CotsMort.sd = std(ANNUAL_LOSS_REL_COTS(:,3:end),[],2);

% Logarithmic mean:
% First removes zeros and positives
TEMP_ANNUAL_LOSS_REL_COTS = ANNUAL_LOSS_REL_COTS;
TEMP_ANNUAL_LOSS_REL_COTS(ANNUAL_LOSS_REL_COTS>=0)=-0.01; % turns into -0.01%
% CotsMort.mean = -geomean(-TEMP_ANNUAL_LOSS_REL_COTS(:,3:end),2);
CotsMort.mean = mean(TEMP_ANNUAL_LOSS_REL_COTS(:,3:end),2);
CotsMort.sd = std(TEMP_ANNUAL_LOSS_REL_COTS(:,3:end),[],2);

nb_simul = 1000;
M3 = zeros(3806, nb_simul);

for i=1:nb_simul
    M3(:,i) = normrnd(CotsMort.mean,CotsMort.sd );
%     M3(:,i) = -poissrnd(-CotsMort.mean);
end
M3(M3>0)=0;
figure
subplot(1,2,1) ;histogram(mean(M3,2)); axis([-25 5 0 1000])
subplot(1,2,2) ;histogram(mean(ANNUAL_LOSS_REL_COTS(:,2:end),2)); axis([-25 5 0 1000])

figure
subplot(1,2,1) ;X = M3(:,1:12); histogram(X(:)); axis([-25 5 0 10000])
subplot(1,2,2) ;Y = ANNUAL_LOSS_REL_COTS(:,2:end);histogram(Y(:)); axis([-25 5 0 10000])


%% CREATE PROBABILISTIC FORCING SCENARIOS FOR SIMULATION OF RESILIENCE (TO BE PERFORMED IN R)
% What we do is to create 100 scnearios of 20 years of disturbances
% For cyclones and bleaching, this requires creating matrices of
% disturbance events, then calculate associated mortalities using the 2
% statistical models (BleachingMortModel and CycloneMortModel)
% For COTS we just sample at random the simulated mortality between 2008-2017

nsimul =100; % number of replicates of the forcing scheme
nstep = 80; % number of 6 month steps for simulation

% Nick Wolff matrix of clustered cyclones for 1312 reefs, 100 years, 100 replicates
load('Reef_Cyclone_TimeSeries_Count_Cat.mat') 
CYCLONE_CAT = Cyc_cat(GBR_REEFS.NickID,:,:);

% Using Coral Reef Watch 5km product: max DHW every year from 1985 to 2020 from closest 5x5 km pixel
load('GBR_past_DHW_CRW_5km_1985_2020.mat') 
DHW = GBR_PAST_DHW(:,14:end); %select 1998 to 2020

% Create matrix of probabilistic mortalities
FUTURE_BLEACHING_MORT = zeros(3806,nstep,nsimul);
FUTURE_CYCLONE_MORT = zeros(3806,nstep,nsimul);
FUTURE_COTS_MORT = zeros(3806,nstep,nsimul);

for s=1:nsimul
    
    for t=1:2:nstep
        
        select_DHW_year = randi(size(DHW,2));
        FUTURE_DHW = DHW(:,select_DHW_year);
        FUTURE_BLEACHING_MORT(:,t,s) = -random(BleachingMortModel,FUTURE_DHW);
        FUTURE_BLEACHING_MORT(FUTURE_DHW<3,t,s)=0;
        
        select_cyclone_year = randi(size(CYCLONE_CAT,2));
        FUTURE_CYCLONES = CYCLONE_CAT(:,select_cyclone_year,s);
        FUTURE_CYCLONE_MORT(:,t,s) = -(exp(random(CycloneMortModel,FUTURE_CYCLONES))-1);
        FUTURE_CYCLONE_MORT(FUTURE_CYCLONES==0,t,s)=0;   
    end
    
    for t=1:nstep
        
        COTS_MORT = normrnd(CotsMort.mean,CotsMort.sd);
        COTS_MORT(COTS_MORT>0)=0;
        COTS_MORT(COTS_MORT<-99)=-99;
        FUTURE_COTS_MORT(:,t,s) = -100*(1-(1+COTS_MORT/100).^0.5); % divides by 2 because they were annual mortalities
        
    end
end

FUTURE_BLEACHING_MORT(FUTURE_BLEACHING_MORT<-99)=-99;
FUTURE_CYCLONE_MORT(FUTURE_CYCLONE_MORT<-99)=-99;

%% TEST THE PREDICTIONS
mortbins = [-100:5:0];
x = FUTURE_CYCLONE_MORT(:,1:2:20,1);
y = FUTURE_BLEACHING_MORT(:,1:2:20,1); 
z = FUTURE_COTS_MORT(:,:,1); 

figure
subplot(2,2,1); hist(mean(mean(FUTURE_CYCLONE_MORT(:,1:2:20,:),3),2),mortbins); xlim([-100 10]); title('Mean simulated cyclone mortality (10 yrs)')
subplot(2,2,2); hist(mean(ANNUAL_LOSS_REL_CYCLONES,2),mortbins); xlim([-100 10]); title('Mean hindcast cyclone mortality (10 yrs)')
subplot(2,2,3); hist(mean(mean(FUTURE_BLEACHING_MORT(:,1:2:20,:),3),2),mortbins); xlim([-100 10]); title('Mean simulated bleaching mortality (10 yrs)')
subplot(2,2,4); hist(mean(ANNUAL_LOSS_REL_BLEACHING,2),mortbins); xlim([-100 10]); title('Mean hindcast bleachingmortality (10 yrs)')

figure
subplot(1,3,1); plot(mean(mean(FUTURE_BLEACHING_MORT(:,1:2:20,:),3),2),mean(ANNUAL_LOSS_REL_BLEACHING,2),'o'); ylabel('Hindcast'); hold on ; line([-25 -0], [-25 0])
subplot(1,3,2); plot(mean(FUTURE_BLEACHING_MORT(:,1:2:20,40),2),mean(ANNUAL_LOSS_REL_BLEACHING,2),'o'); ylabel('Hindcast'); hold on ; line([-25 -0], [-25 0])
subplot(1,3,3); plot(mean(mean(FUTURE_COTS_MORT,3),2),mean(ANNUAL_LOSS_REL_COTS,2),'o'); ylabel('Hindcast'); hold on ; line([-25 -0], [-25 0])


% Now we simply save the mean mortalities to get the deterministic equilibrium
MEAN_CYCLONE_MORT = mean(mean(FUTURE_CYCLONE_MORT,3),2); % this averages summer and winter (null mortality)
MEAN_BLEACHING_MORT = mean(mean(FUTURE_BLEACHING_MORT,3),2); % this averages summer and winter (null mortality)
% MEAN_COTS_MORT1 = mean(mean(FUTURE_COTS_MORT,3),2);
MEAN_COTS_MORT = CotsMort.mean; % Better to use the mean of the hindcast rather than the probabilistic ones for COTS
save('MEAN_MORTALITIES_FOR_R.mat', 'MEAN_CYCLONE_MORT', 'MEAN_BLEACHING_MORT', 'MEAN_COTS_MORT')

