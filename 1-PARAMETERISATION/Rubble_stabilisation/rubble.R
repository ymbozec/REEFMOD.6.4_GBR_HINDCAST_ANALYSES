#__________________________________________________________________________
#
# DYNAMICS OF RUBBLE STABILISATION
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 09/2029
#__________________________________________________________________________

rm(list=ls())
library(RSvgDevice)

# MODEL
steps = seq(0,8,by=0.5)
# decay = 1-0.85^0.5 # which corresponds to 15% every year (~50% stabilized in 5 years)
decay = 1-0.5^(1/8) # which corresponds to 50% stabilized in 4 years
decay = 1-0.333^(1/8) # which corresponds to 50% stabilized in 4 years

init = seq(10,50,by=10)
states = array(rep(0,length(init)*length(steps)),dim=c(length(init),length(steps))) ;

states[,1] = init
sup = 0* rep(c(0,0,0,0,0,0,0,10,0,0,0,0,0,0,0),10)

# x11()
devSVG("FIG_rubble_stabilization.svg", height = 4, width = 8, bg="transparent") # 3inches ~ 6cm

par(mar=c(5,5,2,2), mfrow=c(1,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

plot(1,1, 'n', ylab="Unstabilized rubble cover (%)", xlab= "years", cex=1.5, xaxt='n',yaxt='n', xlim=c(0,max(steps)), ylim=c(0,55))
axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

for (i in 1:length(init))
    {

        for (j in 2:length(steps))
            {
            states[i,j] = states[i,j-1]*(1-decay) + sup[j]*(100-states[i,j-1])/100
            
            # if (states[i,j-1]>5)  { states[i,j] = 0 } # if doing restoration
           
            }

    lines(steps, states[i,],lwd=1.5)
    
    }
# lines(steps,rep(5,length(steps)),col='red')

##############################################
# MODEL TESTING WITH EMPIRICAL DATA
##############################################
# Biggs (2013) - number of rubble piles consolidated and stablized in 2 sites over 48 months
time_months = c(0, 12, 24, 36, 48)

## 1) Number of consolidated piles
# site_A = c(21, 21 , 21, 19, 18)
# site_A_sponge = c(21, 19, 16, 13, 13)
# site_B = c(20, 20, 20, 15, 13)
# site_B_sponge = c(20, 20, 16, 6, 5)
# 
# plot(time_months/12,site_A/21,pch=19, ylim=c(0,1))
# points(time_months/12,site_B/20,pch=19)
# points(time_months/12,site_A_sponge/20,pch=19, col='blue')
# points(time_months/12,site_B_sponge/20,pch=19, col='blue')
# 
# Freq1 = data.frame(time=time_months, prop_unconsolidated = site_A/max(site_A))
# Freq2 = data.frame(time=time_months, prop_unconsolidated = site_A_sponge/max(site_A_sponge))
# Freq3 = data.frame(time=time_months, prop_unconsolidated = site_B/max(site_B))
# Freq4 = data.frame(time=time_months, prop_unconsolidated = site_B_sponge/max(site_B_sponge))
# 
# ALL = rbind(Freq1,Freq2,Freq3,Freq4)
# 
# plot(ALL$time/12,100*ALL$prop_unconsolidated,pch=19,cex=1.5,xlim=c(0,4),ylim=c(0,100))

## 2) Number of stabilized piles -> more useful because coral can recruit and survive on stabilized rubble.
# Note hwever this is temporary stabilization so will be quite optimistic for corals
time_months = c(0, 12, 48)

Ssite_A = c(0, 4, 11)
Ssite_A_sponge = c(0, 13, 20)
Ssite_B = c(0, 11, 16)
Ssite_B_sponge = c(0, 17, 20)

# plot(time_months/12,Ssite_A/21,pch=19, ylim=c(0,1))
# points(time_months/12,Ssite_B/20,pch=19)
# points(time_months/12,Ssite_A_sponge/21,pch=19, col='blue')
# points(time_months/12,Ssite_B_sponge/20,pch=19, col='blue')

Freq1 = data.frame(time=time_months, prop_unconsolidated = Ssite_A/21)
Freq3 = data.frame(time=time_months, prop_unconsolidated = Ssite_B/20)
ALL = rbind(Freq1,Freq3)

# Freq2 = data.frame(time=time_months, prop_unconsolidated = Ssite_A_sponge/21)
# Freq4 = data.frame(time=time_months, prop_unconsolidated = Ssite_B_sponge/20)
# ALL = rbind(Freq1,Freq2,Freq3,Freq4)

plot(ALL$time/12,100-100*ALL$prop_unconsolidated, pch=19, cex=1.5, cex.lab=1.3, cex.axis=1.2, xlim=c(0,5),ylim=c(0,100), ylab="Unstabilized rubble piles (%)", xlab= "years",	xaxt='n',yaxt='n' )
axis(1,lwd=0,lwd.ticks=1,line=NA,las = 1)
axis(2,lwd=0,lwd.ticks=1,line=NA,las = 1)

M = 10*states[1,]
lines(steps,M, lwd=1.5)

dev.off()

