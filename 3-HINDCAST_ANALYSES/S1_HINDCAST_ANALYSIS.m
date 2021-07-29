%__________________________________________________________________________
%
% CALCULATE DERIVED OUTPUTS PER REGION
% 
% Requires the output file of ReefMod-GBR Hindcast
% 'R0_HINDCAST_GBR.mat' (~360MB)
% Produces 'HINDCAST_METRICS.mat' which is used for subsequent analyses
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

load('GBR_REEF_POLYGONS.mat')
load('R0_HINDCAST_GBR.mat'); outfilename ='HINDCAST_METRICS.mat';

% Initial step is end of 2007 (winter), first step is summer 2008, last step is end of 2017
start_year = 2007.5 ;
years =  start_year + (0:META.nb_time_steps)/2 ;

coral_cover_tot = sum(coral_cover_per_taxa,4);
Coral_tot.M = squeeze(mean(coral_cover_tot, 1)) ;
Coral_tot.SD = squeeze(std(coral_cover_tot, 0, 1)) ;

% Mean cover per species
for s=1:META.nb_coral_types
    Coral_sp(s).M = squeeze(mean(coral_cover_per_taxa(:,:,:,s), 1)) ;
    Coral_sp(s).SD= squeeze(std(coral_cover_per_taxa(:,:,:,s), 0, 1));
end

area_w = log(1+META.area_habitat)/sum(log(1+META.area_habitat)); % weigh by habitat area

%% For reef selection
lat_cutoff = -10 ; % exclude reefs above (north) this latitude

select.North = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3)&GBR_REEFS.LAT<lat_cutoff);
select.Centre = find(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8);
select.South = find(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11);

select.North_IN = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==1);
select.North_MID = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==2);
select.North_OUT = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==3);

select.Centre_IN = find((GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8) & GBR_REEFS.KarloShelf==1);
select.Centre_MID = find((GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8) & GBR_REEFS.KarloShelf==2);
select.Centre_OUT = find((GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8) & GBR_REEFS.KarloShelf==3);

select.South_IN = find((GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11) & GBR_REEFS.KarloShelf==1);
select.South_MID = find((GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11) & GBR_REEFS.KarloShelf==2);
select.South_OUT = find((GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11) & GBR_REEFS.KarloShelf==3);

select.GBR = find(GBR_REEFS.LAT<lat_cutoff); % 3,027 reefs in total if lat_cutoff=-13.
select.GBR_IN = find(GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==1); 
select.GBR_MID = find(GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==2); 
select.GBR_OUT = find(GBR_REEFS.LAT<lat_cutoff & GBR_REEFS.KarloShelf==3); 

%% Function to calculate mean values across a specific region weighted by reef area of that region
weighted_mean = @(x,w,select) (w(select,1)'*x(select,:)/sum(w(select,1)))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Trajectories of coral cover 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store mean trajectories
MEAN_TRAJECTORIES = array2table(years','VariableNames',{'Year'});
MEAN_TRAJECTORIES.GBR = weighted_mean(Coral_tot.M, area_w, select.GBR);
MEAN_TRAJECTORIES.NORTH = weighted_mean(Coral_tot.M, area_w, select.North);
MEAN_TRAJECTORIES.CENTER = weighted_mean(Coral_tot.M, area_w, select.Centre);
MEAN_TRAJECTORIES.SOUTH = weighted_mean(Coral_tot.M, area_w, select.South);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2) Rates of change of coral cover 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORAL COVER CHANGE
ANNUAL_CORAL_COVER_ini = squeeze(mean(coral_cover_tot(:,:,1:2:(end-1)),1)); % end of winter for years y
ANNUAL_CORAL_COVER_fin = squeeze(mean(coral_cover_tot(:,:,3:2:end),1)); % end of winter for years y+1
ANNUAL_CORAL_COVER_ini(ANNUAL_CORAL_COVER_ini<0.1) = 0.1;

%% Absolute change in coral cover
ANNUAL_ABS_CHANGE = ANNUAL_CORAL_COVER_fin - ANNUAL_CORAL_COVER_ini;

% Store mean annual changes
MEAN_ANNUAL_ABS_CHANGE = array2table([2008:1:2020]','VariableNames',{'Year'});
MEAN_ANNUAL_ABS_CHANGE.GBR = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select.GBR);
MEAN_ANNUAL_ABS_CHANGE.NORTH = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select.North);
MEAN_ANNUAL_ABS_CHANGE.CENTER = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select.Centre);
MEAN_ANNUAL_ABS_CHANGE.SOUTH = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select.South);

%% Relative change in coral cover
ANNUAL_REL_CHANGE = 100*(ANNUAL_CORAL_COVER_fin - ANNUAL_CORAL_COVER_ini)./ANNUAL_CORAL_COVER_ini;

% Store mean annual changes
MEAN_ANNUAL_REL_CHANGES = array2table([2008:1:2020]','VariableNames',{'Year'});
MEAN_ANNUAL_REL_CHANGES.GBR = weighted_mean(ANNUAL_REL_CHANGE, area_w, select.GBR);
MEAN_ANNUAL_REL_CHANGES.NORTH = weighted_mean(ANNUAL_REL_CHANGE, area_w, select.North);
MEAN_ANNUAL_REL_CHANGES.CENTER = weighted_mean(ANNUAL_REL_CHANGE, area_w, select.Centre);
MEAN_ANNUAL_REL_CHANGES.SOUTH = weighted_mean(ANNUAL_REL_CHANGE, area_w, select.South);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Coral mortality due to disturbance 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Need to account for growth before mortality
LOSS_WINTER = - ( sum(coral_cover_lost_bleaching(:,:,2:2:end,:),4) + sum(coral_cover_lost_cyclones(:,:,2:2:end,:),4) + sum(coral_cover_lost_COTS(:,:,2:2:end,:),4) );
LOSS_SUMMER = - ( sum(coral_cover_lost_bleaching(:,:,1:2:end,:),4) + sum(coral_cover_lost_cyclones(:,:,1:2:end,:),4) + sum(coral_cover_lost_COTS(:,:,1:2:end,:),4) ); 
% figure; bins = [-100:5:10] ; subplot(1,2,1); hist(LOSS_WINTER(:),bins) ;subplot(1,2,2); hist(LOSS_SUMMER(:),bins)

COVER_WINTER = coral_cover_tot(:,:,1:2:end); % there is one more winter than summer
COVER_SUMMER = coral_cover_tot(:,:,2:2:end);

COVER_WINTER(COVER_WINTER<0.1)=0.1; % cap minimum to 1% to calculate ratio
COVER_SUMMER(COVER_SUMMER<0.1)=0.1; % cap minimum to 1% to calculate ratio

IND_GROWTH_SUMMER = COVER_SUMMER(:,:,1:end) - COVER_WINTER(:,:,1:(end-1)) - LOSS_SUMMER;
IND_GROWTH_WINTER = COVER_WINTER(:,:,2:end) - COVER_SUMMER(:,:,1:end) - LOSS_WINTER;
% figure; bins = [-1:0.5:12] ; subplot(1,2,1); hist(GROWTH_WINTER(:),bins) ;subplot(1,2,2); hist(GROWTH_SUMMER(:),bins)

%% Absolute cover change due to each stressor (mortality)
MORT_SUMMER_COTS = -sum(coral_cover_lost_COTS(:,:,1:2:end-1,:),4); % because the first record of mortality due to CoTS is after summer step
MORT_WINTER_COTS = -sum(coral_cover_lost_COTS(:,:,2:2:end,:),4);
IND_MORT_ANNUAL_COTS = MORT_SUMMER_COTS + MORT_WINTER_COTS;
% figure; bins = [-100:5:10] ; subplot(1,2,1); hist(MORT_WINTER_COTS(:),bins) ;subplot(1,2,2); hist(MORT_SUMMER_COTS(:),bins)

% Now loss due to bleaching and cyclones (not CoTS) is per species
IND_MORT_ANNUAL_BLEACHING = -sum(coral_cover_lost_bleaching(:,:,1:2:end,:),4);
IND_MORT_ANNUAL_CYCLONES = -sum(coral_cover_lost_cyclones(:,:,1:2:end,:),4);

%% Calculation of proportional cover loss (mortality) = relative to coral cover AFTER growth
%% Relative cover change due to CoTS (mortality)
REL_MORT_SUMMER_COTS = 100*MORT_SUMMER_COTS./(COVER_WINTER(:,:,1:(end-1))+IND_GROWTH_SUMMER) ;
REL_MORT_WINTER_COTS = 100*MORT_WINTER_COTS./(COVER_SUMMER(:,:,1:end)+IND_GROWTH_WINTER) ;
% figure; bins = [-100:5:10] ; subplot(1,2,1); hist(REL_MORT_WINTER_COTS(:),bins) ;subplot(1,2,2); hist(REL_MORT_SUMMER_COTS(:),bins)
% 
% min(REL_MORT_WINTER_COTS(:))
% min(REL_MORT_SUMMER_COTS(:))
% REL_MORT_SUMMER_COTS(REL_MORT_SUMMER_COTS < -100)= -100;
% REL_MORT_WINTER_COTS(REL_MORT_WINTER_COTS < -100)= -100;

IND_REL_MORT_ANNUAL_COTS =  -100*(1 - (1+REL_MORT_WINTER_COTS/100).*(1+REL_MORT_SUMMER_COTS/100)); %remember relative mort are negative
% min(REL_MORT_ANNUAL_COTS(:))
% figure; bins = [-100:5:10] ; hist(REL_MORT_ANNUAL_COTS(:),bins)

%% Relative cover change due to bleaching and cyclones (mortality) 
% (need to account for loss due to CoTS first)
% Note we cannot get cyclone and bleaching on same reef the same year
% Note the term "annual mortality" is confusing as the relative loss is only for summer
IND_REL_MORT_ANNUAL_BLEACHING = 100*IND_MORT_ANNUAL_BLEACHING./(COVER_WINTER(:,:,1:(end-1)) + IND_GROWTH_SUMMER + MORT_SUMMER_COTS) ;
IND_REL_MORT_ANNUAL_CYCLONES = 100*IND_MORT_ANNUAL_CYCLONES./(COVER_WINTER(:,:,1:(end-1)) + IND_GROWTH_SUMMER + MORT_SUMMER_COTS) ;
% figure; bins = [-100:5:10] ; subplot(1,2,1); hist(REL_MORT_ANNUAL_BLEACHING(:),bins) ;subplot(1,2,2); hist(REL_MORT_ANNUAL_CYCLONES(:),bins)
% 
% min(REL_MORT_ANNUAL_BLEACHING(:))
% min(REL_MORT_ANNUAL_CYCLONES(:))
% 
% I=find(isnan(REL_MORT_ANNUAL_COTS)==1)
% I=find(isnan(REL_MORT_ANNUAL_CYCLONES)==1)
% I=find(isnan(REL_MORT_ANNUAL_BLEACHING)==1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOW AVERAGE ACROSS SIMULATIONS (n=40) FOR EXPORT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MORT_ANNUAL_COTS = squeeze(mean(IND_MORT_ANNUAL_COTS,1));
MORT_ANNUAL_CYCLONES = squeeze(mean(IND_MORT_ANNUAL_CYCLONES,1));
MORT_ANNUAL_BLEACHING = squeeze(mean(IND_MORT_ANNUAL_BLEACHING,1));
% figure; bins = [-100:5:10] ; 
% subplot(1,3,1); hist(MORT_ANNUAL_COTS(:),bins); [min(MORT_ANNUAL_COTS(:)) max(MORT_ANNUAL_COTS(:))]
% subplot(1,3,2); hist(MORT_ANNUAL_CYCLONES(:),bins); [min(MORT_ANNUAL_CYCLONES(:)) max(MORT_ANNUAL_CYCLONES(:))]
% subplot(1,3,3); hist(MORT_ANNUAL_BLEACHING(:),bins); [min(MORT_ANNUAL_BLEACHING(:)) max(MORT_ANNUAL_BLEACHING(:))]

REL_MORT_ANNUAL_COTS = squeeze(mean(IND_REL_MORT_ANNUAL_COTS,1));
REL_MORT_ANNUAL_CYCLONES = squeeze(mean(IND_REL_MORT_ANNUAL_CYCLONES,1));
REL_MORT_ANNUAL_BLEACHING = squeeze(mean(IND_REL_MORT_ANNUAL_BLEACHING,1));
% figure; bins = [-100:5:10] ; 
% subplot(1,3,1); hist(REL_MORT_ANNUAL_COTS(:),bins); [min(REL_MORT_ANNUAL_COTS(:)) max(REL_MORT_ANNUAL_COTS(:))]
% subplot(1,3,2); hist(REL_MORT_ANNUAL_CYCLONES(:),bins); [min(REL_MORT_ANNUAL_CYCLONES(:)) max(REL_MORT_ANNUAL_CYCLONES(:))]
% subplot(1,3,3); hist(REL_MORT_ANNUAL_BLEACHING(:),bins); [min(REL_MORT_ANNUAL_BLEACHING(:)) max(REL_MORT_ANNUAL_BLEACHING(:))]

%% Mean values for each region
MEAN_ANNUAL_MORT = array2table([2008:1:2020]','VariableNames',{'Year'});

MEAN_ANNUAL_MORT.Bl_GBR = round(weighted_mean(MORT_ANNUAL_BLEACHING, area_w, select.GBR),2);
MEAN_ANNUAL_MORT.Bl_NORTH = round(weighted_mean(MORT_ANNUAL_BLEACHING, area_w, select.North),2);
MEAN_ANNUAL_MORT.Bl_CENTER = round(weighted_mean(MORT_ANNUAL_BLEACHING, area_w, select.Centre),2);
MEAN_ANNUAL_MORT.Bl_SOUTH = round(weighted_mean(MORT_ANNUAL_BLEACHING, area_w, select.South),2);

MEAN_ANNUAL_MORT.Cy_GBR = round(weighted_mean(MORT_ANNUAL_CYCLONES, area_w, select.GBR),2);
MEAN_ANNUAL_MORT.Cy_NORTH = round(weighted_mean(MORT_ANNUAL_CYCLONES, area_w, select.North),2);
MEAN_ANNUAL_MORT.Cy_CENTER = round(weighted_mean(MORT_ANNUAL_CYCLONES, area_w, select.Centre),2);
MEAN_ANNUAL_MORT.Cy_SOUTH = round(weighted_mean(MORT_ANNUAL_CYCLONES, area_w, select.South),2);

MEAN_ANNUAL_MORT.Co_GBR = round(weighted_mean(MORT_ANNUAL_COTS, area_w, select.GBR),2);
MEAN_ANNUAL_MORT.Co_NORTH = round(weighted_mean(MORT_ANNUAL_COTS, area_w, select.North),2);
MEAN_ANNUAL_MORT.Co_CENTER = round(weighted_mean(MORT_ANNUAL_COTS, area_w, select.Centre),2);
MEAN_ANNUAL_MORT.Co_SOUTH = round(weighted_mean(MORT_ANNUAL_COTS, area_w, select.South),2);

% Extract bleaching mortality in the northern area of the central region
select456 = find(GBR_REEFS.Sector==4 | GBR_REEFS.Sector==5 | GBR_REEFS.Sector==6);
Bl_sector456 = round(weighted_mean(MORT_ANNUAL_BLEACHING, area_w, select456),2);

% Mean values for each region
MEAN_ANNUAL_REL_MORT = array2table([2008:1:2020]','VariableNames',{'Year'});

MEAN_ANNUAL_REL_MORT.Bl_GBR = round(weighted_mean(REL_MORT_ANNUAL_BLEACHING, area_w, select.GBR),2);
MEAN_ANNUAL_REL_MORT.Bl_NORTH = round(weighted_mean(REL_MORT_ANNUAL_BLEACHING, area_w, select.North),2);
MEAN_ANNUAL_REL_MORT.Bl_CENTER = round(weighted_mean(REL_MORT_ANNUAL_BLEACHING, area_w, select.Centre),2);
MEAN_ANNUAL_REL_MORT.Bl_SOUTH = round(weighted_mean(REL_MORT_ANNUAL_BLEACHING, area_w, select.South),2);

MEAN_ANNUAL_REL_MORT.Cy_GBR = round(weighted_mean(REL_MORT_ANNUAL_CYCLONES, area_w, select.GBR),2);
MEAN_ANNUAL_REL_MORT.Cy_NORTH = round(weighted_mean(REL_MORT_ANNUAL_CYCLONES, area_w, select.North),2);
MEAN_ANNUAL_REL_MORT.Cy_CENTER = round(weighted_mean(REL_MORT_ANNUAL_CYCLONES, area_w, select.Centre),2);
MEAN_ANNUAL_REL_MORT.Cy_SOUTH = round(weighted_mean(REL_MORT_ANNUAL_CYCLONES, area_w, select.South),2);

MEAN_ANNUAL_REL_MORT.Co_GBR = round(weighted_mean(REL_MORT_ANNUAL_COTS, area_w, select.GBR),2);
MEAN_ANNUAL_REL_MORT.Co_NORTH = round(weighted_mean(REL_MORT_ANNUAL_COTS, area_w, select.North),2);
MEAN_ANNUAL_REL_MORT.Co_CENTER = round(weighted_mean(REL_MORT_ANNUAL_COTS, area_w, select.Centre),2);
MEAN_ANNUAL_REL_MORT.Co_SOUTH = round(weighted_mean(REL_MORT_ANNUAL_COTS, area_w, select.South),2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4) Shelf-position specific metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-- WHOLE GBR
select_reefs = find(GBR_REEFS.KarloShelf==1 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.GBR_inn = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.GBR_inn = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.GBR_inn = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==2 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.GBR_mid = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.GBR_mid = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.GBR_mid = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==3 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.GBR_out = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.GBR_out = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.GBR_out = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

%-- NORTHERN
select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==1 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.NORTH_inn = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.NORTH_inn = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.NORTH_inn = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==2 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.NORTH_mid = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.NORTH_mid = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.NORTH_mid = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find((GBR_REEFS.Sector==1|GBR_REEFS.Sector==2|GBR_REEFS.Sector==3) & GBR_REEFS.KarloShelf==3 & GBR_REEFS.LAT<lat_cutoff);
MEAN_TRAJECTORIES.NORTH_out = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.NORTH_out = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.NORTH_out = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

%-- CENTRAL
select_reefs = find(GBR_REEFS.KarloShelf==1&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
MEAN_TRAJECTORIES.CENTER_inn = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.CENTER_inn = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.CENTER_inn = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==2&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
MEAN_TRAJECTORIES.CENTER_mid = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.CENTER_mid = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.CENTER_mid = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==3&(GBR_REEFS.Sector==4|GBR_REEFS.Sector==5|GBR_REEFS.Sector==6|GBR_REEFS.Sector==7|GBR_REEFS.Sector==8));
MEAN_TRAJECTORIES.CENTER_out = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.CENTER_out = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.CENTER_out = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

%-- SOUTHERN
select_reefs = find(GBR_REEFS.KarloShelf==1&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
MEAN_TRAJECTORIES.SOUTH_inn = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.SOUTH_inn = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.SOUTH_inn = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==2&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
MEAN_TRAJECTORIES.SOUTH_mid = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.SOUTH_mid = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.SOUTH_mid = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);

select_reefs = find(GBR_REEFS.KarloShelf==3&(GBR_REEFS.Sector==9|GBR_REEFS.Sector==10|GBR_REEFS.Sector==11));
MEAN_TRAJECTORIES.SOUTH_out = weighted_mean(Coral_tot.M, area_w, select_reefs);
MEAN_ANNUAL_ABS_CHANGE.SOUTH_out = weighted_mean(ANNUAL_ABS_CHANGE, area_w, select_reefs);
MEAN_ANNUAL_REL_CHANGES.SOUTH_out = weighted_mean(ANNUAL_REL_CHANGE, area_w, select_reefs);


%% Only save total recruits, juveniles etc.
total_nb_coral_recruits = squeeze(sum(coral_recruits,4));
% total_nb_juveniles = squeeze(sum(nb_juveniles,4));
% total_nb_adol_5cm = squeeze(sum(nb_adol_5cm,4));
total_coral_larval_supply = squeeze(sum(coral_larval_supply,4));


%% EXPORT NEW CALCULATIONS
writetable(MEAN_TRAJECTORIES,'EXPORT_MEAN_TRAJECTORIES.csv')
writetable(MEAN_ANNUAL_ABS_CHANGE,'EXPORT_ANNUAL_ABS_CHANGES.csv')
writetable(MEAN_ANNUAL_REL_CHANGES,'EXPORT_ANNUAL_REL_CHANGES.csv')
writetable(MEAN_ANNUAL_MORT,'EXPORT_ANNUAL_MORT.csv')
writetable(MEAN_ANNUAL_REL_MORT,'EXPORT_ANNUAL_REL_MORT.csv')

clearvars -except ANNUAL_CORAL_COVER_fin ANNUAL_CORAL_COVER_ini ANNUAL_ABS_CHANGE ANNUAL_REL_CHANGE ...
area_w lat_cutoff MEAN_ANNUAL_ABS_CHANGE MEAN_ANNUAL_MORT MEAN_ANNUAL_REL_CHANGES MEAN_ANNUAL_REL_MORT...
select weighted_mean years Coral_tot Coral_sp COTS_densities COTS_mantatow CURRENT_RUBBLE_COVER GROWTH_SUMMER GROWTH_WINTER...
IND_MORT_ANNUAL_BLEACHING IND_MORT_ANNUAL_COTS IND_MORT_ANNUAL_CYCLONES IND_REL_MORT_ANNUAL_BLEACHING IND_REL_MORT_ANNUAL_COTS IND_REL_MORT_ANNUAL_CYCLONES...
IND_GROWTH_SUMMER IND_GROWTH_WINTER...
outfilename coral_cover_tot total_nb_coral_recruits total_nb_juveniles total_nb_adol_5cm total_coral_larval_supply...
coral_cover_lost_bleaching coral_cover_lost_cyclones coral_cover_lost_COTS...
coral_cover_per_taxa
% coral_cover_per_taxa nb_juveniles nb_adol_5cm coral_recruits coral_larval_supply
% MEAN_TRAJECTORIES MORT_ANNUAL_BLEACHING MORT_ANNUAL_COTS MORT_ANNUAL_CYCLONES REL_MORT_ANNUAL_BLEACHING REL_MORT_ANNUAL_COTS REL_MORT_ANNUAL_CYCLONES

save(outfilename)
