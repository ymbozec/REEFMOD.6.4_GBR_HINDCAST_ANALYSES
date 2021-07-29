#__________________________________________________________________________
#
# CALIBRATION PLOTS (Figure 2, Figure 3c,d, Figure S12)
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 09/2019
#__________________________________________________________________________

rm(list=ls())
graphics.off()

library(ggplot2); library(plotrix) ;
library(viridis)

## CALIBRATION RECRUITMENT
Trapon = read.table("Trapon_Juveniles.csv", header=TRUE, sep=",")
Emslie = read.table("Emslie_Recovery.csv", header=TRUE, sep=",")

OUTPUT_TOT_COVER = read.table("OUTPUT_TOT_COVER_new.csv", header=F, sep=",")
OUTPUT_JUV = read.table("OUTPUT_NB_JUV_new.csv", header=F, sep=",")

## CALIBRATION CYCLONE IMPACTS
COVER_BEFORE = read.table("OUTPUT_BEFORE_CYCL.csv", header=F, sep=",") #36 reefs, 40 replicates
COVER_AFTER = read.table("OUTPUT_AFTER_CYCL.csv", header=F, sep=",") #36 reefs, 40 replicates
CYCL_CAT = read.table("OUTPUT_CYCL_CAT.csv", header=F, sep=",") #36 reefs
AIMS_OBS = read.table("AIMS_LTMP_transects_calibration_cyclones.csv", header=T, sep=",") #36 reefs
AIMS_OBS_BEFORE = AIMS_OBS[AIMS_OBS$STORM_DATE=='BEFORE',]
AIMS_OBS_AFTER = AIMS_OBS[AIMS_OBS$STORM_DATE=='AFTER',]

# write.csv(AIMS_OBS_AFTER,file="TMPafter.csv",row.names=FALSE)
# write.csv(AIMS_OBS_BEFORE,file="TMPbefore.csv",row.names=FALSE)

## CALIBRATION COTS IMPACTS
LIZARD_CORAL = read.table("OUTPUT_LIZARD_CORAL.csv", header=F, sep=",") #40 replicates, 7 time steps
LIZARD_COTS = read.table("OUTPUT_LIZARD_COTS.csv", header=F, sep=",")  #40 replicates, 7 time steps

OBS_CORAL_LIZARD = c(32.16, 29.2, 27.3, 25.9, 25.9, 23.9, NaN, 22.4, 22.2)
OBS_COTS_LIZARD = c(0.775, 1.025, 0.945, 0.995, 0.855, 1.1, 0.825, 0.275, 0.07)
OBS_TIME_LIZARD = c(1996.8, 1996.9, 1997.1, 1997.4, 1997.9, 1998.1, 1998.5, 1998.9, 1999.1)

## CALIBRATION BLEACHING IMPACT
BLEACHING_COVERCHANGE = read.table("OUTPUT_BLEACHING_COVER_CHANGE.csv",header=T, sep=",") # simulate cover change (col2) for the observed DHW (col1)
BLEACHING_FREQCHANGE = read.table("OUTPUT_BLEACHING_FREQ_DISTRI.csv",header=T, sep=",") # Frequency (%) of reefs for different reef states
BLEACHING_COVERCHANGE_OBS = read.table('Hughes_cover_change.csv',header=T, sep=",")

## PLOTTING OPTIONS
color1 = "#3E498933"
color2 = rgb(150,150,150,100,maxColorValue=255)
color3 = rgb(255,140,0,100,maxColorValue=255)
colorCOTS = rgb(205,92,92,maxColorValue=255)
colorCOTSalpha = rgb(139,34,82,100,maxColorValue=255)

color_H1 = rgb(139,71,93,100,maxColorValue=255)
color_H2 = rgb(255,236,139,100,maxColorValue=255)
color_H3 = rgb(102,205,170,100,maxColorValue=255)

Op = "D"
palVir10 = viridis(10, Op, begin=0, end=1, alpha=1, dir=-1)

CexDotObs = 2.5 # magnification of dot markers for observations
CexDotMod = 2.5 # magnification of dot markers for model outputs
CexLab = 1.7 # magnifcation of axis labels
Cexaxis = 1.3
CexPanel = 2.25
SetMGP = c(2,0.5,0)
SetMAR1 = c(4.5,5.5,2.5,0.5) #bottom,left,top,right

#######################################
## PLOTS
#######################################

## 1.1. Calibration recovery #######################################

png("@Figure_2.png", height = 2200, width = 2200, units='px', pointsize=12, type='cairo-png',res=150 )
par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)

split.screen( figs = c( 3, 1 ) ,erase=T) # split screen in 3 rows -> screen 1, 2 and 3
split.screen( figs = c( 1, 2 ), screen = 1 ) # split screen 1 in 2 columns -> screen 4 and 5
split.screen( figs = c( 1, 3 ), screen = 2 ) # split screen 2 in 3 columns -> screen 6, 7 and 8
split.screen( figs = c( 1, 2 ), screen = 3 ) # split screen 3 in 2 columns -> screen 9 and 10

screen(4) ## 1.1. Recovery curves

    par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)

    T_start = 1;
    T_end = 35;
    years = seq(T_start,T_end,1)/2;
    offset = 4.75
    
    Y = t(OUTPUT_TOT_COVER[,T_start:T_end]); 
    step = 2
    select_steps = seq((T_start+step),T_end,by=step)

    matplot(years, Y,'l', lwd=1, lty=rep(1,ncol(Y)), col=rgb(61,71,135,100,maxColorValue=255), xlim=c(0,17), ylim=c(0,85), xaxt='n',yaxt='n',xlab='',ylab='')

    points(Emslie$Year-1993+offset, Emslie$CL, pch=21, bg='white', cex=CexDotObs)
    points(Emslie$Year-1993+offset, Emslie$CB, pch=19, cex=CexDotObs)
    
    axis(1, lwd=0, lwd.ticks=2, line=NA, las = 1, padj=0.5) ; 
    title(xlab= 'Time (yr)', line=3)
    axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) ; 
    title(ylab='Total coral cover (%)', line=3.5)
    mtext('A',side=3,line=0.5, outer=F, font=2, cex=CexPanel, adj=0)
    
      
screen(5) ## 1.2. Calibration juveniles
    
    par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)

    matplot(OUTPUT_TOT_COVER[,T_start:T_end], OUTPUT_JUV[,T_start:T_end], pch=19, xlim=c(0,82), ylim=c(0,15), col=color1, cex=CexDotMod,
         xaxt='n',yaxt='n', xlab='', ylab='')

    points(Trapon$CoralCover, Trapon$JuvDens, pch=21, bg='white', cex=CexDotObs)
    
    axis(1, lwd=0, lwd.ticks=2, line=NA, las = 1, padj=0.5) ; 
    title(xlab= 'Total coral cover (%)', line=3)
    axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) ; 
    title(ylab=expression(paste("Coral juvenile density (m"^"-2", ")")), line=3.5)
    mtext('B',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)


    # 2.1 Cyclones  ######################
    maxCover=c(70,50,50,50)
    PanelTitles = c('C','','')
    s=0
    for (i in c(1,2,4)) {
            s=s+1
            screen(5+s)
            par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)
            
            select_CAT = which(CYCL_CAT==i) 
            matplot(COVER_BEFORE[select_CAT,], COVER_AFTER[select_CAT,], pch=16 ,xlim=c(0,maxCover[i]), ylim=c(0,maxCover[i]),
                    col=color1, cex=CexDotMod, xaxt='n',yaxt='n', xlab='', ylab='')
            lines(c(0,maxCover[i]),c(0,maxCover[i]),lty='dashed')
            points(AIMS_OBS_BEFORE$AllCorals[select_CAT], AIMS_OBS_AFTER$AllCorals[select_CAT], pch=21, bg='white', cex=CexDotObs)
            
            axis(1,lwd=0,lwd.ticks=2, line=NA,las = 1, padj=0.5)
            title(xlab= 'Pre-cyclone cover (%)', line=3)
            axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) 
            title(ylab='Post-cyclone cover (%)', line=3.5)
            
            mtext(PanelTitles[s],side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)
            mtext(paste("Cat.", i, "cyclones"),side=3, line=-2, outer=FALSE, font=1, cex=1.5, adj=0.5)
      }

    # 3.1 Bleaching impacts  ######################
    screen(9)
    par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)
    
    barplot(t(as.matrix(BLEACHING_FREQCHANGE[,1:2])),beside=TRUE, col=c(color1,color3),
            ylim=c(0,40), xlab='',ylab='',xaxt='n',yaxt='n')
    X_bars = seq(1.5,21.5,by=3)
    X_labels = c('0 - 10','10 - 20','20 - 30','30 - 40','40 - 50','50 - 60','60 - 100')
    plotCI(X_bars,BLEACHING_FREQCHANGE[,3],uiw=BLEACHING_FREQCHANGE[,5], sfrac=0, pch=19, lwd=2, cex=2, add=T)
    plotCI(X_bars+1,BLEACHING_FREQCHANGE[,4],uiw=BLEACHING_FREQCHANGE[,6], sfrac=0, pch=19, lwd=2, cex=2, add=T)
    points(X_bars,BLEACHING_FREQCHANGE[,3],pch=21, bg=palVir10[8],cex=CexDotMod)
    points(X_bars+1,BLEACHING_FREQCHANGE[,4],pch=21, bg='DarkOrange',cex=CexDotMod)
    
    axis(1,lwd=0,lwd.ticks=0,at=X_bars+0.5, labels=X_labels,las = 1, line=0.5)
    axis(1,lwd=0,lwd.ticks=2,at=c(X_bars,22.5)-1, labels=FALSE, las = 1, padj=0.5)
    title(xlab= 'Coral cover (%)', line=3)
    axis(2,lwd=0,lwd.ticks=2,at=c(0,10,20,30,40),las = 1, hadj=1.25)
    title(ylab='Frequency (%)', line=3.5)      
    
    mtext('D',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)
    box(lwd=2)

    # 3.3 Bleaching impacts 2nd plot  ######################
    screen(10)
    par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)
    
    plot(BLEACHING_COVERCHANGE$DHW, BLEACHING_COVERCHANGE$CoverChange, pch=16, xlim=c(0,10.5), ylim=c(-100,10), 
         col=color1, cex=CexDotMod, xaxt='n', yaxt='n', xlab='', ylab='', xaxt='n', yaxt='n')
    points(BLEACHING_COVERCHANGE_OBS$DHW, BLEACHING_COVERCHANGE_OBS$CoverChange, pch=21, bg='white', cex=CexDotObs)
    
    axis(1, lwd=0, lwd.ticks=2, line=NA,las = 1, padj=0.5)
    title(xlab= 'DHW (°C-weeks)', line=3)
    axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) 
    title(ylab='Change in coral cover (%)', line=3.5)
    
    mtext('E',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)
    
    dev.off()

######## ######## ######## ######## ######## ######## ########
## 2) Calibration COTS impacts (COTS) ########################
######## ######## ######## ######## ######## ######## ########

years = c(1996.8, 1997, 1997.5, 1998, 1998.5, 1999, 1999.5)

svg("FIG_COTS_calibration.svg", height = 6, width = 12, pointsize=12)
par(mfrow=c(1,2),mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=Cexaxis)

# 2.1) COTS ######################
matplot(years, t(LIZARD_COTS), 'l', lty=rep(1,ncol(LIZARD_COTS)), xlim=c(1996.8,1999.5), ylim=c(0,1.5), 
        col=colorCOTSalpha, lwd=2, xaxt='n',yaxt='n', xlab='', ylab='')

lines(years,colMeans(LIZARD_COTS), col='black', lwd=4)
points(OBS_TIME_LIZARD, OBS_COTS_LIZARD, pch=21, bg='white', cex=CexDotObs)

axis(1,lwd=0,lwd.ticks=2,at=c(1997, 1998, 1999),labels=FALSE,line=NA,las = 1,padj=0.5)
axis(1,lwd=0,lwd.ticks=0,at=c(1997.5, 1998.5, 1999.5),labels=c("1997", "1998", '1999'),line=0.5,las = 1)
title(xlab= 'Years', line=3)
axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) ; 
title(ylab=expression(paste("CoTS density (200m"^"-2", ")")), line=3.5)
# mtext('C',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)

# 2.2) CORALS ######################
matplot(years, t(LIZARD_CORAL), 'l', lty=rep(1,ncol(LIZARD_CORAL)), xlim=c(1996.8,1999.5), ylim=c(0,40), col=color1, lwd=2,
        xaxt='n',yaxt='n', xlab='',ylab='')

lines(years,colMeans(LIZARD_CORAL), col='black', lwd=4)
points(OBS_TIME_LIZARD, OBS_CORAL_LIZARD, pch=21, bg='white', cex=CexDotObs)

axis(1,lwd=0,lwd.ticks=2,at=c(1997, 1998, 1999),labels=FALSE,line=NA,las = 1,padj=0.5)
axis(1,lwd=0,lwd.ticks=0,at=c(1997.5, 1998.5, 1999.5),labels=c("1997", "1998", '1999'),line=0.5,las = 1)
title(xlab= 'Years', line=3)
axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) ; 
title(ylab='Total coral cover (%)', line=3.5)
# mtext('D',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)

dev.off()