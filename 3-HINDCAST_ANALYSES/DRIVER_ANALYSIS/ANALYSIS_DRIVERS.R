#__________________________________________________________________________
#
# ANALYSIS OF DRIVERS OF SIMULATED GROWTH
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 01/2020
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
nrow(MEANS) # 3806 model realisations

## TEMP: REDUCE THE SIZE OF DATA FOR MODEL EXPLORATION
# DRIVERS = DRIVERS[1:400000,];

######################################################
# VARIABLES TRANSFORMATION
######################################################
DRIVERS$Gnew = DRIVERS$Growth + 2


######################################################
## CHECK DISTRIBUTIONS
######################################################
par(mfrow=c(3,3))
hist(DRIVERS$Growth,main='Net growth (%.step-1)')
hist(DRIVERS$Coral,main='Coral cover (%)')
hist(DRIVERS$Rubble,main='Rubble cover (%)')
hist(DRIVERS$Sand,main='Sand cover (%)')
hist(DRIVERS$Connect,main='Connectivity')
hist(DRIVERS$Nb_connect,main='Incoming connections')
hist(DRIVERS$WQrepro,main='WQrepro (coral repro)')
hist(DRIVERS$WQjuv,main='WQjuv (juv growth)')
hist(DRIVERS$WQrecruit,main='WQrecruit (recruit mort)')

######################################################
# CHECK TRANSFORMATIONS
######################################################
par(mfrow=c(2,4)) # Growth
x = DRIVERS$Gnew ; hist(x,main='',breaks=40)
x = sqrt(DRIVERS$Gnew) ; hist(x,main='',breaks=40)
x = log(1+DRIVERS$Gnew) ; hist(x,main='',breaks=40)
x = asin(DRIVERS$Gnew/100) ; hist(x,main='',breaks=40)

par(mfrow=c(2,4)) # Coral cover
hist(DRIVERS$Coral,main='Coral cover (%)')
hist(sqrt(DRIVERS$Coral),main='Coral cover (%)') #***
hist(log(1+DRIVERS$Coral),main='Coral cover (%)')
hist(asin(DRIVERS$Coral/100),main='Coral cover (%)')

par(mfrow=c(2,4)) # Rubble cover
hist(DRIVERS$Rubble,main='Rubble cover (%)')
hist(sqrt(DRIVERS$Rubble),main='Rubble cover (%)')
hist(log(1+DRIVERS$Rubble),main='Rubble cover (%)') #***
hist(asin(DRIVERS$Rubble/100),main='Rubble cover (%)')

par(mfrow=c(2,4)) # WQrepro = effects on coral reproduction
hist(DRIVERS$WQrepro,main='WQ coral repro')
hist(sqrt(DRIVERS$WQrepro),main='WQ coral repro')
hist(log(1+DRIVERS$WQrepro),main='WQ coral repro')
hist(asin(DRIVERS$WQrepro),main='WQ coral repro') #***

par(mfrow=c(2,4)) # WQjuv = effects on juvenile growth
hist(DRIVERS$WQjuv,main='WQ coral juv')
hist(sqrt(DRIVERS$WQjuv),main='WQ coral juv')
hist(log(1+DRIVERS$WQjuv),main='WQ coral juv')
hist(asin(DRIVERS$WQjuv),main='WQ coral juv') #***

par(mfrow=c(2,4)) # WQjuv = effects on recruit mortality
hist(DRIVERS$WQrecruit,main='WQ coral recruit')
hist(sqrt(DRIVERS$WQrecruit),main='WQ coral recruit')
hist(log(1+DRIVERS$WQrecruit),main='WQ coral recruit')
hist(asin(DRIVERS$WQrecruit),main='WQ coral recruit') #***

par(mfrow=c(2,4)) # Connectivity
hist(DRIVERS$Connect,main='External supply')
hist(sqrt(DRIVERS$Connect),main='External supply') #**
hist(log(1+DRIVERS$Connect),main='External supply')
hist(DRIVERS$Connect^(1/4),main='External supply') #***

par(mfrow=c(2,4)) # Connectivity
hist(DRIVERS$Nb_connect,main='Incoming connections')
hist(sqrt(DRIVERS$Nb_connect),main='Incoming connections') #***
hist(log(1+DRIVERS$Nb_connect),main='Incoming connections')
hist(DRIVERS$Nb_connect^(1/4),main='Incoming connections')

######################################################
## EXPLORE MODELS
######################################################


#############################  
##### MAIN EFFECTS COMPARISON
#############################  
# WQrepro = WQ repro
# WQjuv = WQ juv
# WQrecruit = WQ recruit

###############################  
##### 1) INDIVIDUAL EFFECTS
############################### 
# 
# PERCENT_DEVIANCE_IND = data.frame('Predictor'=rep(NaN,8), 'Pct_deviance'=rep(NaN,8))
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[1] ='Coral'
# PERCENT_DEVIANCE_IND$Pct_deviance[1] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~asin(WQjuv), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[2] ='WQ_juv'
# PERCENT_DEVIANCE_IND$Pct_deviance[2] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~asin(WQrecruit), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[3] ='WQ_recruit'
# PERCENT_DEVIANCE_IND$Pct_deviance[3] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~log(1+Rubble), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[4] ='Rubble'
# PERCENT_DEVIANCE_IND$Pct_deviance[4] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~Sand, family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[5] ='Sand'
# PERCENT_DEVIANCE_IND$Pct_deviance[5] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~sqrt(Nb_connect), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[6] ='Incoming_conn'
# PERCENT_DEVIANCE_IND$Pct_deviance[6] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~sqrt(Connect), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[7] ='External_supply'
# PERCENT_DEVIANCE_IND$Pct_deviance[7] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~asin(WQrepro), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE_IND$Predictor[8] ='WQ_repro'
# PERCENT_DEVIANCE_IND$Pct_deviance[8] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# PERCENT_DEVIANCE_IND$Pct_deviance = round(PERCENT_DEVIANCE_IND$Pct_deviance,1)

###############################  
##### 1) INDIVIDUAL EFFECTS ON INSHORE REEFS ONLY
############################### 
DRIVERS_IN = DRIVERS[which(DRIVERS$Shelf==1),]

PERCENT_DEVIANCE_IND_INSHORE = data.frame('Predictor'=rep(NaN,8), 'Pct_deviance'=rep(NaN,8))

M1 = glm(Gnew~poly(Coral,2,raw=T), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[1] ='Coral'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[1] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~asin(WQjuv), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[2] ='WQ_juv'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[2] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~asin(WQrecruit), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[3] ='WQ_recruit'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[3] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~log(1+Rubble), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[4] ='Rubble'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[4] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~Sand, family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[5] ='Sand'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[5] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~sqrt(Nb_connect), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[6] ='Incoming_conn'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[6] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~sqrt(Connect), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[7] ='External_supply'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[7] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

M1 = glm(Gnew~asin(WQrepro), family=Gamma(link=log), data=DRIVERS_IN)
PERCENT_DEVIANCE_IND_INSHORE$Predictor[8] ='WQ_repro'
PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance[8] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained

PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance = round(PERCENT_DEVIANCE_IND_INSHORE$Pct_deviance,1)

###############################  
##### 2) INTERACTIONS
############################### 
# PERCENT_DEVIANCE = data.frame('Predictor'=rep(NaN,8), 'Pct_deviance'=rep(NaN,8))
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[1] ='Coral'
# PERCENT_DEVIANCE$Pct_deviance[1] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):asin(WQjuv), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[2] ='WQ_juv'
# PERCENT_DEVIANCE$Pct_deviance[2] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):asin(WQrecruit), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[3] ='WQ_recruit'
# PERCENT_DEVIANCE$Pct_deviance[3] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):log(1+Rubble), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[4] ='Rubble'
# PERCENT_DEVIANCE$Pct_deviance[4] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):Sand, family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[5] ='Sand'
# PERCENT_DEVIANCE$Pct_deviance[5] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):sqrt(Nb_connect), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[6] ='Incoming_conn'
# PERCENT_DEVIANCE$Pct_deviance[6] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):sqrt(Connect), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[7] ='External_supply'
# PERCENT_DEVIANCE$Pct_deviance[7] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T):asin(WQrepro), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor[8] ='WQ_repro'
# PERCENT_DEVIANCE$Pct_deviance[8] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
# 
# PERCENT_DEVIANCE$Pct_deviance = round(PERCENT_DEVIANCE$Pct_deviance,1)
# 
# ###############################  
# ##### 3) INCREMENT GLOBAL MODEL
# ############################### 
# # WQrepro = WQ repro
# # WQjuv = WQ juv
# # WQrecruit = WQ recruit
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[1] ='Coral'
# PERCENT_DEVIANCE$Pct_deviance_incr[1] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance) #proportional deviance explained
#   
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):asin(WQjuv), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[2] ='WQ_juv'
# PERCENT_DEVIANCE$Pct_deviance_incr[2] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[3] ='WQ_recruit'
# PERCENT_DEVIANCE$Pct_deviance_incr[3] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit) + log(1+Rubble)), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[4] ='Rubble'
# PERCENT_DEVIANCE$Pct_deviance_incr[4] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[5] ='Sand'
# PERCENT_DEVIANCE$Pct_deviance_incr[5] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand + sqrt(Nb_connect)), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[6] ='Incoming_conn'
# PERCENT_DEVIANCE$Pct_deviance_incr[6] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand + sqrt(Nb_connect) + sqrt(Connect)), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[7] ='External_supply'
# PERCENT_DEVIANCE$Pct_deviance_incr[7] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# M1 = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand + sqrt(Nb_connect) + sqrt(Connect)+ asin(WQrepro)), family=Gamma(link=log), data=DRIVERS)
# PERCENT_DEVIANCE$Predictor_incr[8] ='WQrepro'
# PERCENT_DEVIANCE$Pct_deviance_incr[8] = 100*(1-summary(M1)$deviance/summary(M1)$null.deviance)
# 
# PERCENT_DEVIANCE$Pct_deviance_incr = round(PERCENT_DEVIANCE$Pct_deviance_incr,1)

######################################################
######################################################
# FINAL MODEL
######################################################
######################################################
Mf = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand +
          sqrt(Nb_connect) + sqrt(Connect)+ asin(WQrepro)), family=Gamma(link=log), data=DRIVERS)
100*(1-summary(Mf)$deviance/summary(Mf)$null.deviance)

## FINAL MODEL ON INSHORE REEFS
Mf_i = glm(Gnew~poly(Coral,2,raw=T) + poly(Coral,2,raw=T):(asin(WQjuv) + asin(WQrecruit)  + log(1+Rubble) + Sand + 
          sqrt(Nb_connect) + sqrt(Connect)+ asin(WQrepro)), family=Gamma(link=log), data=DRIVERS_IN)
100*(1-summary(Mf_i)$deviance/summary(Mf_i)$null.deviance)

# par(mfrow=c(1,1))
# plot(fitted(Mf), residuals(Mf)) ; abline(h=0,col='red')
# qqnorm(residuals(Mf)) ; qqline(residuals(Mf),lty=2);


# FOR SIMULATING GROWTH
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
    g[i]=predict(M,newX,type="response") - 2 # (with type='response' no need to back transform)

    c[i+1] = c[i] + g[i]
    # r[i+1] = r[i]*(1-0.128) # decaying rubble due to progressive cementation
    r[i+1]=r[i] # keep rubble constant to reproduce compensatory response
  }
  # return(data.frame('c'=c,'r'=r))
  return(c)
}

#######################################
# TEST MODEL SIMULATION
init_Coral = 1
init_Rubble = 11
Sand = 30
maxTime = 40
PREDS = data.frame('WQrepro'= 1,'WQjuv'= 1,'WQrecruit'= 1, 'Nb_connect'= 10,'Connect'=0.1,'Sand'=Sand)

MySimul1 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PREDS))
x11(); plot(MySimul1$X,MySimul1$Y,pch=19,ylim=c(0,100)); lines(c(0,maxTime),c(100-Sand,100-Sand))# TEST MODEL SIMULATION
# init_Coral = 5
# Init_Rubble = 5
# maxTime = 40
# PREDS = data.frame('WQrepro'= 1,'WQjuv'= 1,'WQrecruit'= 1, 'Nb_connect'= 10,'Connect'=0.1,'Sand'=25)
# 
# MySimul1 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PREDS))
# x11(); plot(MySimul1$X,MySimul1$Y,pch=19)

#######################################
## PLOTS
#######################################
graphics.off()

Op = "D" # select viridis scheme
cuts = 60

select = seq(1,length(DRIVERS$Coral),1)
# select =seq(1,100000) # temp for exploration

MyData = data.frame('X' = DRIVERS$Coral[select], 'Y' = DRIVERS$Growth[select], 
                    'Z' = DRIVERS$WQ[select], 'SSC' = DRIVERS$SSC[select], 'SAND' = DRIVERS$Sand[select])

## FIG A - Growth as a function of coral cover ##############################################
maxG = 10.8
minG = -1.65
maxCC = 82
k = 2

# I = order(DRIVERS$WQ[select],decreasing=T) # just re-order by decreasing WQ score for the plot (low WQ plotted last)
I = order(DRIVERS$SSC[select],decreasing=F) # just re-order by decreasing WQ score for the plot (low WQ plotted last)
# I = order(DRIVERS$Sand[select],decreasing=T) # just re-order by decreasing WQ score for the plot (low WQ plotted last)

# gg1 <- ggplot(MyData, aes(x=X[I], y=Y[I], color=Z[I])) +
gg1 <- ggplot(MyData, aes(x=X[I], y=Y[I], color=SSC[I])) +
# gg1 <- ggplot(MyData, aes(x=X[I], y=Y[I], color=SAND[I])) +
  geom_point(size=1) +
  scale_x_continuous(expand=c(0,0), limits=c(-1,maxCC)) +
  scale_y_continuous(expand=c(0,0), limits=c(minG,maxG)) +
  # scale_colour_viridis_c(alpha=0.1*k, option='D', begin=0, end=1, direction=-1,"PDP",limits=c(0, 1),guide="colourbar") +
  scale_colour_viridis_c(alpha=0.1*k, Op, begin=0, end=1, direction=1,"SSC (mg/L)",limits=c(0, 55),guide="colourbar") +
  # scale_colour_viridis_c(alpha=0.1*k, option='magma', begin=0, end=1, direction=1,"Ungrazable",limits=c(0, 50),guide="colourbar") +
  labs(x='Coral cover (%)', y='Coral growth (%cover per 6 month)') +
  theme_bw() +
  theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm"))+ #t,r,b,l
  theme(panel.border = element_rect(linetype = "solid", fill=NA, colour = "black", size=0.5))+
  theme(axis.text = element_text(size=10,color='black'))+
  theme(axis.title=element_text(size=14,color='black'))

## FIG B RECOVERY CURVES ~ SSC ##############################################
# Percentiles of SSC from Matlab (need to inverse labels)
# PRCTILE_SSC = data.frame('0pct'= 748.9235, '5pct' = 56.2638, '10pct' = 31.2019, '25pct'= 9.7963, 
#                          '50pct'= 1.2317, '75pct'= 0.4014, '90pct'= 0.1810, '95pct'= 0.1062, '100pct'= 0.0000000)

# ALL REEFS
# PRCTILE_SSC = data.frame('0pct'= 59.8015, '5pct' = 4.7623, '10pct' = 3.3651, '25pct'= 1.2393, 
#                          '50pct'= 0.1436, '75pct'= 0.0477, '90pct'= 0.0215, '95pct'= 0.0133, '100pct'= 0.0002)

# INSHORE REEFS ONLY
PRCTILE_SSC = data.frame('0pct'= 99.1636, '5pct' = 13.2396, '10pct' = 8.0177, '25pct'= 4.4532, 
                         '50pct'= 2.3349, '75pct'= 1.3115, '90pct'= 0.3122, '95pct'= 0.0826, '100pct'= 0.0013)

SSC = c(PRCTILE_SSC$X90pct, PRCTILE_SSC$X75pct, PRCTILE_SSC$X50pct,PRCTILE_SSC$X25pct, PRCTILE_SSC$X10pct, PRCTILE_SSC$X5pct)

SSC_names = c('10th pctile', '25th pctile', '50th pctile', '75th pctile', '90th pctile', '95th pctile')
SSC_names = paste(SSC_names,"=",round(SSC,1),"mg/L")

WQrepro = exp(4.579-0.01*SSC)*(99.571-10.637*log(SSC+1))/(100*100)
WQjuv = 1 - 0.176*log(SSC+1)
WQrecruit = (1 - 1.88*0.001*SSC)^(180/40)

Op = "D" # select viridis scheme
k=10;
maxTime = 60
maxCC = 79
init_Coral = 5
init_Rubble = median(DRIVERS$Rubble)
MyPalette2 =  viridis(cuts, Op, begin=0, end=1, alpha=0.1*k, direction=-1)
SSC_scale = seq(0.2,1, length=60)

PRED1 = data.frame('WQrepro'= WQrepro[1],'WQjuv'= WQjuv[1],'WQrecruit'= WQrecruit[1], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
PRED2 = data.frame('WQrepro'= WQrepro[2],'WQjuv'= WQjuv[2],'WQrecruit'= WQrecruit[2], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
PRED3 = data.frame('WQrepro'= WQrepro[3],'WQjuv'= WQjuv[3],'WQrecruit'= WQrecruit[3], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
PRED4 = data.frame('WQrepro'= WQrepro[4],'WQjuv'= WQjuv[4],'WQrecruit'= WQrecruit[4], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
PRED5 = data.frame('WQrepro'= WQrepro[5],'WQjuv'= WQjuv[5],'WQrecruit'= WQrecruit[5], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
PRED6 = data.frame('WQrepro'= WQrepro[6],'WQjuv'= WQjuv[6],'WQrecruit'= WQrecruit[6], 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))

MySimul1 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED1))
MySimul2 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED2))
MySimul3 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED3))
MySimul4 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED4))
MySimul5 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED5))
MySimul6 = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED6))

find_color1 = which(SSC_scale < WQrepro[1]*WQjuv[1]*WQrecruit[1])
find_color2 = which(SSC_scale < WQrepro[2]*WQjuv[2]*WQrecruit[2])
find_color3 = which(SSC_scale < WQrepro[3]*WQjuv[3]*WQrecruit[3])
find_color4 = which(SSC_scale < WQrepro[4]*WQjuv[4]*WQrecruit[4])
find_color5 = which(SSC_scale < WQrepro[5]*WQjuv[5]*WQrecruit[5])
find_color6 = which(SSC_scale < WQrepro[6]*WQjuv[6]*WQrecruit[6])

gg2 <- ggplot() + 
  geom_line(MySimul1, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color1[length(find_color1)]+1], size =1.25) +
  geom_line(MySimul2, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color2[length(find_color2)]+1], size =1.25) +
  geom_line(MySimul3, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color3[length(find_color3)]+1], size =1.25) +
  geom_line(MySimul4, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color4[length(find_color4)]+1], size =1.25) +
  geom_line(MySimul5, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color5[length(find_color5)]+1], size =1.25) +
  geom_line(MySimul6, mapping=aes(x=X/2, y=Y), color=MyPalette2[find_color6[length(find_color6)]+1], size =1.25) +
  scale_x_continuous(expand=c(0,0), limits=c(0,43)) +
  scale_y_continuous(expand=c(0,0), limits=c(0,maxCC)) +
  annotate(label = SSC_names[1], geom = "text", x = 1 + maxTime/2, y = MySimul1$Y[61]+0.75, size = 3.5, hjust=0 ) +
  annotate(label = SSC_names[2], geom = "text", x = 1 + maxTime/2, y = MySimul2$Y[61]+0.50, size = 3.5, hjust=0 ) +
  annotate(label = SSC_names[3], geom = "text", x = 1 + maxTime/2, y = MySimul3$Y[61]-0.25, size = 3.5, hjust=0 ) +
  annotate(label = SSC_names[4], geom = "text", x = 1 + maxTime/2, y = MySimul4$Y[61]-0.25, size = 3.5, hjust=0 ) +
  annotate(label = SSC_names[5], geom = "text", x = 1 + maxTime/2, y = MySimul5$Y[61], size = 3.5, hjust=0 ) +
  annotate(label = SSC_names[6], geom = "text", x = 1 + maxTime/2, y = MySimul6$Y[61], size = 3.5, hjust=0 ) +
  geom_abline(slope=0,intercept=50,linetype='dashed') +
  labs(x='Time (year)', y='Coral cover (%)') +
  # theme_bw() + theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm")) #t,r,b,l
  theme(panel.background = element_rect(fill = "white", colour = "black")) +
  theme(panel.border = element_rect(linetype = "solid", fill=NA, colour = "black", size=0.5)) +
  theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm"))+ #t,r,b,l
  theme(axis.text = element_text(size=10,color='black'))+
  theme(axis.title=element_text(size=14,color='black'))


## Relationship between SSC and recovery time (inset)
ALL_PCTILES_NAMES = rev(c('10th', '25th', '50th', '75th', '90th', '95th')) # Need to reverse labels
ALL_PCTILES = c(13.2396, 8.0177, 4.4532, 2.3349, 1.3115, 0.3122)
N_VALUES = length(ALL_PCTILES)
OUTPUTS = data.frame('SSC'=rep(NA,N_VALUES),'MinTimeTo50'=rep(NA,N_VALUES),'MinTimeTo30'=rep(NA,N_VALUES),'find_color'=rep(NA,N_VALUES))

for (i in 1:length(ALL_PCTILES))
{   
  WQreproI = exp(4.579-0.01*ALL_PCTILES[i])*(99.571-10.637*log(ALL_PCTILES[i]+1))/(100*100)
  WQjuvI = 1 - 0.176*log(ALL_PCTILES[i]+1)
  WQrecruitI = (1 - 1.88*0.001*ALL_PCTILES[i])^(180/40)
  PRED = data.frame('WQrepro'= WQreproI,'WQjuv'= WQjuvI,'WQrecruit'= WQrecruitI, 'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=median(DRIVERS$Sand))
  MySimul = data.frame('X' = seq(0,maxTime), 'Y' = f.grow(Mf, maxTime, init_Coral, init_Rubble, PRED))
  find_min_time1 = which(MySimul$Y>50)
  find_min_time2 = which(MySimul$Y>30)
  OUTPUTS$SSC[i] = ALL_PCTILES[i]
  OUTPUTS$MinTimeTo50[i] = MySimul$X[ find_min_time1[1] ]
  OUTPUTS$MinTimeTo30[i] = MySimul$X[ find_min_time2[1] ]
  WQDemo = WQreproI*WQjuvI*WQrecruitI
  WQDemo[WQDemo<0.3]=0.301 # force to 0.3 if below (minimum considered here)
  OUTPUTS$find_color[i] = max(which(SSC_scale < WQDemo))
}

# Plot of SSC thresholds
gg3 <- ggplot() + 
  geom_point(OUTPUTS, mapping=aes(x=SSC, y=MinTimeTo50/2), color=MyPalette2[OUTPUTS$find_color], size =2) +
  # geom_point(OUTPUTS, mapping=aes(x=SSC, y=MinTimeTo30/2), color=MyPalette2[OUTPUTS$find_color], size =2) +
  scale_x_continuous(expand=c(0,0), limits=c(-0.5,16)) +
  scale_y_continuous(expand=c(0,0), limits=c(3,23)) +
  # scale_y_continuous(expand=c(0,0), limits=c(0,1+100)) +
  annotate(label = ALL_PCTILES_NAMES, geom = "text", x = 0.3 + OUTPUTS$SSC, y = (OUTPUTS$MinTimeTo50/2), size = 3.25, hjust=0 ) +
  # annotate(label = ALL_PCTILES_NAMES, geom = "text", x = 0.3 + OUTPUTS$SSC, y = (OUTPUTS$MinTimeTo30/2), size = 3, hjust=0 ) +
  labs(x='SSC (mg/L)', y='Time to recovery (yr)') +
  theme_bw() + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) + #t,r,b,l
  theme(panel.background = element_rect(fill = "white", colour = "black"), axis.text = element_text(size=10,color='black'))+
theme(axis.title=element_text(size=14,color='black'))

gg4 = gg2 + annotation_custom(ggplotGrob(gg3), xmin = 20, xmax = 42, ymin = 3, ymax = 48)
gg5 = ggarrange(gg1, gg4, labels=c('A','B'), font.label = list(size = 20),  ncol=2, hjust=-0.7, vjust=1.5)

# ggsave('TEST.png', plot=gg5, width = 6, height = 10)
ggsave('TEST3.png', plot=gg5, width = 14, height = 6) # using SSC rather than PDP (May 14, 2021)


## FIG Colourbar to add ##############################################
png("Colourbar_SSC.png", width=5, height=10, units='in', pointsize=12, type='cairo-png',res=500)
plot(1, type="n", xlab="", ylab="", xlim=c(0, 20), ylim=c(0, 60))
# lut = viridis(cuts, begin=0.5, end=1,alpha=1,dir=-1) # for PDP
lut = viridis(cuts, begin=0, end=1,alpha=1,dir=1) # for SSC

min = 0
max = 1
scale = (length(lut)-1)/(max-min)/40
xleft = 5
xright = xleft+2
ybottom = 2
ytop = ybottom+40

for (i in 1:(length(lut)-1)) { y = (i-1)/scale+ybottom ; rect(xleft,y,xright,(y+1/scale), col=lut[i], border=NA) }

text(xright+1.5,ybottom,'0',cex=2, adj=0)
text(xright+1.5,ytop,'50 mg/L',cex=2, adj=0)
# text(xleft+1,ytop+5,'PDP', font=3,cex=3)
text(xleft+1,ytop+5,'SSC', font=3,cex=3)
# text(xleft+1,ytop+5,'(mg/L)', font=3,cex=2)

dev.off()

############################################################################################
## FIGS for supplementary material (Sand, WQ1, WQ2, WQ3) ###################################
############################################################################################
INIT_CORAL = seq(10,80,by=5)

## (1) Growth as a function of increasing sand
SAND = seq(0, 50, by=2)
MODELLED_GROWTH = matrix(data=NA, nrow = length(SAND)*length(INIT_CORAL), ncol = 3)
count = 0;

for (i in 1:length(INIT_CORAL))
{
  for (s in 1:length(SAND))
  {
    count = count +1 
    newX = data.frame('Coral'=INIT_CORAL[i],'WQrepro'=median(MEANS$WQrepro),'WQjuv'=median(MEANS$WQjuv),'WQrecruit'=median(MEANS$WQrecruit),
                      'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=SAND[s],'Rubble'=median(DRIVERS$Rubble))
    MODELLED_GROWTH[count,1]= SAND[s]
    MODELLED_GROWTH[count,2]= predict(Mf, newX,type="response") - 2
    MODELLED_GROWTH[count,3]=INIT_CORAL[i]
    }
}

MYPREDICT = as.data.frame(MODELLED_GROWTH)

gg10 <- ggplot() + 
  geom_line(MYPREDICT, mapping=aes(x=V1, y=V2, group=V3, col=V3),  size =1.25) +
  # scale_colour_viridis_c(option='magma',alpha=1, expression(atop("Coral", "cover (%)")), begin=0, end=1, direction=1, limits = c(10, 80)) +
  scale_colour_viridis_c(option='magma',alpha=1, "Coral cover (%)", begin=0, end=1, direction=1, limits = c(10, 80)) +
  scale_x_continuous(expand=c(0,0), limits=c(0,max(SAND))) +
  scale_y_continuous(expand=c(0,0), limits=c(-2,8)) +
  labs(x='Ungrazable substrata cover (%)', y='Coral growth (%cover per 6 month)') +
  theme(panel.background = element_rect(fill = "grey", colour = "black")) +
  theme(panel.border = element_rect(linetype = "solid", fill=NA, colour = "black", size=0.5)) +
  theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm"))+ #t,r,b,l
  theme(axis.text = element_text(size=10,color='black'))+ theme(axis.title=element_text(size=14,color='black'))


## (2) Growth as a function of increasing WQ recruit survival
WQ_REC = seq(0.7,1,by=0.02) # min value is 0.722
MODELLED_GROWTH = matrix(data=NA, nrow = length(WQ_REC)*length(INIT_CORAL), ncol = 3)
count = 0;

for (i in 1:length(INIT_CORAL))
{
  for (s in 1:length(WQ_REC))
  {
    count = count +1 
    newX = data.frame('Coral'=INIT_CORAL[i],'WQrepro'=median(MEANS$WQrepro),'WQjuv'=median(MEANS$WQjuv),'WQrecruit'=WQ_REC[s],
                      'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=30,'Rubble'=median(DRIVERS$Rubble))
    MODELLED_GROWTH[count,1]= WQ_REC[s]
    MODELLED_GROWTH[count,2]= predict(Mf, newX,type="response") - 2
    MODELLED_GROWTH[count,3]=INIT_CORAL[i]
  }
}

MYPREDICT = as.data.frame(MODELLED_GROWTH)

gg11 <- ggplot() + 
  geom_line(MYPREDICT, mapping=aes(x=V1, y=V2, group=V3, col=V3),  size =1.25) + 
  scale_colour_viridis_c(option='magma',alpha=1, "Coral cover (%)", begin=0, end=1, direction=1, limits = c(10, 80)) +
  scale_x_continuous(expand=c(0,0), limits=c(0.7,1)) +
  scale_y_continuous(expand=c(0,0), limits=c(-2,8)) +
  labs(x='WQ recruit', y='Coral growth (%cover per 6 month)') +
  theme(panel.background = element_rect(fill = "grey", colour = "black")) +
  theme(panel.border = element_rect(linetype = "solid", fill=NA, colour = "black", size=0.5)) +
  theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm"))+ #t,r,b,l
  theme(axis.text = element_text(size=10,color='black'))+ theme(axis.title=element_text(size=14,color='black'))

## (3) Growth as a function of increasing WQ juvenile growth
WQ_JUV = seq(0.6,1,by=0.02) # min value is 0.623
MODELLED_GROWTH = matrix(data=NA, nrow = length(WQ_JUV)*length(INIT_CORAL), ncol = 3)
count = 0;

for (i in 1:length(INIT_CORAL))
{
  for (s in 1:length(WQ_JUV))
  {
    count = count +1 
    newX = data.frame('Coral'=INIT_CORAL[i],'WQrepro'=median(MEANS$WQrepro),'WQjuv'=WQ_JUV[s],'WQrecruit'=median(MEANS$WQrecruit),
                      'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=30,'Rubble'=median(DRIVERS$Rubble))
    MODELLED_GROWTH[count,1]= WQ_JUV[s]
    MODELLED_GROWTH[count,2]= predict(Mf, newX,type="response") - 2
    MODELLED_GROWTH[count,3]=INIT_CORAL[i]
  }
}

MYPREDICT = as.data.frame(MODELLED_GROWTH)

gg12 <- ggplot() + 
  geom_line(MYPREDICT, mapping=aes(x=V1, y=V2, group=V3, col=V3),  size =1.25) + 
  # scale_colour_viridis_c(option='magma',alpha=1, "Coral cover (%)", begin=0, end=1, direction=1, limits = c(10, 80), guide=guide_colourbar(title.position='left')) +
  scale_colour_viridis_c(option='magma',alpha=1, "Coral cover (%)", begin=0, end=1, direction=1, limits = c(10, 80)) +
  scale_x_continuous(expand=c(0,0), limits=c(0.6,1)) +
  scale_y_continuous(expand=c(0,0), limits=c(-2,8)) +
  labs(x='WQ juv', y='Coral growth (%cover per 6 month)') +
  theme(panel.background = element_rect(fill = "grey", colour = "black")) +
  theme(panel.border = element_rect(linetype = "solid", fill=NA, colour = "black", size=0.5)) +
  theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm"))+ #t,r,b,l
  theme(axis.text = element_text(size=10,color='black'))+ theme(axis.title=element_text(size=14,color='black'))

gg13 = ggarrange(gg10, gg11, gg12, labels=c('A','B','C'), font.label = list(size = 20),  ncol=1, hjust=-0.7, vjust=1.5)
ggsave('@Figure_S17_partial_effects.png', plot=gg13, width = 7, height = 12) # using SSC rather than PDP (May 14, 2021)


######################################################
## SPATIAL PREDICTIONS
######################################################

# Check distributions
par(mfrow=c(2,3))
hist(MEANS$Connect,main='Mean prop external supply')
hist(MEANS$Nb_connect,main='Mean incoming connections')
hist(MEANS$WQrepro,main='Mean WQrepro (coral repro)')
hist(MEANS$WQjuv,main='Mean WQjuv (juv growth)')
hist(MEANS$WQrecruit,main='Mean WQrecruit (recruit mort)')

INIT_CORAL = seq(5,30,by=5)
PREDICTED_GROWTH = matrix(data=NA, nrow = 3806, ncol = length(INIT_CORAL))
count = 0

# NEW: predictions of annual growth for mapping (simulations over 2 time steps) ####

for (i in INIT_CORAL)
{ 
  print(i)
  count = count+1
  for (r in 1:3806)
  {
    PREDS = data.frame('WQrepro'=MEANS$WQrepro[r],'WQjuv'=MEANS$WQjuv[r],'WQrecruit'=MEANS$WQrecruit[r],
                       'Nb_connect'=MEANS$Nb_connect[r],'Connect'=MEANS$Connect[r],'Sand'=30)
    
    MySimul = f.grow(Mf, 2, init_Coral=i, init_Rubble=median(DRIVERS$Rubble), PREDS)
    PREDICTED_GROWTH[r,count]= MySimul[3]-MySimul[1] # growth after 1 year
  }
}

# for (i in INIT_CORAL)
# { 
#   print(i)
#   count = count+1
#   for (r in 1:3806)
#   {
#     newX = data.frame('Coral'=i,'WQrepro'=MEANS$WQrepro[r],'WQjuv'=MEANS$WQjuv[r],'WQrecruit'=MEANS$WQrecruit[r],
#                       'Nb_connect'=MEANS$Nb_connect[r],'Connect'=MEANS$Connect[r],'Sand'=30,'Rubble'=median(DRIVERS$Rubble))
#     
#     # PREDICTED_GROWTH[r,count]= exp(predict(Mf, newX)) - 2
#     PREDICTED_GROWTH[r,count]= predict(Mf, newX,type="response") - 2
#   }
# }

## EXPORT SPATIAL PREDICTIONS FOR MAPPING IN MATLAB
writeMat('Predicted_Growth_from_R.mat', PREDICTED_GROWTH=PREDICTED_GROWTH)

par(mfrow=c(2,2))
hist(PREDICTED_GROWTH[,1])
hist(PREDICTED_GROWTH[,2])
hist(PREDICTED_GROWTH[,3])
hist(PREDICTED_GROWTH)
hist(DRIVERS$Growth)

######################################################
## SURFACE PLOTS
######################################################
# SSC = seq(0.1,PRCTILE_SSC$X5pct,0.05)
# 
# WQrepro = exp(4.579-0.01*SSC)*(99.571-10.637*log(SSC+1))/(100*100)
# WQjuv = 1 - 0.176*log(SSC+1)
# WQrecruit = (1 - 1.88*0.001*SSC)^(180/40)
# 
# init_Coral = seq(0,20,by=0.2)
# Z_SSC = data.frame('SSC' = rep(NA, length(init_Coral)*length(SSC)), 
#                   'CCover' = rep(NA, length(init_Coral)*length(SSC)), 'Growth' = rep(NA, length(init_Coral)*length(SSC)))
# count = 0
# for (s in 1:length(SSC))
# {
#   print(s)
#   for (c in 1:length(init_Coral))
#   {
#     newX = data.frame('WQrepro'=WQrepro[s],'WQjuv'=WQjuv[s],'WQrecruit'=WQrecruit[s],
#                       'Nb_connect'=median(MEANS$Nb_connect),'Connect'=median(MEANS$Connect),'Sand'=25,'Rubble'=10)
#     count = count+1
#     Z_SSC$SSC[count] = SSC[s]
#     Z_SSC$CCover[count] = init_Coral[c]
#     Z_SSC$Growth[count] = 2*( exp(predict(Mf, cbind(data.frame('Coral'=init_Coral[c]),newX)))-2)
#   }
# }
# 
# adjust_lab = 1.5
# Op = "C" # select inferno scheme
# 
# gg1 <- ggplot(Z_SSC, aes(x=SSC, y=CCover, z=Growth)) +
#   geom_tile(aes(fill=Growth)) + 
#   coord_trans(x = "log") +
#   scale_x_continuous(expand=c(0,0)) + 
#   scale_y_continuous(expand=c(0,0)) +
#   scale_fill_viridis_c("Net growth\n(%.year-1)",Op, limits=c(0.5, 4.6)) +
#   # coord_cartesian(expand = FALSE, log='x') +
#   theme_bw() +
#   geom_vline(xintercept=PRCTILE_SSC$X25pct, linetype="dashed", size=0.5, col='white') +
#   annotate(label = "75th percentile", geom = "text", x = PRCTILE_SSC$X25pct - adjust_lab, y = 7.5, size = 4, angle=90, col='white' ) +
#   geom_vline(xintercept=PRCTILE_SSC$X50pct, linetype="dashed", size=0.5, col='white') +
#   annotate(label = "median", geom = "text", x = exp(PRCTILE_SSC$X50pct - 0.8*adjust_lab), y = 7.5, size = 4, angle=90, col='white' ) +
#   labs(x='Suspended sediment (mg.L-1)', y='Coral cover (%)') +
#   theme(axis.title=element_text(size=12,face="bold")) +
#   theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm")) #t,r,b,l
# # theme(title=element_text(size=16,face="bold")) 
# 
# ####################
# ## Surface plot of coral growth as a function of Connect and init
# PRCTILE_CONNECT = quantile(MEANS$Connect, c(0, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 1)) 
# 
# CONNECT = seq(0.01,PRCTILE_CONNECT[8],by=0.01)
# 
# Z_CONNECT = data.frame('CONNECT' = rep(NA, length(init_Coral)*length(CONNECT)), 
#                                'CCover' = rep(NA, length(init_Coral)*length(CONNECT)), 
#                                'Growth' = rep(NA, length(init_Coral)*length(CONNECT)))
# count = 0
# for (s in 1:length(CONNECT))
# {
#   print(s)
#   for (c in 1:length(init_Coral))
#   {
#     newX = data.frame('WQrepro'=median(MEANS$WQrepro),'WQjuv'=median(MEANS$WQjuv),'WQrecruit'=median(MEANS$WQrecruit),
#                       'Nb_connect'=median(MEANS$Nb_connect),'Connect'=CONNECT[s],'Sand'=25,'Rubble'=10)
#     count = count+1
#     Z_CONNECT$CONNECT[count] = CONNECT[s]
#     Z_CONNECT$CCover[count] = init_Coral[c]
#     Z_CONNECT$Growth[count] = 2*( exp(predict(Mf, cbind(data.frame('Coral'=init_Coral[c]),newX)))-2)
#   }
# }
# 
# adjust_lab = 0.02
# gg2 <- ggplot(Z_CONNECT, aes(x=CONNECT, y=CCover, z=Growth)) +
#   geom_tile(aes(fill=Growth)) + 
#   coord_trans(x = "log") +
#   scale_x_continuous(expand=c(0,0)) + 
#   scale_y_continuous(expand=c(0,0)) +
#   scale_fill_viridis_c("Net growth\n(%.year-1)", Op, limits=c(0.5, 4.6)) +
#   theme_bw() +
#   geom_vline(xintercept=quantile(MEANS$Connect, 0.75), linetype="dashed", size=0.5, col='white') +
#   annotate(label = "75th percentile", geom = "text", x = quantile(MEANS$Connect, 0.75) - adjust_lab, y = 7.5, size = 4, angle=90, col='white' ) +
#   geom_vline(xintercept=quantile(MEANS$Connect, 0.5), linetype="dashed", size=0.5, col='white') +
#   annotate(label = "median", geom = "text", x = quantile(MEANS$Connect, 0.5) - 0.4*adjust_lab, y = 7.5, size = 4, angle=90, col='white' ) +
#   labs(x='Proportion of external supply', y='Coral cover (%)') +
#   theme(axis.title=element_text(size=12,face="bold")) +
#   theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm")) #t,r,b,l
# # theme(title=element_text(size=16,face="bold")) 
# 
# ####################
# ## Surface plot of coral growth as a function of Connect and init
# PRCTILE_NB_CONNECT = quantile(MEANS$Nb_connect, c(0, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 1)) 
# 
# NB_CONNECT = seq(0.1,PRCTILE_NB_CONNECT[8],by=0.2)
# 
# Z_NB_CONNECT = data.frame('NB_CONNECT' = rep(NA, length(init_Coral)*length(NB_CONNECT)), 
#                        'CCover' = rep(NA, length(init_Coral)*length(NB_CONNECT)), 
#                        'Growth' = rep(NA, length(init_Coral)*length(NB_CONNECT)))
# count = 0
# for (s in 1:length(NB_CONNECT))
# {
#   print(s)
#   for (c in 1:length(init_Coral))
#   {
#     newX = data.frame('WQrepro'=median(MEANS$WQrepro),'WQjuv'=median(MEANS$WQjuv),'WQrecruit'=median(MEANS$WQrecruit),
#                       'Nb_connect'=NB_CONNECT[s],'Connect'=median(MEANS$Connect),'Sand'=25,'Rubble'=10)
#     count = count+1
#     Z_NB_CONNECT$NB_CONNECT[count] = NB_CONNECT[s]
#     Z_NB_CONNECT$CCover[count] = init_Coral[c]
#     Z_NB_CONNECT$Growth[count] = 2*( exp(predict(Mf, cbind(data.frame('Coral'=init_Coral[c]),newX)))-2)
#   }
# }
# 
# adjust_lab = 1
# gg3 <- ggplot(Z_NB_CONNECT, aes(x=NB_CONNECT, y=CCover, z=Growth)) +
#   geom_tile(aes(fill=Growth)) + 
#   # coord_trans(x = "log") +
#   scale_x_continuous(expand=c(0,0)) + 
#   scale_y_continuous(expand=c(0,0)) +
#   scale_fill_viridis_c("Net growth\n(%.year-1)", Op, limits=c(0.5, 4.68)) +
#   theme_bw() +
#   geom_vline(xintercept=quantile(MEANS$Nb_connect, 0.75), linetype="dashed", size=0.5, col='white') +
#   annotate(label = "75th percentile", geom = "text", x = quantile(MEANS$Nb_connect, 0.75) - adjust_lab, y = 7.5, size = 4, angle=90, col='white' ) +
#   geom_vline(xintercept=quantile(MEANS$Nb_connect, 0.5), linetype="dashed", size=0.5, col='white') +
#   annotate(label = "median", geom = "text", x = quantile(MEANS$Nb_connect, 0.5) - adjust_lab, y = 7.5, size = 4, angle=90, col='white') +
#   labs(x='Number of external supply links', y='Coral cover (%)') +
#   theme(axis.title=element_text(size=12,face="bold")) +
#   theme(plot.margin = unit(c(1, 0.5, 0, 0.5), "cm")) #t,r,b,l
#   # theme(title=element_text(size=16,face="bold")) 
# 
# ggarrange(gg1,gg2,gg3,labels=c('(A)','(B)','(C)'), ncol=1, hjust=-0.7,vjust=1.5)
# ggsave('SURFACES2.png', width = 8, height = 10)
