%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRIPT for the extraction of eReefs data layers 
% Yves-Marie Bozec, University of Queensland - Sep 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% First create vector of dates (text)
% We only select potential spawning seasons
% NOTE: 
% 1) first layer available is December 2010 but spawning in 2010 was Oct-Nov
% 2) No spawning dates for summer 2018 (Oct-Dec 17) but we still extract the data

% To read info on netCDF files type: 
ncdisp('https://regional-models.ereefs.info/thredds/dodsC/GBR4_H2p0_B3p1_Cq3b_Dhnd/all/gbr4_bgc_all_simple_2011-10.nc')

months=flipud({                             
    '2017-12';'2017-11';'2017-10'; % summer 2018
    '2016-12';'2016-11';'2016-10'; % summer 2017
    '2015-12';'2015-11';'2015-10'; % summer 2016
    '2014-12';'2014-11';'2014-10'; % summer 2015
    '2013-12';'2013-11';'2013-10'; % summer 2014
    '2012-12';'2012-11';'2012-10'; % summer 2013
    '2011-12';'2011-11';'2011-10'});% summer 2012

for m=1:length(months)
    
    months(m)
    layer_name = ['https://regional-models.ereefs.info/thredds/dodsC/GBR4_H2p0_B3p1_Cq3b_Dhnd/all/gbr4_bgc_all_simple_' char(months(m)) '.nc'];

% Select the depth layers
%     #40 = -12.75m
%     #41 = -8.80m
%     #42 =  -5.55m 
%     #43 = -3m
%     #44 = -1.5m
%     #45 = -0.5m
%     #46 = 0.5m
%     #47 = 1.5m

    min_layer = 45; % (~surface)
    count_layer = 1; % number of layers to capture from min_layer (with 1 only capture min_layer)

    % Mark (Sep 2019): Don’t use TSS (which is a diagnostic variable), but sum all the others (including Dust). 
    % YM (Sept 2019): Don't use sand anymore (Sand-mineral + Sand-carbonate)anymore because particulate size too coarse (100 micro)
    Mud_mineral = ncread(layer_name,'Mud-mineral',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]);  % in layer in kg m-3
    Mud_carbonate = ncread(layer_name,'Mud-carbonate',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]);  % in layer in kg m-3
    FineSed = ncread(layer_name,'FineSed',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]); % in layer in kg m-3
    Dust = ncread(layer_name,'Dust',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]); % in layer in kg m-3
 
    DATA_surface(m).month = months(m);
    DATA_surface(m).Mud_mineral = squeeze(Mud_mineral(:,:,1,:));
    DATA_surface(m).Mud_carbonate = squeeze(Mud_carbonate(:,:,1,:));
    DATA_surface(m).FineSed = squeeze(FineSed(:,:,1,:));
    DATA_surface(m).Dust = squeeze(Dust(:,:,1,:));
       
    clear Mud_mineral Mud_carbonate FineSed Dust    
end

save('EREEFS_GBR4_H2p0_B3p1_Cq3b_Dhnd_SURFACE_SSC', 'DATA_surface')
