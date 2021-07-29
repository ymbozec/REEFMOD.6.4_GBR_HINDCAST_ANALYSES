clear
load('EREEFS_physical.mat') %% Load bathymetry etc.
% load('GBR_hydro.mat')
load('GBR_ssc_surface.mat') % concentrations in kg.m-3 here (converted into mg/L below)
% S gives SSC average over 4 days following spawning
% M gives SSC average over Oct-Nov-Dec for all years

% select = find(botz<=0 & botz>=-50); % Spatial filters

%% 1) Assign seeding potential to each reef polygon of the GBR (3806)
% Requires to intersect each reef polygon with eReefs pixels then for a given reef, 
% average the value across the split spawning events in the corresponding sector (North, Centre, South)
load('GBR_centroids.mat')
load('GBR_sectors.mat')

nb_years = 6 ;
POTENT_SEED = nan(size(centr,1),3,nb_years);
REEF_SSC = nan(size(centr,1),3,nb_years);

% Simulate impacts of a hypothetical reduction of SSC
WQ_CONTROL = 1; filename = 'GBR_dispersal.mat'; % normal conditions
% WQ_CONTROL = 0.5; filename = 'GBR_dispersal_WQ50.mat'; % reduce SSC by 50% everywhere

check_SSC_nan = squeeze(S(1).SSC(:,:,1,1)); % nan where there is no water
% (works with first year and first spawning period)
    
for r = 1:size(centr,1)
    
    % Assign value to centroids from their nearest neighbouring pixel
    [select_pixel] = f_find_nearest_eReefs_pixel(centr(r,2), centr(r,1), y_centre, x_centre, check_SSC_nan);
    reef_sector = sectors(r);
    
    for k=1:nb_years
        
        for spawn = 1:3
            ssc = WQ_CONTROL * squeeze(S(k).SSC(:,:,reef_sector,spawn)) ;
            REEF_SSC(r,spawn,k) = nanmean(ssc(select_pixel))*1e6/1000; % converted in [mg L-1];
            
            POTENT_SEED(r,spawn,k) = f_dispersal_success(REEF_SSC(r,spawn,k));
            clear ssc wind curr temp
        end
    end
end


%% 2) Estimate potential for dispersal
load('GBR_acroyp.mat')
POTENT_DISPERSAL = nan(size(POTENT_SEED,1),nb_years);

% Carefully exclude 2013 from calculation since there is no associated
% connectivity matrix that year

for k=[1 2] % For 2011 and 2012
    
    conn_matrix = ACROYP(k+2).M; % k+2 here!
    N = nanmean(squeeze(POTENT_SEED(:,:,k)),2);
    select_nan = isnan(N);
    
    N(select_nan==1)=0;
    POTENT_DISPERSAL(:,k) = transp(transp(N)*conn_matrix./sum(conn_matrix,1));
    
    clear N conn_matrix
end

for k=[4 5 6]
    
    conn_matrix = ACROYP(k+1).M; % k+1 here!
    N = nanmean(squeeze(POTENT_SEED(:,:,k)),2);
    select_nan = isnan(N);
    
    N(select_nan==1)=0;
    POTENT_DISPERSAL(:,k) = transp(transp(N)*conn_matrix./sum(conn_matrix,1));
    
    clear N conn_matrix
end

clearvars -except filename centr POTENT_DISPERSAL POTENT_SEED POTENT_SEED_3M REEF_SSC REEF_WIND REEF_CURR REEF_TEMP select x_centre y_centre

filename
save(filename)
