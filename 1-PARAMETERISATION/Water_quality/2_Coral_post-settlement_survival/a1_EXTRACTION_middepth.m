%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRIPT for the extraction of eReefs data layers 
% Yves-Marie Bozec, University of Queensland - Dec 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% First create vector of dates (text)
% NOTE: 
% 1) first layer available is December 2010 but spawning in 2010 was Oct-Nov
% 2) double check values on 01/12/10 because might be just zeros everywhere

% To read info on netCDF files type: 
% ncdisp('https://regional-models.ereefs.info/thredds/dodsC/GBR4_H2p0_B3p1_Cq3b_Dhnd/all/gbr4_bgc_all_simple_2011-10.nc')

months=flipud({
    '2018-10';'2018-09';'2018-08';'2018-07';'2018-06';'2018-05'; % winter 2018
    '2018-04';'2018-03';'2018-02';'2018-01';'2017-12';'2017-11'; % summer 2018
    '2017-10';'2017-09';'2017-08';'2017-07';'2017-06';'2017-05'; % winter 2017
    '2017-04';'2017-03';'2017-02';'2017-01';'2016-12';'2016-11'; % summer 2017
    '2016-10';'2016-09';'2016-08';'2016-07';'2016-06';'2016-05'; % winter 2016
    '2016-04';'2016-03';'2016-02';'2016-01';'2015-12';'2015-11'; % summer 2016
    '2015-10';'2015-09';'2015-08';'2015-07';'2015-06';'2015-05'; % winter 2015
    '2015-04';'2015-03';'2015-02';'2015-01';'2014-12';'2014-11'; % summer 2015
    '2014-10';'2014-09';'2014-08';'2014-07';'2014-06';'2014-05'; % winter 2014
    '2014-04';'2014-03';'2014-02';'2014-01';'2013-12';'2013-11'; % summer 2014
    '2013-10';'2013-09';'2013-08';'2013-07';'2013-06';'2013-05'; % winter 2013
    '2013-04';'2013-03';'2013-02';'2013-01';'2012-12';'2012-11'; % summer 2013
    '2012-10';'2012-09';'2012-08';'2012-07';'2012-06';'2012-05'; % winter 2012
    '2012-04';'2012-03';'2012-02';'2012-01';'2011-12';'2011-11'; % summer 2012
    '2011-10';'2011-09';'2011-08';'2011-07';'2011-06';'2011-05'; % winter 2011
    '2011-04';'2011-03';'2011-02';'2011-01';'2010-12'}); % summer 2011

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

    min_layer = 42;
    count_layer = 1; % number of layers to capture from min_layer (with 1 only capture min_layer)
    
    % Mark (Sep 2019): Don’t use TSS (which is a diagnostic variable), but sum all the others (including Dust). 
    % YM (Sept 2019): Don't use sand anymore because too big (100 micro)
    Mud_mineral = ncread(layer_name,'Mud-mineral',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]);  % in layer in kg m-3
    Mud_carbonate = ncread(layer_name,'Mud-carbonate',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]);  % in layer in kg m-3
    FineSed = ncread(layer_name,'FineSed',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]); % in layer in kg m-3
    Dust = ncread(layer_name,'Dust',[1 1 min_layer 1],[inf inf count_layer inf],[1 1 1 1]); % in layer in kg m-3
    
    DATA_middepth(m).month = months(m);
    DATA_middepth(m).SSC = squeeze(Mud_mineral(:,:,1,:))+squeeze(Mud_carbonate(:,:,1,:))+squeeze(FineSed(:,:,1,:))+squeeze(Dust(:,:,1,:));   

       
    clear Mud_mineral Mud_carbonate FineSed Dust    
end

save('EREEFS_GBR4_H2p0_B3p1_Cq3b_Dhnd_MIDDEPTH_SSC', 'DATA_middepth')


%% CANNOT SAVE DATA_middepth because larger than 2GB

% DATA_middepth_part1 = DATA_middepth(1:50);
% save('EREEFS_GBR4_middepth_v2p0_Chyd_PART1', 'DATA_middepth_part1')
% DATA_middepth_part2 = DATA_middepth(51:end);
% save('EREEFS_GBR4_middepth_v2p0_Chyd_PART2', 'DATA_middepth_part2')

