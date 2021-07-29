#__________________________________________________________________________
#
# ANALYSIS OF REEF RESILIENCE
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 04/2020
#__________________________________________________________________________

rm(list=ls())
graphics.off()

# library(RSvgDevice)
library(ggplot2); library(plotrix) ; library(ggthemes)
library(viridis)
library(viridisLite)
library(splines)
library(ggpubr)
library(R.matlab)

# Load data of simulated GROWTH over 6 month with predictors (the first 2 time steps excluded)
DRIVERS = read.table("DATA_DRIVER_ANALYSIS.csv", header=T, sep=",") 
head(DRIVERS)
nrow(DRIVERS) # 3806 reefs x 24 time steps x 40 runs = 3653760 model realisations

# Load the predictor values for each reef (ie, same value regardless time step and run)
MEANS = read.table("DATA_DRIVER_SIMPLE.csv", header=T, sep=",") 
head(MEANS)
nrow(MEANS) # 3806 'observations'

## TEMP: REDUCE THE SIZE OF DATA FOR MODEL EXPLORATION
# DRIVERS = DRIVERS[1:400000,];

######################################################
# VARIABLES TRANSFORMATION
######################################################
DRIVERS$Gnew = DRIVERS$Growth + 2


######################################################
# FINAL MODEL (from ANALYSIS.DRIVERS.m)
######################################################
Mf = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand + sqrt(Nb_connect) + sqrt(Connect)+ asin(WQrepro)), family=Gamma(link=log), data=DRIVERS)
100*(1-summary(Mf)$deviance/summary(Mf)$null.deviance) # R2=49.7

#######################################
# FOR SIMULATING GROWTH
#######################################
f.grow = function(M, maxTime, init_Coral, init_Rubble, X)
{
  # X is a dataframe of predictors (1 value each) with names that match the predictor list in M
  c = rep(0,maxTime+1)
  r = rep(0,maxTime+1)
  g = rep(0,maxTime+1)
  
  c[1]=init_Coral
  r[1]=init_Rubble
  
  for (i in 1:maxTime)
  {
    newX = cbind(data.frame('Coral'=c[i], 'Rubble'=r[i]), X)
    g[i]=predict(M,newX,type="response") - 2

    c[i+1] = c[i] + g[i]
    # r[i+1] = r[i]*(1-0.128)
    r[i+1]=r[i] # keep rubble constant to reproduce compensatory response
  }
  # return(data.frame('c'=c,'r'=r))
  return(c)
}


#######################################
# FOR SIMULATING DYNAMICS
#######################################
f.dynamics = function(MODEL, maxTime, init_Coral, init_Rubble, X, MORT)
{
  # X is a dataframe of predictors (1 value each) with names that match the predictor list in MODEL
  # MORT is the relative mortality due to bleaching+COTS+cyclones (negative proportions)
  
  # c = rep(0,maxTime+1)
  # r = rep(0,maxTime+1)
  # g = rep(0,maxTime+1)
  # 
  # c[1]=init_Coral
  # r[1]=init_Rubble
  
  c = array(NA,dim=c(length(init_Coral),maxTime+1))
  r = c
  g = c
  
  c[,1]=init_Coral
  r[,1]=init_Rubble
  
  for (t in 1:maxTime)
  {
    newX = cbind(data.frame('Coral'=c[,t], 'Rubble'=r[,t]), X)
    g[,t]=predict(MODEL,newX,type="response") - 2
    
    c[,t+1] = c[,t] + g[,t]
    # r[i+1] = r[i]*(1-0.128)
    r[,t+1]=r[,t] # keep rubble constant to reproduce compensatory response
    
    # Apply mortality after growth as in Reefmod
    c[,t+1] = c[,t+1] + MORT[,t]*c[,t+1]/100
  }
  # return(data.frame('c'=c,'r'=r))
  return(c)
}


## MEAN REEF PERFORMANCE (3806 reefs, 100 time steps, fixed mortality = mean for each stressor)
MEAN_MORT = readMat('MEAN_MORTALITIES_FOR_R.mat')

MeanMortBleach = MEAN_MORT[1][['MEAN.BLEACHING.MORT']]; dim(MeanMortBleach)
MeanMortCOTS = MEAN_MORT[2][['MEAN.COTS.MORT']]; dim(MeanMortCOTS)
MeanMortCycl = MEAN_MORT[3][['MEAN.CYCLONE.MORT']]; dim(MeanMortCycl)

init_Rubble = rep(11,3806)
CoralInit=rep(30,3806)
maxTime = 200 #number of 6months steps

EQUILIBRIA = array(data=NA,dim=c(3806,maxTime+1))

# 1) Calculate EQUILIBRIA based on actual WQ reef values
newX = data.frame('WQrepro'=MEANS$WQrepro,'WQjuv'=MEANS$WQjuv,'WQrecruit'=MEANS$WQrecruit,
                      'Nb_connect'=MEANS$Nb_connect,'Connect'=MEANS$Connect,'Sand'=rep(30,3806))

# 2) Calculate EQUILIBRIA based on a mini WQ
# SSC=1.2 # choosing here the 50 pctile as the maximum SSC under assumption of WQ improvement (improving the 50% poorest WQ)
# WQrepro_forced = exp(4.579-0.01*SSC)*(99.571-10.637*log(SSC+1))/(100*100)
# WQjuv_forced = 1 - 0.176*log(SSC+1)
# WQrecruit_forced = (1 - 1.88*0.001*SSC)^(180/40)
# 
# WQrepro = MEANS$WQrepro ; WQrepro[WQrepro<WQrepro_forced]=WQrepro_forced
# WQjuv = MEANS$WQjuv ; WQjuv[WQjuv<WQjuv_forced]=WQjuv_forced
# WQrecruit = MEANS$WQrecruit ; WQrecruit[WQrecruit<WQrecruit_forced]=WQrecruit_forced
# 
# newX = data.frame('WQrepro'=WQrepro,'WQjuv'=WQjuv,'WQrecruit'=WQrecruit,
#                   'Nb_connect'=MEANS$Nb_connect,'Connect'=MEANS$Connect,'Sand'=rep(25,3806))

# calculate mean annual total mortality (compounded)
MEAN_TOT_MORT_annual = -100 * (1 - (1+MeanMortBleach/100) * (1+MeanMortCOTS/100) * (1+MeanMortCycl/100))
MEAN_TOT_MORT_annual[which(MEAN_TOT_MORT_annual< -99)]=-99 # always leave 1% of intial cover
# transform annual into seasonal mortality (6 months)
MEAN_TOT_MORT_6month = -100*(1 - (1+MEAN_TOT_MORT_annual/100)^0.5)

MEAN_TOT_MORT_MATRIX=matrix(MEAN_TOT_MORT_6month,3806,maxTime)
EQUILIBRIA = f.dynamics(Mf, maxTime, CoralInit, init_Rubble, newX, MEAN_TOT_MORT_MATRIX)

# Check equilibrium has been reached at maxTime
plot(EQUILIBRIA[,maxTime-10],EQUILIBRIA[,maxTime+1],pch=19)
lines(c(0,maxTime),c(0,maxTime),col='red')


## Plot the simulations
years = seq(1,maxTime+1)/2
Y = t(EQUILIBRIA)

CexLab = 2 # magnifcation of axis labels
CexPanel = 2.25
SetMGP = c(2,0.5,0)
SetMAR1 = c(4.5,7,2.5,1) #bottom,left,top,right

png("@Figure_S16.png", height = 600, width = 800, units='px', pointsize=12, type='cairo-png',res=100 )
par(mgp=SetMGP, mar=SetMAR1, pty="m", tck=-0.015, lwd=2, las=1,'font.lab'=1, 'cex.lab'=CexLab, cex.axis=1.5)

#% 1) Same color for all trajectories
  my.alpha = 0.15
  matplot(years, Y,'l', lwd=1, lty=rep(1,ncol(Y)), col=rep(rgb(0.6445,0.1641,0.1641,my.alpha,max=1),ncol(Y)) ,ylim=c(0,80), xlim=c(0,max(years)), xaxt='n',yaxt='n',xlab='',ylab='')
points(max(years),80,pch=25,bg='black')
## 2) WQ associated color 
  # Op = "D"
  # palVir10 = viridis(10, Op, begin=0, end=1, alpha=1, dir=-1)
  # EDP = DRIVERS$WQ[1:3806]
  # reef_order = order(EDP,decreasing='T')
  # k = 2
  # cuts = 60
  # Z = viridis(cuts, Op, begin=0, end=1,alpha=0.06*k,dir=-1)[as.numeric(cut(EDP,breaks = cuts))]
  # matplot(years, Y[,reef_order],'l', lwd=1, lty=rep(1,ncol(Y)), col=Z[reef_order], ylim=c(0,80), xlim=c(0,max(years)), xaxt='n',yaxt='n',xlab='',ylab='')
  # 
  # # Add color bar for water quality impact
  # lut = viridis(cuts, Op, begin=0, end=1,alpha=1,dir=-1)
  # min = 0 ;   max = 1
  # scale = (length(lut)-1)/(max-min)/40
  # xleft = 1.5 ;   xright = xleft+0.5
  # ybottom = 25 ;   ytop = ybottom+40
  # 
  # for (i in 1:(length(lut)-1))   {    y = (i-1)/scale+ybottom
  #                                     rect(xleft,y,xright,(y+1/scale), col=lut[i], border=NA)  }
  # text(xright+0.5,ybottom,'0',cex=1.5)
  # text(xright+0.5,ytop,'1',cex=1.5)
  # text(xleft+0.25,ytop+7,'EDP',cex=2)

axis(1, lwd=0, lwd.ticks=2, line=NA, las = 1, padj=0.5) ;
title(xlab= 'Time (yr)', line=3)
axis(2, lwd=0, lwd.ticks=2, line=NA, las = 1, hadj=1.25) ;
title(ylab='Total coral cover (%)', line=3.5)
# mtext('A',side=3,line=0.5, outer=FALSE, font=2, cex=CexPanel, adj=0)
  
dev.off()

## EXPORT DATA FOR MAPPING IN MATLAB
writeMat('ALL_EQUILIBRIA_FROM_R.mat', EQUILIBRIA=EQUILIBRIA)
