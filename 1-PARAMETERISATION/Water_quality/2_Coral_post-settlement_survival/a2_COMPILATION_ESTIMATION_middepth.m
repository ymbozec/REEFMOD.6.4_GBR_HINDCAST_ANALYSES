clear
load('EREEFS_GBR4_H2p0_B3p1_Cq3b_Dhnd_MIDDEPTH_SSC.mat');

Nb_years = 8; % 8 years of data

%% ------------------------------------------------------------------------
%% NOTE: we miss Nov 2010 so only 5 months for summer 2010
% The best way is just to fill the gap with the average daily values for
% November months from 2012 to 2016 (2017 and 2018 will be later excluded)
DATA_middepth2(1).SSC = nan(size(DATA_middepth(12).SSC));
DATA_middepth2(1).month={'2010-11 reconstructed'};

for d = 1:30 % 30 days in November    
    DATA_middepth2(1).SSC(:,:,d) = (1/7)*(DATA_middepth(12).SSC(:,:,d) + DATA_middepth(24).SSC(:,:,d) + DATA_middepth(36).SSC(:,:,d) + ...
        DATA_middepth(48).SSC(:,:,d) + DATA_middepth(60).SSC(:,:,d) + DATA_middepth(72).SSC(:,:,d) + DATA_middepth(84).SSC(:,:,d));
end

% Then just fill the rest with the 95 following month -> 96 (8 years * 12)
% Note this will be trimmed below to exclude 2017 and 2018
for m=1:size(DATA_middepth,2)
    DATA_middepth2(m+1).SSC = DATA_middepth(m).SSC ;    
    DATA_middepth2(m+1).month = DATA_middepth(m).month;
end


clear DATA_middepth
%% ------------------------------------------------------------------------
%% NOW GENERATE SEASONAL DATA STORAGE using DATA_middepth2
for y = 1:Nb_years 
    MIDDEPTH_SUMMER(y).SSC = NaN(600,180,6); % monthly mean values of SSC in summer (6 months)
    MIDDEPTH_WINTER(y).SSC = NaN(600,180,6); % monthly mean values of SSC in winter (6 months)
end

SURVIVAL = ones(600,180,Nb_years);

GROWTH_SUMMER = zeros(600,180,Nb_years);
GROWTH_WINTER = zeros(600,180,Nb_years);

% Simulate impacts of a hypothetical reduction of SSC
WQ_CONTROL = 1; filename = ''; % no change
% WQ_CONTROL = 0.5; filename = '_WQ50'; % reduce SSC by 50% everywhere

stack = 0;

for y = 1:Nb_years
    y
    count_days = 0;    
    for m = 1:6 % for the 6 months of each summer
        m
        stack = stack+1
        MIDDEPTH_SUMMER(y).SSC(:,:,m) = WQ_CONTROL*(1e6/1000)*nanmean(DATA_middepth2(stack).SSC,3);% converted in [mg L-1];
               
        for d=1:size(DATA_middepth2(stack).SSC,3) % for every day of the selected stack
            
            count_days = count_days+1;
            SSC_daily = DATA_middepth2(stack).SSC(:,:,d) ;
            
            % Use regression model performed on survival after 40 days then downscale to daily survival 
%             SURVIVAL_daily = (1-1.88e-3 *squeeze(WQ_CONTROL*(1e6/1000)*SSC_daily)).^(1/40); % SS converted in [mg L-1];
            
            % Better to use the regression model obtained on daily survival
            % to avoid generating complex numbers from negatives
            SURVIVAL_daily = 1 - 5.223e-5 * squeeze(WQ_CONTROL*(1e6/1000)*SSC_daily); % SS converted in [mg L-1];)
           
            SURVIVAL_daily(SURVIVAL_daily<0.01)=0.01; % cap with a minimum (avoid zeros and negatives)
            SURVIVAL(:,:,y) = SURVIVAL(:,:,y).*SURVIVAL_daily ;
            
            GROWTH_daily = 1 - 0.176*log(1+WQ_CONTROL*(1e6/1000)*SSC_daily);% converted in [mg L-1];)
            GROWTH_daily(GROWTH_daily<0.01)=0.01;  % cap with a minimum 
%             GROWTH_SUMMER(:,:,y) = GROWTH_SUMMER(:,:,y).*GROWTH_daily ; % if logarithmic mean
            GROWTH_SUMMER(:,:,y) = GROWTH_SUMMER(:,:,y)+GROWTH_daily ; % if arithmetic mean
        end
    end    
%     GROWTH_SUMMER(:,:,y) = GROWTH_SUMMER(:,:,y).^(1/count_days); % equivalent to a logarithmic mean
    GROWTH_SUMMER(:,:,y) = GROWTH_SUMMER(:,:,y)/count_days; % arithmetic mean

    count_days = 0;  
    for m = 1:6 % for the 6 months of each winter
        m
        stack = stack+1
        MIDDEPTH_WINTER(y).SSC(:,:,m) = WQ_CONTROL*(1e6/1000)*nanmean(DATA_middepth2(stack).SSC,3); % converted in [mg L-1];
        
        for d=1:size(DATA_middepth2(stack).SSC,3) % for every day of the selected stack
            
            count_days = count_days+1;
            SSC_daily = DATA_middepth2(stack).SSC(:,:,d) ;
            
            GROWTH_daily = 1 - 0.176*log(1+WQ_CONTROL*(1e6/1000)*SSC_daily);% converted in [mg L-1];)
            GROWTH_daily(GROWTH_daily<0.01)=0.01;  % cap with a minimum (avoid zeros and negatives)
%             GROWTH_WINTER(:,:,y) = GROWTH_WINTER(:,:,y).*GROWTH_daily ;
            GROWTH_WINTER(:,:,y) = GROWTH_WINTER(:,:,y)+GROWTH_daily ; % if arithmetic mean
        end 
    end
%     GROWTH_WINTER(:,:,y) = GROWTH_WINTER(:,:,y).^(1/count_days);
    GROWTH_WINTER(:,:,y) = GROWTH_WINTER(:,:,y)/count_days;
    
end


%% ------------------------------------------------------------------------
%% NOW ASSIGN VALUES TO EACH OF THE 3806 REEFS

% Requires to intersect each reef polygon with eReefs pixels
load('GBR_centroids.mat') % Karlo's 3806 centroids
load('EREEFS_physical.mat') %% eReefs 600*180 pixel coordinates

REEF_RECRUIT_SURVIVAL = nan(size(centr,1),Nb_years);
REEF_JUV_GROWTH_SUMMER = REEF_RECRUIT_SURVIVAL;
REEF_JUV_GROWTH_WINTER = REEF_RECRUIT_SURVIVAL;
REEF_SSC_6m = REEF_RECRUIT_SURVIVAL;
check_growth = GROWTH_SUMMER(:,:,1); % nan where there is no water

pixel_list = nan(size(centr,1),1);

for r = 1:size(centr,1)
    
    % Assign value to centroids from their nearest neighbouring pixel
    pixel_list(r,1) = f_find_nearest_eReefs_pixel(centr(r,2), centr(r,1), y_centre, x_centre, check_growth);
    
end

for r=1:size(centr,1)
    for y = 1:Nb_years
        
        S_TEMP = squeeze(SURVIVAL(:,:,y));
        REEF_RECRUIT_SURVIVAL(r,y) = nanmean(S_TEMP(pixel_list(r,1)));
        
        G_SUMMER_TEMP = squeeze(GROWTH_SUMMER(:,:,y));
        REEF_JUV_GROWTH_SUMMER(r,y) = nanmean(G_SUMMER_TEMP(pixel_list(r,1)));
        
        G_WINTER_TEMP = squeeze(GROWTH_WINTER(:,:,y));
        REEF_JUV_GROWTH_WINTER(r,y) = nanmean(G_WINTER_TEMP(pixel_list(r,1)));
        
        SSC_temp = cat(3, MIDDEPTH_SUMMER(y).SSC, MIDDEPTH_WINTER(y).SSC) ;
        SSC_temp2 = nanmean(SSC_temp,3);
        REEF_SSC_6m(r,y) = SSC_temp2(pixel_list(r,1));
        
    end  
end

%% EXPORT
save(['GBR_RECRUIT_SURVIVAL' filename],'REEF_RECRUIT_SURVIVAL')
save(['GBR_JUV_GROWTH' filename],'REEF_JUV_GROWTH_SUMMER','REEF_JUV_GROWTH_WINTER')
save(['GBR_ssc_middepth' filename],'MIDDEPTH_SUMMER','MIDDEPTH_WINTER')


%% EXPLORE VALUES OF SSC ON REEFS
load('/home/ym/REEFMOD/REEFMOD.6.3_GBR_FINAL/data/GBR_REEF_POLYGONS.mat')

% Estimate SSC percentiles for GLM of coral growth
SSC_PTILES1 = prctile(mean(REEF_SSC_6m,2),[0, 5, 10, 25, 50, 75, 90, 95, 100]) 
hfig1=figure;
histogram(mean(REEF_SSC_6m,2),[0:2:80])
xlabel('Annual mean SSC (mg/L)')
ylabel('Frequency (nb of reefs)')

SSC_PTILES2 = prctile(REEF_SSC_6m(:),[10, 25, 50, 75, 90]) 
hfig1=figure;
histogram(REEF_SSC_6m(:),[0:5:100])
xlabel('Annual mean SSC (mg/L)')
ylabel('Frequency (nb of reefs)')


hfig3=figure;
subplot(1,3,1)
histogram(mean(REEF_SSC_6m(GBR_REEFS.KarloShelf==1),2),[0:5:100])
xlabel('Annual mean SSC (mg/L)')
ylabel('Frequency (nb of reefs)')
title('Inshore reefs (N=1,374)', 'FontWeight','bold')
SSC_PTILES_INSHORE = prctile(mean(REEF_SSC_6m(GBR_REEFS.KarloShelf==1),2),[0, 5, 10, 25, 50, 75, 90, 95, 100]) 

subplot(1,3,2)
histogram(mean(REEF_SSC_6m(GBR_REEFS.KarloShelf==2),2),[0:5:100])
xlabel('Annual mean SSC (mg/L)')
ylabel('Frequency (nb of reefs)')
title('Mid-shelf reefs (N=1,652)', 'FontWeight','bold')

subplot(1,3,3)
histogram(mean(REEF_SSC_6m(GBR_REEFS.KarloShelf==3),2),[0:5:100])
xlabel('Annual mean SSC (mg/L)')
ylabel('Frequency (nb of reefs)')
title('Outer-shelf reefs (N=780)', 'FontWeight','bold')
