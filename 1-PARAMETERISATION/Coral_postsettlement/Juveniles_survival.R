#__________________________________________________________________________
#
# EFFECTS OF SSC ON THE SURVIVAL OF JUVENILES
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 03/2018
#
# Uses experimental data extracted from:
# Humanes, A., A. Fink, B. L. Willis, K. E. Fabricius, D. de Beer, and A. P. Negri. 2017. 
# Effects of suspended sediments and nutrient enrichment on juvenile corals. 
# Marine Pollution Bulletin 125:166–175.
#__________________________________________________________________________


rm(list=ls())

humanes=data.frame(TSS=c(0,10,30,100,0,10,30,100),
                   S180d=c(1.000, 0.736, 0.860, 0.529, 1.000, 0.869, 0.753, 0.283),
                   SPECIES=c('ten','ten','ten','ten','mil','mil','mil','mil'))

select_ten = c(1,2,3,4)
select_mil = c(5,6,7,8)

# humanes$S = humanes$S180d
humanes$S = humanes$S180d^(40/180) # transform back to 40 days (duration of experiment)
# humanes$S = humanes$S180d^(1/180) # transform do daily mortality


## Test the relationship
# M1 = lm(humanes$S~ humanes$TSS)
# 
# R2 = summary(M1)$r.squared
# slope = round(summary(M1)$coefficients[2],3)
# intercept = round(summary(M1)$coefficients[1],3)
# ( survival after 6mo = -0.005*TSS + 0.941 )

# Model with intercept forced to 1
M2 = lm(humanes$S-1 ~ 0+humanes$TSS)

R2 = summary(M2)$r.squared
# Don't extract slope and intercept from summary(M2) because no intercept 
# Use predict instead (predict(M2)+1)


## Plot relationship between log(Linf) and log(K) 
svg("FIG_juvenile_survival_with_SSC.svg", height = 4, width = 4, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,1), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

# plot(humanes$TSS[select_ten],humanes$S[select_ten],pch=19,cex=1.5,xlim=c(0,100),
#       ylim=c(0,1),xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Survival fraction after 6 month')
plot(humanes$TSS[select_ten],humanes$S[select_ten],pch=19,cex=1.5,xlim=c(0,100),
     ylim=c(0.6,1),xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Survival fraction after 40 days')
points(humanes$TSS[select_mil],humanes$S[select_mil],pch=21,cex=1.5)

# lines(humanes$TSS, predict(M1),lwd=1.5)
# lines(humanes$TSS, predict(M2)+1,lwd=1.5)
lines(seq(0,100,by=20), summary(M2)$coefficients[1]*seq(0,100,by=20)+1,lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()

## Model with daily survival
M2 = lm((humanes$S)^(1/180)~humanes$TSS)

summary(M2)