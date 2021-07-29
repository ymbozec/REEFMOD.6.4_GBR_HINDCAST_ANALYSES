#__________________________________________________________________________
#
# EFFECTS OF SSC ON THE GROWTH OF JUVENILES
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 03/2018
#
# Uses experimental data extracted from:
# Humanes, A., A. Fink, B. L. Willis, K. E. Fabricius, D. de Beer, and A. P. Negri. 2017. 
# Effects of suspended sediments and nutrient enrichment on juvenile corals. 
# Marine Pollution Bulletin 125:166–175.
#__________________________________________________________________________

rm(list=ls())

humanes=data.frame(TSS=c(0,10,30,100,0,10,30,100,0,10,30,100),
                   RelG=c(1 , 0.792, 0.410, 0.454 , 1, 0.510, -0.001, -0.164, 1, 1.175, 0.757, -0.098),
                   SPECIES=c('ten','ten','ten','ten','mil','mil','mil','mil', 'acu', 'acu', 'acu', 'acu'))

select_ten = c(1,2,3,4)
select_mil = c(5,6,7,8)
select_acu = c(9,10,11,12)

plot(humanes$TSS,humanes$RelG )
plot(log(humanes$TSS+1),humanes$RelG )

## Test the relationship
M1 = lm(humanes$RelG-1~ 0+log(humanes$TSS+1))

R2 = summary(M1)$r.squared
# Don't extract slope and intercept from summary(M2) because no intercept 
# Use predict instead (predict(M2)+1)


## Plot relationship between log(Linf) and log(K) 
svg("FIG_juvenile_growth_with_SSC.svg", height = 4, width = 4, bg="transparent") # 3inches ~ 6cm

par(mar=c(6,6,2,2), mfrow=c(1,1), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(humanes$TSS[select_ten],humanes$RelG[select_ten],pch=19,cex=1.5,xlim=c(0,100),ylim=c(-0.5,1.5),xaxt='n',yaxt='n', xlab='Suspended sediment (mg.L-1)',ylab='Relative growth')
points(humanes$TSS[select_mil],humanes$RelG[select_mil],pch=21,cex=1.5)
points(humanes$TSS[select_acu],humanes$RelG[select_acu],pch=21,bg='gray',cex=1.5)

# lines(humanes$TSS, predict(M1),lwd=1.5)
lines(seq(0,100,by=1), summary(M1)$coefficients[1]*log(1+seq(0,100,by=1))+1,lwd=1.5)

axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

dev.off()
