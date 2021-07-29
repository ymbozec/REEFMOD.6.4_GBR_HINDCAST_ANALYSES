#__________________________________________________________________________
#
# EFFECTS OF CHL ON THE SURVIVAL OF COTS LARVAE
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 03/2018
#
# Uses experimental data extracted from:
# Fabricius, K., K. Okaji, and G. De’Ath. 2010. Three lines of evidence
# to link outbreaks of the crown-of-thorns seastar Acanthaster planci to
# the release of larval food limitation. Coral Reefs 29:593–605.
#__________________________________________________________________________

rm(list=ls())

fabricius = read.table("Fabricius.csv", header=TRUE, sep=",")

select=c(11,15) # outliers as defined by Fabricius et al. 2010

S = fabricius$Completion[-select]/100
S[S==1]=0.999
S[S==0]=0.001
Chl = fabricius$Chl_a[-select]
N = fabricius$N[-select]

# plot(log(Chl+1),1-S)
# plot(Chl,log(S/(1-S)))

## Test the relationship
M1 = glm(S~log(Chl),family=binomial(link='logit'),weights=N)

R2 = summary(M1)$r.squared
slope = round(summary(M1)$coefficients[2],3)
intercept = round(summary(M1)$coefficients[1],3)

new_X = seq(0.01,6,0.01)
pred_Y = 1/(1+exp(-(slope*log(new_X)+intercept)))
pred_Y = 1/(1+exp(-2.91*log(new_X)+0.20))
# Simplified formulation (they are all the same):
pred_Y2= exp(intercept)/(exp(intercept)+new_X^(-slope))
pred_Y2= 0.816/(0.816+new_X^(-2.909))
pred_Y3= 1/(1+(1.07/new_X)^2.91) # <- or this one!! (1.07=1.23^(1/2.91)

## Plot relationship between log(Linf) and log(K) 
svg("FIG_juvenile_survival.svg", height = 4, width = 4, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,1), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(Chl,S,pch=19,cex=1.5,ylim=c(0,1),log='x',xaxt='n',yaxt='n', xlab='Chl a (micro g.L-1)',ylab='Survival fraction after 22 days')
lines(new_X,pred_Y,lwd=1.5)
lines(new_X,pred_Y3,lwd=1,col='green')
lines(new_X,pred_Y3,lwd=1,col='red')

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()
