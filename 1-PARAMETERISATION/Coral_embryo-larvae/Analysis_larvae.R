#__________________________________________________________________________
#
# EFFECTS OF SSC ON EARLY STAGES
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 03/2018
#
# Uses experimental data extracted from:
# Humanes, A., G. F. Ricardo, B. L. Willis, K. E. Fabricius, and A. P. Negri. 2017. 
# Cumulative effects of suspended sediments, organic nutrients and temperature stress
# on early life history stages of the coral Acropora tenuis. Scientific Reports 7:44101.
#__________________________________________________________________________

rm(list=ls())
source('myFunctions.R')

Erftemeijer = data.frame(SSC=c(6,43,169), NTU=c(4,39,154), REL_FERTILIZATION=c(1, 0.88, 0.75))
Humphrey = data.frame(SSC=c(0,25,50,100,200), REL_FERTILIZATION=c(1,1.02,1.05,0.83,0.40))
Humanes = read.table("Humanes_larvae.csv", header=TRUE, sep=",")

# Force to zero relative fertilizaton
Humanes$REL_FERTILIZATION[Humanes$REL_FERTILIZATION>1]=1
Humphrey$REL_FERTILIZATION[Humphrey$REL_FERTILIZATION>1]=1

##############################
## 1) FERTILIZATION SUCCESS ##
##############################

## First plot for exploration
par(mar=c(6,6,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(Humanes$SSC,100*Humanes$REL_FERTILIZATION,pch=19,cex=1.5,xlim=c(0,100),ylim=c(0,100), 
	  xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
# points(Humphrey$SSC,100*Humphrey$REL_FERTILIZATION)
# points(Erftemeijer$SSC,100*Erftemeijer$REL_FERTILIZATION,col='green')

plot(Humanes$SSC,100*Humanes$REL_FERTILIZATION,pch=19,cex=1.5,log='y',xlim=c(0,100),ylim=c(1,100), 
	  xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
	  
## Test the relationship
M1 = lm(log(100*Humanes$REL_FERTILIZATION)~ Humanes$SSC)

R2 = summary(M1)$r.squared
m = round(summary(M1)$coefficients[2],3)
p = round(summary(M1)$coefficients[1],3)

all_obs = (log(100*Humanes$REL_FERTILIZATION)-mean(log(100*Humanes$REL_FERTILIZATION)))^2
all_fit = (predict(M1)-mean(log(100*Humanes$REL_FERTILIZATION)))^2

R2_tot = sum(all_fit)/sum(all_obs) # double-check this is exactly R2
exclu = c(1,6,11,16) # exclude the baseline of each treatment (=100%)
R2_correct = sum(all_fit[-exclu])/sum(all_obs[-exclu])
# Update: does not make any sense to correct R2 because the regression is not constrained to intercept=100%

model_validation(M1)

# log(100*Rel_Fert) = 4.579 - 0.010*SSC

## Plot relationship between deposited sediment and settlement rate 
svg("FIG_fertilization_success.svg", height = 4, width = 8, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

# Plot 1 - model fit
plot(Humanes$SSC,100*Humanes$REL_FERTILIZATION,log='y',pch=19,cex=1.5,xlim=c(0,100),ylim=c(1,100),
	xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
lines(seq(0,100,by=1), exp(m*seq(0,100,by=1)+p),lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

# Plot 2 - non-transformed data with model exptrapolation
plot(Humanes$SSC,100*Humanes$REL_FERTILIZATION,pch=19,cex=1.5,xlim=c(0,100),ylim=c(0,100),
      xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
lines(seq(0,100,by=1), exp(m*seq(0,100,by=1)+p),lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()


##############################
## 2) SETLLEMENT RATE       ##
##############################

## First plot for exploration

select = which(Humanes$TREATMENT=="NH_TL")

par(mar=c(6,6,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(Humanes$SSC[-select],100*Humanes$REL_SETTLEMENT[-select],pch=19,cex=1.5,xlim=c(0,100),ylim=c(0,100), 
	  xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')

plot(Humanes$SSC[-select],100*Humanes$REL_SETTLEMENT[-select],pch=19,cex=1.5,log='y',xlim=c(1,100),ylim=c(1,100), 
	  xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
	  
plot(Humanes$SSC[-select]+1,100*Humanes$REL_SETTLEMENT[-select],pch=19,cex=1.5,log='x',xlim=c(1,100),ylim=c(1,100), 
	  xlab='Suspended sediment (mg.L-1)',ylab='Relative fertilization success (%)')
	  
## Test the relationship
M2 = lm(100*Humanes$REL_SETTLEMENT[-select]~ log(Humanes$SSC[-select]+1))

R2 = summary(M2)$r.squared
m = round(summary(M2)$coefficients[2],3)
p = round(summary(M2)$coefficients[1],3)

# 100*Rel_Settl) = 99.571 - 10.637*log(SSC+1)

## Plot relationship between deposited sediment and settlement rate 
svg("FIG_settlement.svg", height = 4, width = 8, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

# Plot 1 - model fit
plot(Humanes$SSC[-select]+1,100*Humanes$REL_SETTLEMENT[-select],log='x',pch=19,cex=1.5,xlim=c(1,100),ylim=c(0,100),
	xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative settlement (%) following exposure')
lines(seq(0,100,by=1)+1, m*(log(seq(0,100,by=1)+1))+p,lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

# Plot 2 - non-transformed data with model exptrapolation
plot(Humanes$SSC[-select]+1,100*Humanes$REL_SETTLEMENT[-select],pch=19,cex=1.5,xlim=c(0,100),ylim=c(0,100),
      xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative settlement (%) following exposure')
lines(seq(0,100,by=1)+1, m*(log(seq(0,100,by=1)+1))+p,lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()

#######################################
## 3) Model of reproduction success 
#######################################

# Fertilization
m1 = round(summary(M1)$coefficients[2],3)
p1 = round(summary(M1)$coefficients[1],3)

m2 = round(summary(M2)$coefficients[2],3)
p2 = round(summary(M2)$coefficients[1],3)

SSC = seq(0,100,by=1)
FERT = exp(m1*SSC+p1)
SETTL = m2*(log(SSC+1))+p2
REPRO = FERT*SETTL/100
# REPRO = (100*FERT/FERT[1])*(100*SETTL/SETTL[1])/100

plot(SSC,FERT)
plot(SSC,SETTL)

svg("FIG_reproduction.svg", height = 4, width = 8, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(SSC, REPRO,'l',xlim=c(0,100),ylim=c(0,100),lwd=1.5,
     xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative reproduction success (%)')

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()


