%__________________________________________________________________________
%
% Populate for each run/reef/time step the associated value of the predictors
% of subsequent coral growth for the glm built in ANALYSIS_DRIVERS.R
%
% Produces the csv file 'DATA_DRIVER_ANALYSIS.csv' with ~3.5 millions rows
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________

load('REEF_SSC_6m.mat')
load('GBR_REEF_POLYGONS.mat')
load('R0_HINDCAST_GBR.mat')

reef_ID = GBR_REEFS.KarloID;

coral_cover_tot = sum(coral_cover_per_taxa,4);

COVER_CHANGE2 = coral_cover_tot(:,:,2:end) - coral_cover_tot(:,:,1:(end-1));
GROWTH = COVER_CHANGE2 + sum(coral_cover_lost_bleaching,4) + sum(coral_cover_lost_cyclones,4) + sum(coral_cover_lost_COTS,4);

%% PREDICTORS
CCOVER = coral_cover_tot(:,:,1:(end-1));
SAND = nongrazable(:,:,ones(1,NB_TIME_STEPS));

% CONNECTIVITY
settings_CONNECTIVITY % Script can be found in REEFMOD.6.4_GBR/settings
EXTERNAL_SUPPLY = ones(size(reef_ID,1),1);
EXTERNAL_SUPPLY_adj = EXTERNAL_SUPPLY;

HabitatKm2 = log(GBR_REEFS.HabitatAreaKm2+1);

NB_CONNECT = NaN(size(reef_ID,1),size(CONNECT,2));

for k = 1:size(CONNECT,2)
    
    % Proportion of external supply
    C = 1-diag(ones(1,size(reef_ID,1),1));
    tmp=sum(CONNECT(k).ACROPORA.*C,1)./sum(CONNECT(k).ACROPORA,1);
    tmp(tmp<0.01)=0.01;
    EXTERNAL_SUPPLY = EXTERNAL_SUPPLY.*tmp';
       
    % Number of connections
    CONNECT_ONES = spones(CONNECT(k).ACROPORA);
    NB_CONNECT(:,k) = sum(CONNECT_ONES.*C,1)';
end

LSUPPLY = full(EXTERNAL_SUPPLY.^(1/size(CONNECT,2)));
LSUPPLY = transp(LSUPPLY(:,ones(40,1))); 
LSUPPLY = LSUPPLY(:,:,ones(1,NB_TIME_STEPS));

NB_CONNECT = mean(NB_CONNECT,2);
NB_CONNECT = transp(NB_CONNECT(:,ones(40,1))); 
NB_CONNECT = NB_CONNECT(:,:,ones(1,NB_TIME_STEPS));

% WATER QUALITY DRIVERS
settings_WATER_QUALITY % Script can be found in REEFMOD.6.4_GBR/settings
POP_REPRO = ones(size(reef_ID,1),1);
POP_GROWTH_summer = POP_REPRO;
POP_GROWTH_winter = POP_REPRO;
POP_SURVIV = POP_REPRO;

for k = 1:8 % 8 years of WQ
    
    POP_REPRO = POP_REPRO .* REEF_POP(k).CORAL_larvae_production;
    POP_GROWTH_summer = POP_GROWTH_summer .* REEF_POP(k).CORAL_juvenile_growth(:,1);
    POP_GROWTH_winter = POP_GROWTH_winter .* REEF_POP(k).CORAL_juvenile_growth(:,2);
    POP_SURVIV = POP_SURVIV .* REEF_POP(k).CORAL_recruit_survival;
   
end

WQrepro = POP_REPRO.^(1/k);
WQ2a = POP_GROWTH_summer.^(1/k);
WQ2b = POP_GROWTH_winter.^(1/k);
WQjuv = (WQ2a.*WQ2b).^(1/2);
WQrecruit = POP_SURVIV.^(1/k);

WQrepro = transp(WQrepro(:,ones(40,1)));
WQrepro = WQrepro(:,:,ones(1,NB_TIME_STEPS));

WQjuv = transp(WQjuv(:,ones(40,1)));
WQjuv = WQjuv(:,:,ones(1,NB_TIME_STEPS));

WQrecruit = transp(WQrecruit(:,ones(40,1)));
WQrecruit = WQrecruit(:,:,ones(1,NB_TIME_STEPS));

% Composite metrics
WQ = WQrepro.*WQjuv.*WQrecruit;

% RUBBLE
RUBB = rubble(:,:,1:(end-1));
% to use the average amount of rubble over one simulation:
RUBB = squeeze(mean(RUBB,3));
RUBB = RUBB(:,:,ones(1,NB_TIME_STEPS));

% RECOVER SSC FROM WQ_chronology (index of the WQ layer (1 to 8)
chronology = repmat([6 6 7 7 8 8 1 1 2 2 3 3 4 4 5 5 6 6 ],1,META.nb_time_steps);
chronology = chronology(1:META.nb_time_steps);
SSC0 = REEF_SSC_6m(:,chronology(1));

for t=2:META.nb_time_steps
    SSC0 = [SSC0 REEF_SSC_6m(:,chronology(t))];
end

SSC1 = mean(SSC0,2);
SSC = transp(SSC1(:,ones(40,1)));
SSC = SSC(:,:,ones(1,NB_TIME_STEPS));

% INIT
INITCCOVER = coral_cover_tot(:,:,1);
INITCCOVER = INITCCOVER(:,:,ones(1,NB_TIME_STEPS));

% ATTRIBUTES
SHELF = transp(GBR_REEFS.KarloShelf(:,ones(40,1))); 
SHELF = SHELF(:,:,ones(1,NB_TIME_STEPS));

SECTOR = transp(GBR_REEFS.Sector(:,ones(40,1))); 
SECTOR = SECTOR(:,:,ones(1,NB_TIME_STEPS));

REGION = GBR_REEFS.Sector;
REGION(REGION<4)=1; % North
REGION(REGION>8)=3; % Centre
REGION(REGION>3)=2; % South
REGION = transp(REGION(:,ones(40,1))); 
REGION = REGION(:,:,ones(1,NB_TIME_STEPS));

select_step = 3; %select from 2009 onward to reduce influence of initialisation
GROWTH = GROWTH(:,:,select_step:end);
CCOVER = CCOVER(:,:,select_step:end);
SAND = SAND(:,:,select_step:end);
LSUPPLY = LSUPPLY(:,:,select_step:end);
NB_CONNECT = NB_CONNECT(:,:,select_step:end);
WQ = WQ(:,:,select_step:end);
WQrepro = WQrepro(:,:,select_step:end);
WQjuv = WQjuv(:,:,select_step:end);
WQrecruit = WQrecruit(:,:,select_step:end);
RUBB = RUBB(:,:,select_step:end);
INITCCOVER = INITCCOVER(:,:,select_step:end);
SECTOR = SECTOR(:,:,select_step:end);
REGION = REGION(:,:,select_step:end);
SHELF = SHELF(:,:,select_step:end);
SSC = SSC(:,:,select_step:end);

%% POPULATE THE DATA TABLE FOR EXPORT (to R)
X0 = [GROWTH(:) CCOVER(:) 100*SAND(:) LSUPPLY(:) NB_CONNECT(:) ...
    WQ(:) WQrepro(:) WQjuv(:) WQrecruit(:) RUBB(:) INITCCOVER(:) REGION(:) SECTOR(:) SHELF(:) SSC(:)]; 
EXPORT = array2table(single(round(X0,3)),'VariableNames',{'Growth','Coral','Sand','Connect','Nb_connect',...
    'WQ','WQrepro','WQjuv','WQrecruit','Rubble','InitCoral','Region','Sector','Shelf','SSC'});

writetable(EXPORT,'DATA_DRIVER_ANALYSIS.csv') % May 14, 2021

NEW_X = [ squeeze(LSUPPLY(1,:,1))' squeeze(NB_CONNECT(1,:,1))' squeeze(WQrepro(1,:,1))' squeeze(WQjuv(1,:,1))' squeeze(WQrecruit(1,:,1))' squeeze(REGION(1,:,1))' squeeze(SECTOR(1,:,1))' squeeze(SHELF(1,:,1))']; 
EXPORT2 = array2table(single(round(NEW_X,3)),'VariableNames',{'Connect','Nb_connect','WQrepro','WQjuv','WQrecruit','Region','Sector','Shelf'});

writetable(EXPORT2,'DATA_DRIVER_SIMPLE.csv')
