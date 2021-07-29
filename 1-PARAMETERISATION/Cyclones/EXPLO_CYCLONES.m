load('Cyclones_Marji_2008-2017.mat')
load('Cyclones_Marji_2018_to_2019.mat')

% Merge the two datasets
GBR_PAST_CYCLONES = [GBR_PAST_CYCLONES Cyclones20182019(:,2:3)];

load('Cyclones_BoM_2008-2020.mat')
load('GBR_REEF_POLYGONS.mat')

list_years = 2008:1:2019;
list_cyclones = unique(CyclonesBoM20082020.DISTURBANCE_ID);


GBR_PAST_CYCLONES_NEW = zeros(size(GBR_PAST_CYCLONES));
GBR_PAST_TRACK_DIST = GBR_PAST_CYCLONES_NEW;

% Damage zones for left and right sides of track to a distance based on intensity
% category [switch sides due to GBR being in southern hemisphere],
% assuming that each higher level category contains damage zone
% distance for the weaker categories (e.g. a category 5 TC will include
% a zone for category 5, 4, 3, 2, and 1 that are combined into an overall damage zone).
% columns = Cat 1, 2, 3, 4, 5
% rows = left=1, right=2
DIST_THRESHOLDS = [23.6 16.4 10 12.6 17.4 ; 47.2 32.8 20 25.2 34.8 ];
% DIST_THRESHOLDS = mean(DIST_THRESHOLDS,1);

for y = 1:length(list_years) 
    
    y
    
    for n = 1:length(GBR_REEFS.KarloID)
        
        if GBR_PAST_CYCLONES(n,y) > 0
            
            reef = GBR_REEFS.KarloID(n);
            reef_LAT = GBR_REEFS.LAT(n);
            reef_LON = GBR_REEFS.LON(n);
            
            I = find(CyclonesBoM20082020.YEARYM==list_years(y));
                       
            TRACK_LAT = CyclonesBoM20082020.LAT(I);
            TRACK_LON = CyclonesBoM20082020.LON(I);
            DISTANCES = zeros(length(TRACK_LAT),1);
            SIDES = zeros(length(TRACK_LAT),1);
            CAT = CyclonesBoM20082020.SAFFIRYM(I);
            WIND = CyclonesBoM20082020.MAX_WIND_SPD(I);
            
            for t = 1:length(TRACK_LAT)-1
                
                DISTANCES(t,1) = lldistkm([reef_LAT reef_LON],[TRACK_LAT(t) TRACK_LON(t)]);
                AZ_CN = azimuth(TRACK_LAT(t), TRACK_LON(t), TRACK_LAT(t+1), TRACK_LON(t+1));
                AZ_CR = azimuth(TRACK_LAT(t), TRACK_LON(t), reef_LAT, reef_LON);
                SIDES(t,1) = AZ_CR - AZ_CN; % if >0, reef is on the right of the track

            end
            SIDES(SIDES<0)=1;
            SIDES(SIDES>0)=2;
            
            [~,rank] = sort(DISTANCES);
            SELECT = [DISTANCES(rank) CAT(rank) WIND(rank) SIDES(rank)];
            
            J = find(SELECT(:,1)<160 & isnan(SELECT(:,2))==0);
            
            if isempty(J)==0
                
                TRACK = SELECT(J,:);
                % Find the minimum distance to the track
                [Dmin, k_Dmin] = min(TRACK(:,1));
                Cat_Dmin = TRACK(k_Dmin,2);
                T = fliplr(DIST_THRESHOLDS(TRACK(k_Dmin,4),1:Cat_Dmin)); % flip the thresholds
                D = zeros(1,length(T));
                
                for k = 1:length(T)
                    D(k)=sum(T(k:end));
                end
                
                p = find(Dmin<D);
                
                if isempty(max(p))==0
                    GBR_PAST_CYCLONES_NEW(n,y) = max(p);
                    GBR_PAST_TRACK_DIST(n,y) = Dmin;
                else
                    GBR_PAST_CYCLONES_NEW(n,y) = 1;  % default category damage
                    GBR_PAST_TRACK_DIST(n,y) = Dmin; % record the minimum distance
                end
            else
                GBR_PAST_CYCLONES_NEW(n,y) = 1; % default category damage
                GBR_PAST_TRACK_DIST(n,y) = min(SELECT(:,1)); % just record the minimum distance to the track
            end
    
        end
    end
end

GBR_PAST_CYCLONES_NEW(isnan(GBR_PAST_CYCLONES_NEW)==1)=1;

figure;
c = 8;
subplot(2,c,1); hist(GBR_PAST_CYCLONES(:,2)); axis([0.5 4.5 0 1500]); title(num2str(list_years(2)))
subplot(2,c,c+1); hist(GBR_PAST_CYCLONES_NEW(:,2)); axis([0.5 4.5 0 1500]); title(num2str(list_years(2)))

subplot(2,c,2); hist(GBR_PAST_CYCLONES(:,3)); axis([0.5 4.5 0 1500]); title(num2str(list_years(3)))
subplot(2,c,c+2); hist(GBR_PAST_CYCLONES_NEW(:,3)); axis([0.5 4.5 0 1500]); title(num2str(list_years(3)))

subplot(2,c,3); hist(GBR_PAST_CYCLONES(:,4)); axis([0.5 4.5 0 1500]); title(num2str(list_years(4)))
subplot(2,c,c+3); hist(GBR_PAST_CYCLONES_NEW(:,4)); axis([0.5 4.5 0 1500]); title(num2str(list_years(4)))

subplot(2,c,4); hist(GBR_PAST_CYCLONES(:,7)); axis([0.5 4.5 0 1500]); title(num2str(list_years(7)))
subplot(2,c,c+4); hist(GBR_PAST_CYCLONES_NEW(:,7)); axis([0.5 4.5 0 1500]); title(num2str(list_years(7)))

subplot(2,c,5); hist(GBR_PAST_CYCLONES(:,8)); axis([0.5 4.5 0 1500]); title(num2str(list_years(8)))
subplot(2,c,c+5); hist(GBR_PAST_CYCLONES_NEW(:,8)); axis([0.5 4.5 0 1500]); title(num2str(list_years(8)))

subplot(2,c,6); hist(GBR_PAST_CYCLONES(:,10)); axis([0.5 4.5 0 1500]); title(num2str(list_years(10)))
subplot(2,c,c+6); hist(GBR_PAST_CYCLONES_NEW(:,10)); axis([0.5 4.5 0 1500]); title(num2str(list_years(10)))

subplot(2,c,7); hist(GBR_PAST_CYCLONES(:,11)); axis([0.5 4.5 0 1500]); title(num2str(list_years(11)))
subplot(2,c,c+7); hist(GBR_PAST_CYCLONES_NEW(:,11)); axis([0.5 4.5 0 1500]); title(num2str(list_years(11)))

subplot(2,c,8); hist(GBR_PAST_CYCLONES(:,11)); axis([0.5 4.5 0 1500]); title(num2str(list_years(12)))
subplot(2,c,c+8); hist(GBR_PAST_CYCLONES_NEW(:,11)); axis([0.5 4.5 0 1500]); title(num2str(list_years(12)))

r = 950 % Arlington reef
r = 3805 % Broomfield reef
r = 3723 % Lady musgrave
r = 3620 % Chinaman
r = 1835 % Havannah
r = 2632 % Gannett Cay Reef
r = 3062 % East Cay Reef
r = 3538 % U/N Reef (22-088a)
r = 2762 % Wade Reef (21-588)
r = 2672 % Turner Reef (21-562)
r = 3096 % U/N Reef (21-139)
r = 3160 % U/N Reef (21-245)

disp(GBR_REEFS.ReefName(r)) ; [list_years ; GBR_PAST_CYCLONES(r,:) ; GBR_PAST_CYCLONES_NEW(r,:) ; GBR_PAST_TRACK_DIST(r,:) ]

r = 910 ; [ list_years ; GBR_PAST_CYCLONES_NEW(r,1:12) ] % Agincourt 1
r = 1911 ; [ list_years ; GBR_PAST_CYCLONES_NEW(r,1:12) ] % Chicken
r = 1556 ; [ list_years ; GBR_PAST_CYCLONES_NEW(r,1:12) ] % Davies


%% EXPORT
% Add zeros for 2020 (no cyclones)
GBR_PAST_CYCLONES_NEW = [GBR_PAST_CYCLONES_NEW zeros(3806,1)];

save('GBR_cyclones_2008-2020_NEW.mat', 'GBR_PAST_CYCLONES_NEW')
