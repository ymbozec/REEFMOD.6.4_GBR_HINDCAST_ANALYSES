%__________________________________________________________________________
%
% CALCULATE PREDICTION AND OBSERVATION ERRORS
% 
% Requires output files of ReefMod-GBR Hindcast
% 'R0_HINDCAST_GBR.mat' (~360MB) - hindcast with all stressors
% 'R1_HINDCAST_GBR.mat' (~360MB) - hindcast without cyclones
% 'R2_HINDCAST_GBR.mat' (~360MB) - hindcast without bleaching 
% 'R3_HINDCAST_GBR.mat' (~360MB) - hindcast without CoTS
% 'R4_HINDCAST_GBR.mat' (~360MB) - hindcast without WQ
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________


load('LTMP_Transect2Tow_NEW.mat') % Linear model allowing to convert manta tow into transect equivalent estimates

%% SELECT THE RELEVANT SCENARIO
load('R0_HINDCAST_GBR.mat'); filename = 'ALL_STRESSORS';
% load('R1_HINDCAST_GBR_NO_CYCL.mat'); filename = 'NO_CYCLONES';
% load('R2_HINDCAST_GBR_NO_BLEACH.mat'); filename = 'NO_BLEACHING';
% load('R3_HINDCAST_GBR_NO_COTS.mat'); filename = 'NO_COTS';
% load('R4_HINDCAST_GBR_NO_WQ.mat'); filename = 'NO_WQ';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('GBR_REEF_POLYGONS.mat')
GBR_REEFS.ReefName(GBR_REEFS.KarloID==1332)={'Lizard Island (14-116c)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==1762)={'Magnetic Island (No 2) (19-009c)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==1756)={'Orpheus Island (No 5) (18-049e)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==3759)={'Barren Reef (No 1) (23-031a)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==3703)={'Humpy Reef (23-016)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==3672)={'Middle Island Reef (23-010)'};
GBR_REEFS.ReefName(GBR_REEFS.KarloID==1728)={'Pelorus Reef (18-048)'};

% Initial step is end of 2007 (winter), first step is summer 2008, last step is end of 2017
years =  2007.5:0.5:2020.5 ;
coral_cover_tot = sum(coral_cover_per_taxa,4);
Coral_tot.M = squeeze(mean(coral_cover_tot, 1)) ;
Coral_tot.SD = squeeze(std(coral_cover_tot, 0, 1)) ;

%% Load AIMS LTMP observations for the whole GBR
StartDate = 2006;

%% TRANSECT data
load('AIMS_LTMP_Transect_sites.mat') % Now we use LTMP data per site
select_TR = find(LTMP_Transect_sites.YEAR_Reefmod>=StartDate);
AIMS_TR = LTMP_Transect_sites(select_TR,[19 20 3 18 11]); %19: REEF_ID, 17: SectorCode, 3: shelf (AIMS), 11: cover tot, 18: YEAR_Reefmod
AIMS_TR.Properties.VariableNames = {'KarloID','SECTOR','SHELF','YEAR','CCOVER'};

% Corrections of wrong year assignements (when start of a season falls
% between two surveys of the same campaign
AIMS_TR.YEAR(AIMS_TR.KarloID==805 & AIMS_TR.YEAR==2011)=2011.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==845 & AIMS_TR.YEAR==2006)=2006.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==930 & AIMS_TR.YEAR==2010.5)=2011;
AIMS_TR.YEAR(AIMS_TR.KarloID==944 & AIMS_TR.YEAR==2007.5)=2008;
AIMS_TR.YEAR(AIMS_TR.KarloID==944 & AIMS_TR.YEAR==2014.5)=2015;
AIMS_TR.YEAR(AIMS_TR.KarloID==1478 & AIMS_TR.YEAR==2014)=2014.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==1756 & AIMS_TR.YEAR==2014)=2014.5;
AIMS_TR.YEAR(AIMS_TR.KarloID==1332 & AIMS_TR.YEAR==2009)=2008.5;

% Delete Middle Island Reef because always surveyed with only 1 site (no variability)
AIMS_TR(AIMS_TR.KarloID==3672,:)=[];

% Rename shelf position
AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='I')=1;
AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='M')=2;
AIMS_TR.AIMS_SHELF(AIMS_TR.SHELF=='O')=3;
AIMS_TR = AIMS_TR(:,[1 2 6 4 5]);

%% AIMS manta tow data (up to 2020)
load('AIMS_MantaTow_1985_2020.mat')
select_MT = find(MantaTow_1985_2020.YearReefMod>=StartDate);
AIMS_MT0 = MantaTow_1985_2020(select_MT,[16 3 8 10]); % select AIMS shelf classification
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='I')=1;
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='M')=2;
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='O')=3;
AIMS_MT0.SECTOR = GBR_REEFS.Sector(AIMS_MT0.KarloID);
AIMS_MT = AIMS_MT0(:,[1 6 5 3 4]);
AIMS_MT.Properties.VariableNames = {'KarloID','SECTOR','AIMS_SHELF','YEAR','CCOVER'};

AIMS_MT_NEW = AIMS_MT;
AIMS_MT_NEW.CCOVER = predict(LTMP_Transect2Tow_Model, AIMS_MT.CCOVER);

%% Combine transects and manta tows
AIMS_ALL = [AIMS_MT_NEW ; AIMS_TR];

AIMS_ALL.OBS = ones(size(AIMS_ALL,1),1);
AIMS_ALL.REGION = 2*ones(size(AIMS_ALL,1),1);
AIMS_ALL.REGION(AIMS_ALL.SECTOR<4)=1;
AIMS_ALL.REGION(AIMS_ALL.SECTOR>=9)=3;

% Calculate mean cover per season
AIMS_ALL_mean = varfun(@mean, AIMS_ALL,'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','YEAR'},'InputVariables','CCOVER');
AIMS_ALL_sd = varfun(@std, AIMS_ALL,'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','YEAR'},'InputVariables','CCOVER');
AIMS_ALL_se = AIMS_ALL_sd(:,1:5);
AIMS_ALL_se.se_CCOVER = AIMS_ALL_sd.std_CCOVER./sqrt(AIMS_ALL_sd.GroupCount);


%% generate 40 new observations from sampling ditrbution
AIMS_ALL_NEW = AIMS_ALL_mean(1,:);
AIMS_ALL_NEW.Properties.VariableNames(6) = {'CCOVER'};

for k=1:size(AIMS_ALL_mean,1)
    
    ADD_ROWS = repmat(AIMS_ALL_mean(k,1:5),40,1);
    
    if AIMS_ALL_se.se_CCOVER(k)==0      
        %% Generates random equivalent fixed sites (transect) from empirical model
        % First reverse because was already converted into transect equivalent
        intercept = LTMP_Transect2Tow_Model.Coefficients.Estimate(1);
        slope = LTMP_Transect2Tow_Model.Coefficients.Estimate(2);
        
        C = (AIMS_ALL_mean.mean_CCOVER(k)-intercept)/slope;
        for j=1:40
            
            ADD_ROWS.CCOVER(j) = random(LTMP_Transect2Tow_Model,C);
        end      
    else
        %% Generates random fixed sites (transect) from normal distribution model
        ADD_ROWS.CCOVER = normrnd(AIMS_ALL_mean.mean_CCOVER(k), AIMS_ALL_se.se_CCOVER(k),40,1);       
    end
    
    AIMS_ALL_NEW = [AIMS_ALL_NEW ; ADD_ROWS];
    
end

AIMS_ALL_NEW = AIMS_ALL_NEW(2:end,:); % Delete the starter
AIMS_ALL_NEW.CCOVER(AIMS_ALL_NEW.CCOVER<0)=0; % force negative CC to 0
AIMS_ALL_NEW.CCOVER(AIMS_ALL_NEW.CCOVER>80)=80; % force negative CC to 0

% Build design to count the number of observed years since 2009
DESIGN = varfun(@sum, AIMS_ALL(AIMS_ALL.YEAR>=2009,:),'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','SECTOR','YEAR'},'InputVariables','OBS');

NB_OBS_YEARS =  varfun(@sum, DESIGN,'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','SECTOR'},'InputVariables','sum_OBS');

%% 1) SET UP COMPARISON OBS-PRED REEF by REEF
% This requires creating 40 observations for each surveyed reef-year to
% compare spread of observed vs modelled data
Y = coral_cover_tot;
Ymean = Coral_tot.M;
omean = @(x) mean(x,'omitnan');

FILL_years = array2table(years');
FILL_years.Properties.VariableNames={'YEAR'};
FILL_years.CCOVER = nan(size(FILL_years,1),1);
all_years = [2006 ; 2006.5 ;2007 ; years'];

MIN_OBS = 6; % minimum number of survey for each reef

SELECTION_REEF = NB_OBS_YEARS(find(NB_OBS_YEARS.GroupCount>= MIN_OBS),:);

SECTOR = []; REGION = []; AIMS_SHELF = []; REEF_ID = []; YEAR = []; 
CC_OBS_MEAN = []; CC_OBS = []; CC_PRED = [];
LOSS_BLEACHING = []; LOSS_CYCLONES = []; LOSS_COTS = [];
OBS_MEAN_REL_CHANGE = []; PRED_REL_CHANGE = [];

for region=1:3
    
    for shelf=1:3
        
        myselect = SELECTION_REEF(SELECTION_REEF.AIMS_SHELF==shelf & SELECTION_REEF.REGION==region,:);
        
        if isempty(myselect)==0
            
            for n=1:size(myselect,1)
                
                traject_all = squeeze(Y(:,myselect.KarloID(n),:));
                traject_mean = Ymean(myselect.KarloID(n),:);
                
                % Need to interpolate missing years
                OBS = AIMS_ALL_NEW(AIMS_ALL_NEW.KarloID==myselect.KarloID(n),:);
                OBS_means = varfun(@mean, OBS,'InputVariables','CCOVER','GroupingVariables','YEAR');

                All_devs_obs = [];
                All_devs_pred = [];
                
                CC_OBS_MEAN_previous = nan(40,1);
                CC_OBS_previous = nan(40,1);
                CC_PRED_previous = nan(40,1);
                
                for t=1:size(OBS_means,1)
                    y = OBS_means.YEAR(t);
                    J = find(OBS.YEAR==y);
                    
                    if length(J)==1 || y <2009 % ignore all observations before 2009 or when only one observation for a given year
                        continue
                    else
                        sector = AIMS_ALL.SECTOR(AIMS_ALL.KarloID==myselect.KarloID(n));
                        SECTOR = [SECTOR ; sector(1)*ones(40,1)];
                        REGION = [REGION ; region*ones(40,1)];
                        AIMS_SHELF = [AIMS_SHELF ; shelf*ones(40,1)];
                        REEF_ID = [REEF_ID ; double(myselect.KarloID(n))*ones(40,1)];
                        YEAR = [YEAR ; y*ones(40,1)];
                        CC_OBS_MEANtmp = OBS_means.mean_CCOVER(t)*ones(40,1);
                        CC_OBS_MEAN = [CC_OBS_MEAN ; CC_OBS_MEANtmp];
                        
                        % Add a selection of 40 observations per samped date
                        select_rnd_run = randsample(1:length(J),40) ; % randomly select runs without replacement
                        CC_OBStmp = OBS.CCOVER(J(select_rnd_run));
                        CC_OBStmp(CC_OBStmp<1)=1; % force to 1% to allow calculation of relative changes
                        CC_OBS = [CC_OBS ; CC_OBStmp];
                        
                        % Add ReefMod estimates
                        CC_PREDtmp = traject_all(:,find(years == y));
                        CC_PREDtmp(CC_PREDtmp<1)=1; % force to 1% to allow calculation of relative changes
                        CC_PRED = [CC_PRED ; CC_PREDtmp];
                        
                        if t>=2
                            
                            y2 = OBS_means.YEAR(t-1);
                            start_track = find(years == y2);
                            stop_track = find(years == y)-1;  
                            track_change = start_track:1:stop_track;
                            
                            LOSS_A = squeeze(sum(coral_cover_lost_bleaching(:,myselect.KarloID(n),track_change,:),4));
                            LOSS_B = squeeze(sum(coral_cover_lost_cyclones(:,myselect.KarloID(n),track_change,:),4));
                            LOSS_C = squeeze(sum(coral_cover_lost_COTS(:,myselect.KarloID(n),track_change,:),4));
                            
                            LOSS_BLEACHING = [LOSS_BLEACHING ; sum(mean(LOSS_A,1))*ones(40,1)];
                            LOSS_CYCLONES = [LOSS_CYCLONES ; sum(mean(LOSS_B,1))*ones(40,1)];
                            LOSS_COTS = [LOSS_COTS ; sum(mean(LOSS_C,1))*ones(40,1)];
                            
                            OBS_MEAN_REL_CHANGE = [OBS_MEAN_REL_CHANGE ; (CC_OBS_MEANtmp(1:40)-CC_OBS_MEAN_previous)./CC_OBS_MEAN_previous]; 
                            % this cannot work by taking paired observations at t and t-1, because
                            % they are independent, while paired (t-1/t) model predictions are not independent (same run).
                            % This would tend to overestimate the variability in observed relative changes
                            % So we just calculate the mean relative change                           
                            PRED_REL_CHANGE = [PRED_REL_CHANGE ; (CC_PREDtmp-CC_PRED_previous)./CC_PRED_previous];
                            
                        else
                            
                            LOSS_BLEACHING = [LOSS_BLEACHING ; nan(40,1)];
                            LOSS_CYCLONES = [LOSS_CYCLONES ; nan(40,1)];
                            LOSS_COTS = [LOSS_COTS ; nan(40,1)];
                            OBS_MEAN_REL_CHANGE = [OBS_MEAN_REL_CHANGE ; nan(40,1)];
                            PRED_REL_CHANGE = [PRED_REL_CHANGE ; nan(40,1)];
                            
                        end
                        
                        CC_OBS_MEAN_previous = CC_OBS_MEANtmp ;
                        CC_OBS_previous = CC_OBStmp ;
                        CC_PRED_previous = CC_PREDtmp;
                        
                    end
                end
            end
        end
    end
end


MYDATA_tmp = [REEF_ID SECTOR REGION AIMS_SHELF YEAR CC_OBS_MEAN CC_OBS CC_PRED...
    OBS_MEAN_REL_CHANGE PRED_REL_CHANGE LOSS_BLEACHING LOSS_CYCLONES LOSS_COTS];
MYDATA = array2table(MYDATA_tmp,'VariableNames', {'REEF_ID', 'SECTOR', 'REGION', 'AIMS_SHELF', 'YEAR', ...
    'CC_OBS_MEAN', 'CC_OBS', 'CC_PRED', 'OBS_MEAN_REL_CHANGE','PRED_REL_CHANGE','LOSS_BLEACHING', 'LOSS_CYCLONES', 'LOSS_COTS' });

clear OBS_MEAN_REL_CHANGE PRED_REL_CHANGE LOSS_BLEACHING LOSS_CYCLONES LOSS_COTS REEF_ID REGION AIMS_SHELF YEAR

%% 2) ASSESS THE FIT REEF BY REEF
SELECTION_REEF.DEV_OBS_lo = nan(size(SELECTION_REEF,1),1);
SELECTION_REEF.DEV_OBS_hi = nan(size(SELECTION_REEF,1),1);
SELECTION_REEF.DEV_MOD_lo = nan(size(SELECTION_REEF,1),1);
SELECTION_REEF.DEV_MOD_hi = nan(size(SELECTION_REEF,1),1);
SELECTION_REEF.MEAN_OVERLAP_MODvsOBS = nan(size(SELECTION_REEF,1),1);
SELECTION_REEF.MEAN_OVERLAP_OBSvsMOD = nan(size(SELECTION_REEF,1),1);

SELECTION_REEF_YEAR = SELECTION_REEF(1,1:4);
SELECTION_REEF_YEAR.overlap_MOD(1) = nan;
SELECTION_REEF_YEAR.MEAN_DEVIANCE(1) = nan;
SELECTION_REEF_YEAR.MEDIAN_DEVIANCE(1) = nan;
SELECTION_REEF_YEAR.Properties.VariableNames(1) = {'REEF_ID'};

% Define percentiles of error intervals
lo_pct = 5;
hi_pct = 95;

for reef = 1:size(SELECTION_REEF,1)
    
    K = find(MYDATA.REEF_ID == SELECTION_REEF.KarloID(reef));
    
    all_year_K = unique(MYDATA.YEAR(K));
    
    ALL_REEF_DEVIANCES = MYDATA(K(1:length(all_year_K)),1:5);
    ALL_REEF_DEVIANCES.YEAR = all_year_K;
    M_tmp = MYDATA(K,:);
    
    % Plot DEMO METHOD
    if contains(filename,'ALL_STRESSORS')==1 && SELECTION_REEF.KarloID(reef) == 1034 % Martin Reef
        
        traject_all = squeeze(Y(:,SELECTION_REEF.KarloID(reef),:));
        traject_mean = Ymean(SELECTION_REEF.KarloID(reef),:);
        PLOT_ERROR_METHOD
        
    end
    
    for t=1:length(all_year_K)
        
        J = find(MYDATA.YEAR(K)==all_year_K(t));
        ALL_REEF_DEVIANCES.DEV_OBS_lo(t) = prctile(M_tmp.CC_OBS(J) - M_tmp.CC_OBS_MEAN(J),lo_pct);
        ALL_REEF_DEVIANCES.DEV_OBS_hi(t) = prctile(M_tmp.CC_OBS(J) - M_tmp.CC_OBS_MEAN(J),hi_pct);
        
        ALL_REEF_DEVIANCES.DEV_MOD_lo(t) = prctile(M_tmp.CC_PRED(J) - M_tmp.CC_OBS_MEAN(J),lo_pct);
        ALL_REEF_DEVIANCES.DEV_MOD_hi(t) = prctile(M_tmp.CC_PRED(J) - M_tmp.CC_OBS_MEAN(J),hi_pct);
        
        
        % Calculate overlaps
        OBStmp = [ floor(ALL_REEF_DEVIANCES.DEV_OBS_lo(t)*100) : 1 : floor(ALL_REEF_DEVIANCES.DEV_OBS_hi(t)*100) ];
        MODtmp = [ floor(ALL_REEF_DEVIANCES.DEV_MOD_lo(t)*100) : 1 : floor(ALL_REEF_DEVIANCES.DEV_MOD_hi(t)*100) ];
        ALL_REEF_DEVIANCES.overlap_MOD(t) = sum(ismember(MODtmp,OBStmp))/length(MODtmp);
        ALL_REEF_DEVIANCES.overlap_OBS(t) = sum(ismember(OBStmp,MODtmp))/length(OBStmp);
       
        % Compare distributions of predicted and observed relative cover change
        ALL_REEF_DEVIANCES.REL_CHANGE_DEV_MOD_lo(t) = prctile(M_tmp.PRED_REL_CHANGE(J),lo_pct);
        ALL_REEF_DEVIANCES.REL_CHANGE_DEV_MOD_hi(t) = prctile(M_tmp.PRED_REL_CHANGE(J),hi_pct);
        
        ALL_REEF_DEVIANCES.OBS_MEAN_REL_CHANGE(t) = mean(M_tmp.OBS_MEAN_REL_CHANGE(J));
        ALL_REEF_DEVIANCES.SUM_LOSS(t)=mean(M_tmp.LOSS_BLEACHING(J)+M_tmp.LOSS_CYCLONES(J)+M_tmp.LOSS_COTS(J));
        
        LOW = ALL_REEF_DEVIANCES.REL_CHANGE_DEV_MOD_lo(t);
        HIG = ALL_REEF_DEVIANCES.REL_CHANGE_DEV_MOD_hi(t);
        x = ALL_REEF_DEVIANCES.OBS_MEAN_REL_CHANGE(t);
        
        if isnan(x)==1
            ALL_REEF_DEVIANCES.MATCH(t) = nan;
            ALL_REEF_DEVIANCES.IS_LOSS(t) = nan;
            ALL_REEF_DEVIANCES.IS_GAIN(t) = nan;
        else
            if x>=LOW && x<=HIG
                ALL_REEF_DEVIANCES.MATCH(t) = 1;
            else
                ALL_REEF_DEVIANCES.MATCH(t) = 0;
            end

            if ALL_REEF_DEVIANCES.SUM_LOSS(t)>=5
                ALL_REEF_DEVIANCES.IS_LOSS(t)=1;
                ALL_REEF_DEVIANCES.IS_GAIN(t)=0;
            else
                ALL_REEF_DEVIANCES.IS_LOSS(t)=0;
                ALL_REEF_DEVIANCES.IS_GAIN(t)=1;
            end
        end
        
        % Keep record of the mean deviance model-observation
        ALL_REEF_DEVIANCES.MEAN_DEVIANCE(t) = mean(M_tmp.CC_PRED(J)) - unique(M_tmp.CC_OBS_MEAN(J));
        ALL_REEF_DEVIANCES.MEDIAN_DEVIANCE(t) = median(M_tmp.CC_PRED(J)) - unique(M_tmp.CC_OBS_MEAN(J));

    end
    
    % Store results per reef and year
    SELECTION_REEF_YEAR = [SELECTION_REEF_YEAR ; ALL_REEF_DEVIANCES(:,[1:4 10 19 20])];
            
    % Store results per reef
    SELECTION_REEF.DEV_OBS_lo(reef) = prctile(MYDATA.CC_OBS(K) - MYDATA.CC_OBS_MEAN(K),lo_pct);
    SELECTION_REEF.DEV_OBS_hi(reef) = prctile(MYDATA.CC_OBS(K) - MYDATA.CC_OBS_MEAN(K),hi_pct);
    
    SELECTION_REEF.DEV_MOD_lo(reef) = prctile(MYDATA.CC_PRED(K) - MYDATA.CC_OBS_MEAN(K),lo_pct);
    SELECTION_REEF.DEV_MOD_hi(reef) = prctile(MYDATA.CC_PRED(K) - MYDATA.CC_OBS_MEAN(K),hi_pct);
    
    % Mean error
    SELECTION_REEF.MEDIAN_ERROR(reef) = prctile(MYDATA.CC_PRED(K) - MYDATA.CC_OBS_MEAN(K),50);
    SELECTION_REEF.MEAN_ERROR(reef) = mean(MYDATA.CC_PRED(K) - MYDATA.CC_OBS_MEAN(K));

    % Calculate mean overlap
    SELECTION_REEF.MEAN_OVERLAP_MODvsOBS(reef) = mean(ALL_REEF_DEVIANCES.overlap_MOD);
    SELECTION_REEF.MEAN_OVERLAP_OBSvsMOD(reef) = mean(ALL_REEF_DEVIANCES.overlap_OBS);

    % Calculate number of matches for predicted losses and gains
    SELECTION_REEF.MATCHED_LOSS(reef) = sum(ALL_REEF_DEVIANCES.MATCH(ALL_REEF_DEVIANCES.IS_LOSS==1));
    SELECTION_REEF.UNMATCHED_LOSS(reef) = nansum(ALL_REEF_DEVIANCES.IS_LOSS) - SELECTION_REEF.MATCHED_LOSS(reef);
    SELECTION_REEF.MATCHED_GAIN(reef) = sum(ALL_REEF_DEVIANCES.MATCH(ALL_REEF_DEVIANCES.IS_GAIN==1));
    SELECTION_REEF.UNMATCHED_GAIN(reef) = nansum(ALL_REEF_DEVIANCES.IS_GAIN) - SELECTION_REEF.MATCHED_GAIN(reef);
    
end

FindNaN = isnan(SELECTION_REEF.DEV_MOD_hi);
SELECTION_REEF = SELECTION_REEF(FindNaN==0,:);

FindNaN = isnan(SELECTION_REEF_YEAR.MEAN_DEVIANCE);
SELECTION_REEF_YEAR = SELECTION_REEF_YEAR(FindNaN==0,:);

prctile(SELECTION_REEF.MEAN_ERROR, [25 75])

% figure; histogram(SELECTION_REEF.MEAN_OVERLAP_MODvsOBS,[0:0.1:1])
% figure; histogram(ALL_REEFS_STAT.overlap_MOD,[0:0.1:1])
% figure; histogram(ALL_REEFS_STAT.MEAN_DEVIANCE,[-50:5:50])

% sum(SELECTION_REEF.MATCHED_LOSS)/(sum(SELECTION_REEF.MATCHED_LOSS)+sum(SELECTION_REEF.UNMATCHED_LOSS))
% sum(SELECTION_REEF.MATCHED_GAIN)/(sum(SELECTION_REEF.MATCHED_GAIN)+sum(SELECTION_REEF.UNMATCHED_GAIN))


%% Plot the global figure comparing percentiles deviances
if contains(filename,'ALL_STRESSORS')==1
    
%     select_metrics = 'median'
        select_metrics = 'mean'
    
    PLOT_ERROR_INTERVALS
    
    IMAGENAME = ['FIG_S18_ERROR_INTERVAL_REEFS_' select_metrics '_N' num2str(MIN_OBS)];
    print(hfig, ['-r' num2str(200)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,20);
    close(hfig);
end


%% Export DATA for further modelling
save(['DEVIANCES_' filename '.mat'], 'MYDATA')
