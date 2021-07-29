#__________________________________________________________________________
#
# SIZE-DEPENDENT FECUNDITY
#
# Yves-Marie Bozec, y.bozec@uq.edu.au, 09/2019
#
# Uses results from:
# Hall, V., and T. Hughes. 1996. Reproductive strategies of modular organisms: 
# comparative studies of reef-building corals. Ecology 77:950–963.
#__________________________________________________________________________


x = seq(10,1000,10)
a = 1.69
b = 1.05
ymax = 10^6

a = 0.86
b = 1.21
ymax = 10^5

a = -1.20
b = 2.27
ymax = 10^5

x11()
par(mar=c(6,6,2,2), mfrow=c(2,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’ 

F1 = exp(log(a)+b*log(x))
F2 = exp(a + b*log(x))
F3 = exp(exp(a)+b*log(x))
# F3 = a*x^b

plot(x,F1,log='xy',ylim=c(1,ymax))
plot(x,F2,log='xy',ylim=c(1,ymax))
plot(x,F3,log='xy',ylim=c(1,ymax))

# if log10
F1 = 10^(log(a)+b*log10(x))
F2 = 10^(a + b*log10(x))
# F3 = a*x^b

plot(x,F1,log='xy',ylim=c(1,ymax))
plot(x,F2,log='xy',ylim=c(1,ymax))
# plot(x,F3,log='xy',ylim=c(1,ymax))

###
x = seq(10,5000,10)

x11(); par(mar=c(6,6,2,2), mfrow=c(3,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’

sp = 'A. hyacinthus'
a = 1.03
b = 1.28
xmax = 10^4
ymax = 10^6
minsize = 123
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)

sp = 'A. nana'
a = 0.63
b = 1.34
xmax = 10^3
ymax = 10^4.2
minsize = 49
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)

sp = 'A. millepora'
a = 1.69
b = 1.05
xmax = 10^3.55
ymax = 10^6
minsize = 134
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)

sp = 'A. gemmifera'
a = 1.64
b = 1.14
xmax = 10^3.5
ymax = 10^6
minsize = 177
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)

sp = 'G. retiformis'
a = 0.86
b = 1.21
xmax = 10^3
ymax = 10^6
minsize = 38
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)

sp = 'S. pistillata'
a = -1.20
b = 2.27
xmax = 10^3
ymax = 10^5
minsize = 31
F2 = exp(a + b*log(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,exp(a + b*log(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(exp(a + b*log(100)),exp(a + b*log(100))))
title(sp)


### if log10
x = seq(10,5000,10)

x11(); par(mar=c(6,6,2,2), mfrow=c(3,2), pty="m", tck=-0.015, lwd=1, las=1) #mar=c(bottom, left, top, right)’

sp = 'A. hyacinthus'
a = 1.03
b = 1.28
xmax = 10^4
ymax = 10^6
minsize = 123
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)

sp = 'A. nana'
a = 0.63
b = 1.34
xmax = 10^3
ymax = 10^4.2
minsize = 49
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)

sp = 'A. millepora'
a = 1.69
b = 1.05
xmax = 10^3.55
ymax = 10^6
minsize = 134
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)

sp = 'A. gemmifera'
a = 1.64
b = 1.14
xmax = 10^3.5
ymax = 10^6
minsize = 177
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)

sp = 'G. retiformis'
a = 0.86
b = 1.21
xmax = 10^3
ymax = 10^6
minsize = 38
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)

sp = 'S. pistillata'
a = -1.20
b = 2.27
xmax = 10^3
ymax = 10^5
minsize = 31
F2 = 10^(a + b*log10(x))
plot(x,F2,log='xy',ylim=c(1,ymax),xlim=c(10,xmax))
points(minsize,10^(a + b*log10(minsize)),pch=19,col='red')
lines(c(100,100),c(1,10^4))
lines(c(10,100),c(10^(a + b*log10(100)),10^(a + b*log10(100))))
title(sp)
