#__________________________________________________________________________
#
# ANALYSIS OF CHANGES IN COMMUNITY COMPOSITION
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 05/2021
#__________________________________________________________________________

rm(list=ls())
graphics.off()

library(RSvgDevice)
library(ggplot2); library(plotrix) ; library(ggthemes)
library(viridis)
library(viridisLite)
library(splines)
library(ggpubr)
library(R.matlab)
library(ade4)
library(factoextra)

# library(mgcv); library(ecospat)

setwd('/home/ym/REEFMOD/REEFMOD.6.3_GBR_FINAL/3-HINDCAST')

# IMPORT DATA GENERATED FROM HINDCAST_TRAJECTORIES.m
DATA = read.table("DATA_COMPO_ANALYSIS.csv", header=T, sep=",")
# DATA = read.table("DATA_COVER_ANALYSIS.csv", header=T, sep=",") # (give the same result than COMPO)

head(DATA)

ShelfRegion = paste(DATA$Shelf,DATA$Region)
ShelfRegion[ShelfRegion=="1 1"]= "North_Inshore"
ShelfRegion[ShelfRegion=="1 2"]= "Centre_Inshore"
ShelfRegion[ShelfRegion=="1 3"]= "South_Inshore"
ShelfRegion[ShelfRegion=="2 1"]= "North_Midshelf"
ShelfRegion[ShelfRegion=="2 2"]= "Centre_Midshelf"
ShelfRegion[ShelfRegion=="2 3"]= "South_Midshelf"
ShelfRegion[ShelfRegion=="3 1"]= "North_Outer"
ShelfRegion[ShelfRegion=="3 2"]= "Centre_Outer"
ShelfRegion[ShelfRegion=="3 3"]= "South_Outer"

YearShort = paste("'", substr(DATA$Year,3,4),sep='')

##################### ALL REEFS ##################### 
# FUNCTION FOR PLOTTING THE COA
f_plot_COA = function(COA, pointsize)
{
  plot(COA$li, pch=19, cex=pointsize, col='grey', xlab='')
  # lines(c(0,0),c(-2,2),lty='dashed') ; lines(c(-2,2),c(0,0),lty='dashed')
  # points(COA$co,pch=19,cex=2,col='limegreen')
  # text(COA$co, labels=c('acro_arbo','acro_plate','acro_corym','pocillo','sm_mix','lg_mass'))
}

f_plot_scatter = function(COA, X, pointsize)
{

  plot(COA$li, pch=19, cex=pointsize, col='grey', xlab='')
  # lines(c(0,0),c(-2,2),lty='dashed') ; lines(c(-2,2),c(0,0),lty='dashed')
  
  list_factor = levels(as.factor(X))
  coord = data.frame(x=rep(NA, length(list_factor)),y=rep(NA, length(list_factor)), lab=rep(NA, length(list_factor)))
  
  for (i in 1:length(list_factor))
  {
  locate_level = which(as.factor(X)==list_factor[i])
  coord$x[i]=mean(COA$li[locate_level,1])
  coord$y[i]=mean(COA$li[locate_level,2])
  coord$lab[i]=list_factor[i]
  }
  points(coord$x,coord$y, pch=19,cex=1,col='limegreen')
  text(coord$x,coord$y, labels=list_factor)
  s.class(COA$li[,1:2],fac=as.factor(X),grid=F, cellipse=1.5,cstar = 0, cpoint = 0, add.plot=T)
}
  
##################### PER REGION ##################### 

pointsize = 0 ; svg("COMM_COMPO_0.svg", height = 8, width = 8)
pointsize = 0.5 ; svg("COMM_COMPO_1.svg", height = 8, width = 8)

par(mfrow=c(3,3), pty='s', mar=c(1,1,1,1))

SELECT = which(DATA$Region==1)
COA1 = dudi.coa(DATA[SELECT,5:10],scannf = FALSE, nf = 2)
f_plot_COA(COA1, pointsize)
f_plot_scatter(COA1, YearShort[SELECT], pointsize)
f_plot_scatter(COA1, DATA$Shelf[SELECT], pointsize)

SELECT = which(DATA$Region==2)
COA2 = dudi.coa(DATA[SELECT,5:10],scannf = FALSE, nf = 2)
f_plot_COA(COA2, pointsize)
f_plot_scatter(COA2, YearShort[SELECT], pointsize)
f_plot_scatter(COA2, DATA$Shelf[SELECT], pointsize)

SELECT = which(DATA$Region==3)
COA3 = dudi.coa(DATA[SELECT,5:10],scannf = FALSE, nf = 2)
f_plot_COA(COA3, pointsize)
f_plot_scatter(COA3, YearShort[SELECT], pointsize)
f_plot_scatter(COA3, DATA$Shelf[SELECT], pointsize)

dev.off()
