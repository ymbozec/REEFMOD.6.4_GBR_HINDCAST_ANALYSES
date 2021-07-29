%__________________________________________________________________________
%
% VALIDATION PLOTS
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 02/2021
%__________________________________________________________________________
clear

load('LTMP_Transect2Tow_NEW.mat') % Linear model allowing to convert manta tow into tranect equivalent estimates
load('R0_HINDCAST_GBR.mat')
load('GBR_REEF_POLYGONS.mat')

% Rename Lizard Is reef to fit title
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

%% TRANSECT DATA
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

%% MANTA TOW DATA (up to 2020)
load('AIMS_MantaTow_1985_2020.mat')
select_MT = find(MantaTow_1985_2020.YearReefMod>=StartDate);
AIMS_MT0 = MantaTow_1985_2020(select_MT,[16 3 8 10]); % select AIMS shelf classification
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='I')=1;
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='M')=2;
AIMS_MT0.AIMS_SHELF(char(AIMS_MT0.SHELF)=='O')=3;
AIMS_MT0.SECTOR = GBR_REEFS.Sector(AIMS_MT0.KarloID);

AIMS_MT0.YearReefMod(AIMS_MT0.KarloID==1911)= AIMS_MT0.YearReefMod(AIMS_MT0.KarloID==1911)-0.5;

AIMS_MT = AIMS_MT0(:,[1 6 5 3 4]);
AIMS_MT.Properties.VariableNames = {'KarloID','SECTOR','AIMS_SHELF','YEAR','CCOVER'};

AIMS_MT_NEW = AIMS_MT;
AIMS_MT_NEW.CCOVER = predict(LTMP_Transect2Tow_Model, AIMS_MT.CCOVER);

%% Combine transects and manta tows
AIMS_ALL = [AIMS_MT_NEW ; AIMS_TR];
AIMS_ALL.OBS = ones(size(AIMS_ALL,1),1);

AIMS_ALL.OBS = ones(size(AIMS_ALL,1),1);
AIMS_ALL.REGION = 2*ones(size(AIMS_ALL,1),1);
AIMS_ALL.REGION(AIMS_ALL.SECTOR<4)=1;
AIMS_ALL.REGION(AIMS_ALL.SECTOR>=9)=3;

% Build design to count the number of observed years since 2009
DESIGN = varfun(@sum, AIMS_ALL(AIMS_ALL.YEAR>=2009,:),'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','SECTOR','YEAR'},'InputVariables','OBS');

NB_OBS_YEARS =  varfun(@sum, DESIGN,'GroupingVariables',{'KarloID','AIMS_SHELF','REGION','SECTOR'},'InputVariables','sum_OBS');


%% PLOT REEF by REEF FOR FIGURE 5
MIN_OBS = 6;

SELECTION = NB_OBS_YEARS(find(NB_OBS_YEARS.GroupCount>= MIN_OBS),:);

Y = coral_cover_tot;
Ymean = Coral_tot.M;

FontSizeLabelTicks = 9; FontSizeLabelAxes = 10; FontSizeLabelTitles = 11;

FolderName = '';
filename= [FolderName 'NEW_FIG_REEF'] ;

omean = @(x) mean(x,'omitnan');

i=0

%%  INDIVIDUAL PLOTS
for region=1:3
    
    for shelf=1:3
        
        myselect = SELECTION(SELECTION.AIMS_SHELF==shelf & SELECTION.REGION==region,:);
        
        if isempty(myselect)==0
            
            for n=1:size(myselect,1)
                
                i=i+1;

                traject_all = squeeze(Y(:,myselect.KarloID(n),:));
                traject_mean = Ymean(myselect.KarloID(n),:);
                
            OBS_MT0 = AIMS_MT_NEW(AIMS_MT_NEW.KarloID==myselect.KarloID(n),4:5); % transformed manta tows!
            OBS_TR0 = AIMS_TR(find(AIMS_TR.KarloID==myselect.KarloID(n)),4:5);
            
            OBS_MT = varfun(@mean, OBS_MT0, 'GroupingVariables','YEAR','InputVariables','CCOVER');
            OBS_TR = varfun(@mean, OBS_TR0, 'GroupingVariables','YEAR','InputVariables','CCOVER');
                
                hfig = figure;
                width=220; height=150; set(hfig,'color','w','units','points','position',[0,0,width,height])
                plot(years, traject_all,'Color',rgb('DarkGray')); hold on
                plot(years, traject_mean, 'Color',rgb('Crimson'),'LineWidth',2)
                line([2007.5 2007.5], [0 85],'LineStyle','--', 'LineWidth',1.5)
                plot(OBS_MT.YEAR, OBS_MT.mean_CCOVER,'o','MarkerSize',6, 'MarkerEdgeColor',rgb('Black'), 'MarkerFaceColor',rgb('White'),'LineWidth',0.5)
                plot(OBS_TR.YEAR,OBS_TR.mean_CCOVER,'o','MarkerSize',6, 'MarkerEdgeColor',rgb('Black'), 'MarkerFaceColor',rgb('Black'))                               
                
                title(GBR_REEFS.ReefName(GBR_REEFS.KarloID==myselect.KarloID(n)),'FontName', 'Arial', 'FontWeight','bold','FontSize',18)
                axis([2004.5 2020.5 0 85])
                
                set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
                yticks([0:20:80])
                xticks([2005:3:2020])
                
                IMAGENAME = [SaveDir filename '.' num2str(region) '.' num2str(shelf) '.' num2str(n)];
                print(hfig, ['-r' num2str(400)], [IMAGENAME '.png' ], ['-d' 'png'] );
                crop([IMAGENAME '.png'],0,20);
                close(hfig);
                
            end
        end
    end
end


%% MULTI PANELS
MIN_OBS = 6;

SELECTION = NB_OBS_YEARS(find(NB_OBS_YEARS.GroupCount>= MIN_OBS),:);

[~,J] = sort(GBR_REEFS.LAT(SELECTION.KarloID),'descend'); %sort by latitude
myselect = SELECTION(J,:);
ShelfName = ["(I)" "(M)" "(O)"];

%% PANELS A, B and C
nrows = 7;
ncols = 5;
n=0;
FolderName = '';
AllFileNames = {[FolderName 'FIG_S17A'];[FolderName 'FIG_S17B'];[FolderName 'FIG_S17C']};

for p=1:3
    
    hfig = figure;
    width=220*ncols; height=150*nrows; set(hfig,'color','w','units','points','position',[0,0,width,height])
    set(hfig, 'Resize', 'off')
    
    hh = tight_subplot(nrows,ncols,[0.03 0.02],0.05,0.12); %tight_subplot(Nh, Nw, gap, marg_h, marg_w)
    
    count=0;
    
    for g=1:nrows*ncols
        
        n = n+1;
        
        if n<=size(myselect,1)
            
            filename=AllFileNames{p};
            
            traject_all = squeeze(Y(:,myselect.KarloID(n),:));
            traject_mean = Ymean(myselect.KarloID(n),:);
            
            OBS_MT0 = AIMS_MT_NEW(AIMS_MT_NEW.KarloID==myselect.KarloID(n),4:5); % transformed manta tows!
            OBS_TR0 = AIMS_TR(find(AIMS_TR.KarloID==myselect.KarloID(n)),4:5);
            
            OBS_MT = varfun(@mean, OBS_MT0, 'GroupingVariables','YEAR','InputVariables','CCOVER');
            OBS_TR = varfun(@mean, OBS_TR0, 'GroupingVariables','YEAR','InputVariables','CCOVER');
                       
            count=count+1;
            axes(hh(count));
            
            plot(years, traject_all,'Color',rgb('DarkGray')); hold on
            plot(years, traject_mean, 'Color',rgb('Crimson'),'LineWidth',2)
            line([2007.5 2007.5], [0 85],'LineStyle','--', 'LineWidth',1.5)
            plot(OBS_MT.YEAR, OBS_MT.mean_CCOVER,'o','MarkerSize',6, 'MarkerEdgeColor',rgb('Black'), 'MarkerFaceColor',rgb('White'),'LineWidth',0.5)
            plot(OBS_TR.YEAR,OBS_TR.mean_CCOVER,'o','MarkerSize',6, 'MarkerEdgeColor',rgb('Black'), 'MarkerFaceColor',rgb('Black'))
            
            text(2018,75,ShelfName(myselect.AIMS_SHELF(n)),'FontName', 'Arial', 'FontWeight','bold','FontSize',11)
            title(GBR_REEFS.ReefName(GBR_REEFS.KarloID==myselect.KarloID(n)),'FontName', 'Arial', 'FontWeight','bold','FontSize',18)
            axis([2004.5 2020.5 0 85])
            
            set(gca,'Layer', 'top','FontName', 'Arial' ,'FontSize',FontSizeLabelTicks);
            yticks([0:20:80])
            xticks([2005:3:2020])

        else
            
            plot([],[])
            hh(count+1).XAxis.Parent.XAxis.Visible = 'off';
            hh(count+1).YAxis.Parent.YAxis.Visible = 'off';            
        end        
    end
    
    for j=[1 6 11 16 21 26 31]
        hh(j).YLabel.String={'Coral cover (%)';''};
        hh(j).YLabel.FontSize=11;
    end
    
    IMAGENAME = [filename];
    print(hfig, ['-r' num2str(150)], [IMAGENAME '.png' ], ['-d' 'png'] );
    crop([IMAGENAME '.png'],0,20);
    close(hfig);  
end
