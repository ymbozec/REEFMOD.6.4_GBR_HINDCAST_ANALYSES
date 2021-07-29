clear
load('EREEFS_GBR4_H2p0_B3p1_Cq3b_Dhnd_SURFACE_SSC.mat');

%% NOTES
% 1) CarbSand and Mud have exact same values 
% 2) TSS does not correspond to the sum CarbSand + Mud + FineSed 
% so don't know what is it. Better to calculate the sum rather than using TSS

% Updates (Sep 2019):
% - Mark: Don’t use TSS (which is a diagnostic variable), but sum all the others (including Dust). There won’t be much Sand in the water column.
% - Mathieu: Sand and Mud have been split in 2, one with the colour of  carbonate (~ white)  and one with a more mineral colour (less white)
% If you sum up Sand-mineral + Sand-carbonate, You get the total Sand,  (same with Mud). The only difference is about their colour. 
% Then we have FineSed that has been split into  FineSed and Dust (so to get the “old” FineSed you need to sum up FineSed +Dust)
% Dust is smaller and sink much slower than fineSed and both are coming down the catchment
% - YM: nominal size of sand is to big (sink faster as well):
%     -> sand: 100 micro
%     -> mud: 30 micro
%     -> finesed: 30 micro
%     -> dust: 1 micro
%     In Adriana's experiments, particle size was 7.3 micro on average, with 95% < 20 micro

% So SSC = % SSC = Mud-mineral + Mud-carbonate + FineSed + Dust

dwindow = 3; % dwindow+1 is the length of the spawning period

for s = 1:6
    % Lat | Lon | sector | spawning event
    S(s).SSC = NaN(600,180,3,3);
    % Lat | Lon | sector
    M(s).SSC = NaN(600,180,3); 
end

%%
%       2011	2012	2013	2014	2015	2016	2017
% Oct   1       4       7       10      13  	16      19
% Nov   2       5       8       11      14      17      20
% Dec   3       6       9       12  	15      18  	21

%% summer 2012
S(1).Time_period = {'Spawning season 2011 (Summer 2011-12)'};
% Year | m | d | sector
% 2011	10	17	1
% 2011	11	15	1
% 2011	11	16	2
% 2011	11	17	3
m = 1 ; d = 17 ; s = 1 ; event = 1 ; S(1).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 2 ; d = 15 ; s = 1 ; event = 2 ; S(1).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 2 ; d = 16 ; s = 2 ; event = 2 ; S(1).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 2 ; d = 17 ; s = 3 ; event = 2 ; S(1).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);

% squeeze(S(1).SSC(select_lat,select_long,1,1));

%% summer 2013
S(2).Time_period = {'Spawning season 2012 (Summer 2012-13)'};
% Year | m | d | sector
% 2012	10	9	1
% 2012	10	9	2
% 2012	11	5	1
% 2012	11	8	2
% 2012	11	9	3
% 2012	12	5	3
m = 4 ; d = 9 ; s = 1 ; event = 1 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 4 ; d = 9 ; s = 2 ; event = 1 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 5 ; d = 5 ; s = 1 ; event = 2 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 5 ; d = 8 ; s = 2 ; event = 2 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 5 ; d = 9 ; s = 3 ; event = 2 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 6 ; d = 5 ; s = 3 ; event = 3 ; S(2).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);

% squeeze(S(2).SSC(select_lat,select_long,1,1));

%% summer 2014
S(3).Time_period = {'Spawning season 2013 (Summer 2013-14)'};
% Year | m | d | sector
% 2013	11	23	1
% 2013	11	21	2
% 2013	11	21	3
% 2013	12	23	3
m = 8 ; d = 23 ; s = 1 ; event = 1 ; S(3).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 8 ; d = 21 ; s = 2 ; event = 1 ; S(3).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 8 ; d = 21 ; s = 3 ; event = 1 ; S(3).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 9 ; d = 23 ; s = 3 ; event = 2 ; S(3).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);

%% summer 2015
S(4).Time_period = {'Spawning season 2014 (Summer 2014-15)'};
% Year | m | d | sector
% 2014	10	11	1
% 2014	11	12	1
% 2014	11	12	2
% 2014	11	14	3
% 2014	12	11	2
% 2014	12	12	3
m = 10 ; d = 11 ; s = 1 ; event = 1 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 11 ; d = 12 ; s = 1 ; event = 2 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 11 ; d = 12 ; s = 2 ; event = 2 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 11 ; d = 14 ; s = 3 ; event = 2 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 12 ; d = 11 ; s = 2 ; event = 3 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 12 ; d = 12 ; s = 3 ; event = 3 ; S(4).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);

%% summer 2016
S(5).Time_period = {'Spawning season 2015 (Summer 2015-16)'};
% Year | m | d | sector
% 2015	11	2	1
% 2015	11	2	2
% 2015	11	5	3
% 2015	11	30	1
% 2015	11	30	2
% 2015	11	30	3
m = 14 ; d = 2 ; s = 1 ; event = 1; S(5).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 14 ; d = 2 ; s = 2 ; event = 1; S(5).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 14 ; d = 5 ; s = 3 ; event = 1; S(5).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);

% Need separate calculation here to overlap end Nov with early Dec
TEMP1 = DATA_surface(14).Mud_mineral(:,:,30)+DATA_surface(14).Mud_carbonate(:,:,30)+...
    DATA_surface(14).FineSed(:,:,30)+DATA_surface(14).Dust(:,:,30);

TEMP1(:,:,2:4) = DATA_surface(15).Mud_mineral(:,:,1:3)+DATA_surface(15).Mud_carbonate(:,:,1:3)+...
    DATA_surface(15).FineSed(:,:,1:3)+DATA_surface(15).Dust(:,:,1:3);

s = 1 ; event = 2; S(5).SSC(:,:,s,event) = mean(TEMP1,3);
s = 2 ; event = 2; S(5).SSC(:,:,s,event) = mean(TEMP1,3);
s = 3 ; event = 2; S(5).SSC(:,:,s,event) = mean(TEMP1,3);

%% summer 2017
S(6).Time_period = {'Spawning season 2016 (Summer 2016-17)'};
% Year | m | d | sector
% 2016	11	17	1
% 2016	11	17	2
% 2016	12	20	1
% 2016	12	20	2
% 2016	12	20	3
m = 17 ; d = 17 ; s = 1 ; event = 1; S(6).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 17 ; d = 17 ; s = 2 ; event = 1; S(6).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 18 ; d = 20 ; s = 1 ; event = 2; S(6).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 18 ; d = 20 ; s = 2 ; event = 2; S(6).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);
m = 18 ; d = 20 ; s = 3 ; event = 2; S(6).SSC(:,:,s,event) = f_compile(DATA_surface(m),d,dwindow);


%% Average for the three spawning events for each year (for testing sensnitivity)
%       2011	2012	2013	2014	2015	2016	2017
% Oct   1       4       7       10      13  	16      19
% Nov   2       5       8       11      14      17      20
% Dec   3       6       9       12  	15      18  	21
% 
% M(1).SSC(:,:,1) = mean(DATA_surface(1).Mud,3)+mean(DATA_surface(1).CarbSand,3)+mean(DATA_surface(1).FineSed,3);
% M(1).SSC(:,:,2) = mean(DATA_surface(2).Mud,3)+mean(DATA_surface(2).CarbSand,3)+mean(DATA_surface(2).FineSed,3);
% M(1).SSC(:,:,3) = mean(DATA_surface(3).Mud,3)+mean(DATA_surface(3).CarbSand,3)+mean(DATA_surface(3).FineSed,3);
% 
% M(2).SSC(:,:,1) = mean(DATA_surface(4).Mud,3)+mean(DATA_surface(4).CarbSand,3)+mean(DATA_surface(4).FineSed,3);
% M(2).SSC(:,:,2) = mean(DATA_surface(5).Mud,3)+mean(DATA_surface(5).CarbSand,3)+mean(DATA_surface(5).FineSed,3);
% M(2).SSC(:,:,3) = mean(DATA_surface(6).Mud,3)+mean(DATA_surface(6).CarbSand,3)+mean(DATA_surface(6).FineSed,3);
% 
% M(3).SSC(:,:,1) = mean(DATA_surface(7).Mud,3)+mean(DATA_surface(7).CarbSand,3)+mean(DATA_surface(7).FineSed,3);
% M(3).SSC(:,:,2) = mean(DATA_surface(8).Mud,3)+mean(DATA_surface(8).CarbSand,3)+mean(DATA_surface(8).FineSed,3);
% M(3).SSC(:,:,3) = mean(DATA_surface(9).Mud,3)+mean(DATA_surface(9).CarbSand,3)+mean(DATA_surface(9).FineSed,3);
% 
% M(4).SSC(:,:,1) = mean(DATA_surface(10).Mud,3)+mean(DATA_surface(10).CarbSand,3)+mean(DATA_surface(10).FineSed,3);
% M(4).SSC(:,:,2) = mean(DATA_surface(11).Mud,3)+mean(DATA_surface(11).CarbSand,3)+mean(DATA_surface(11).FineSed,3);
% M(4).SSC(:,:,3) = mean(DATA_surface(12).Mud,3)+mean(DATA_surface(12).CarbSand,3)+mean(DATA_surface(12).FineSed,3);
% 
% M(5).SSC(:,:,1) = mean(DATA_surface(13).Mud,3)+mean(DATA_surface(13).CarbSand,3)+mean(DATA_surface(13).FineSed,3);
% M(5).SSC(:,:,2) = mean(DATA_surface(14).Mud,3)+mean(DATA_surface(14).CarbSand,3)+mean(DATA_surface(14).FineSed,3);
% M(5).SSC(:,:,3) = mean(DATA_surface(15).Mud,3)+mean(DATA_surface(15).CarbSand,3)+mean(DATA_surface(15).FineSed,3);
% 
% M(6).SSC(:,:,1) = mean(DATA_surface(16).Mud,3)+mean(DATA_surface(16).CarbSand,3)+mean(DATA_surface(16).FineSed,3);
% M(6).SSC(:,:,2) = mean(DATA_surface(17).Mud,3)+mean(DATA_surface(17).CarbSand,3)+mean(DATA_surface(17).FineSed,3);
% M(6).SSC(:,:,3) = mean(DATA_surface(18).Mud,3)+mean(DATA_surface(18).CarbSand,3)+mean(DATA_surface(18).FineSed,3);

% clear DATA_surface TEMP1 select_lat select_long ans d dwindow m s event
save('GBR_ssc_surface','S')
