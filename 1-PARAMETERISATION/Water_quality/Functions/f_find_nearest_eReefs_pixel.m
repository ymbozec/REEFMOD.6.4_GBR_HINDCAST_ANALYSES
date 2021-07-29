function [select_pixel] = f_find_nearest_eReefs_pixel(LAT, LON, y_centre, x_centre, VAR)

        M_LAT = LAT*ones(size(y_centre));
        M_LON = LON*ones(size(x_centre));

        select_pixel=[];
        check=nan;
        
        DIST = distance(M_LAT,M_LON,y_centre,x_centre);
        
        while isnan(check)==1
            
            DIST(select_pixel)=[];
            
            [~,select_pixel]=min(DIST(:));
            
            check = VAR(select_pixel); % check if the selected pixel is actually land (NaN)
            % if NaN then loops again and will be remove from DIST so we
            % try with the next nearest pixel, and so on until we get a
            % numeric value from VAR 
            
        end