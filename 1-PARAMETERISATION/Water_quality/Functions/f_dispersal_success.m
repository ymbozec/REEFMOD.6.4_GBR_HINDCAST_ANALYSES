function [S] = f_dispersal_success(M)

dim_sector = size(M,3);
dim_splitspawn = size(M,4);
S = NaN(size(M));

for i=1:dim_sector
    
    for j=1:dim_splitspawn
        
        SSC = M(:,:,i,j); 
        FERTIL = exp(4.579 - 0.010*SSC)/exp(4.579); %relative to max
        FERTIL(FERTIL>1)=1;
        FERTIL(FERTIL<0)=0;
        
        SETTL = (99.571 - 10.637*log(SSC+1))/99.571; %relative to max
        SETTL(SETTL>1)=1;
        SETTL(SETTL<0)=0;
        
        S(:,:,i,j) = FERTIL.*SETTL;
        
    end
    
end