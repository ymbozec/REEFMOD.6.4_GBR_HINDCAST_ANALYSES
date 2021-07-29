%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Y.-M. Bozec, MSEL, created Dec 2018.
% Last modified: 18/12/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create spatial layers for Reefmod of coral and CoTS demographics for the whole GBR (the 3806 reefs
% of Karlo's connectivity matrices). Demographics are predicted from eReefs water quality layers and
% empirical dose-response relationships (Humanes et al 2017 a,b). Based on the following eReefs models:
% - GBR4_H2p0_B2p0_Chyd_Dcrt (12/2010–10/2016)
% - GBR4_H2p0_B2p0_Chyd_Dnrt (11/2016–today)
% Data available (with gaps) from Summer 2011 to Winter 2018 so 8 complete years with two seasons
% Summer months: Nov - April (6 months)
% Winter months: May - Oct (6 months)
clear
load('GBR_dispersal.mat') 
% load('GBR_dispersal_WQ50.mat') 
% POTENT_SEED gives the relative success of reproduction (0-1) as potential larval supply before
% dispersion (seeding) as a function of near-surface suspended sediments
% 3806 x 3 x 6 with 3 spawning periods (with NaNs)
% Period covered: 2011-2016
% To be applied after reproduction and before dispersal during summer steps

load('GBR_JUV_GROWTH.mat')
% load('GBR_JUV_GROWTH_WQ50.mat')
% REEF_JUV_GROWTH_SUMMER -> growth potential (0-1) from mid-depth SSC 6-month average
% (except first year where average is 5 month because only starts in December
% 3806 x 8 years
% REEF_JUV_GROWTH_WINTER -> same for winter months
% 3806 x 8 years
% Period covered: 2011-2018
% To be applied at each time step when processing population growth

load('GBR_RECRUIT_SURVIVAL.mat')
% load('GBR_RECRUIT_SURVIVAL_WQ50.mat')
% REEF_RECRUIT_SURVIVAL -> relative survival (0-1) from cumulated mortality over 6 month in summer
% function of daily mid-depth SSC values
% 3806 x 8 years
% Period covered: 2011-2018
% To be applied at recruitment (end of summer steps)

load('GBR_COTS_SURVIVAL.mat')
% load('GBR_COTS_SURVIVAL_WQ50.mat')
% REEF_COTS_SURVIVAL_POTENTIAL -> relative survival (0-1) of CoTS larvae
% from Chl a
% NOTE THE SCENARIO WQ50 (Chl a conc divided by 2 everywhere) IS FALWED FOR OUTER REEFS

%% LAYER OF CORAL REPRODUCTION FOR SUMMERS 2012, 2013, 2014, 2015, 2016, 2017
for k=1:6
    
    GBR_REEF_POP(k).CORAL_larvae_production = nanmean(squeeze(POTENT_SEED(:,:,k)),2); % average across spawning event
    
end

%% OTHER LAYERS FOR 2011-2018
for k=1:8
       
    GBR_REEF_POP(k).CORAL_juvenile_growth = [REEF_JUV_GROWTH_SUMMER(:,k) REEF_JUV_GROWTH_WINTER(:,k)];
    GBR_REEF_POP(k).CORAL_recruit_survival = REEF_RECRUIT_SURVIVAL(:,k);
    GBR_REEF_POP(k).COTS_larvae_survival = REEF_COTS_SURVIVAL(:,k);
    
end

save('GBR_REEF_POP.mat','GBR_REEF_POP')
% save('GBR_REEF_POP_WQ50.mat','GBR_REEF_POP')