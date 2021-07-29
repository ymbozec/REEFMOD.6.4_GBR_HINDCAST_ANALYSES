%__________________________________________________________________________
%
% Bleaching mortality
%
% Yves-Marie Bozec, y.bozec@uq.edu.au, 09/2019
%
% Uses data extracted from:
% Hughes, T. P., J. T. Kerry, A. H. Baird, S. R. Connolly, and others. 2018. 
% Global warming transforms coral reef assemblages. Nature 556:492.
%
%__________________________________________________________________________

uiopen('Hughes_initial_mortality.csv',1)
BleachingLinearModel = fitlm(Hughesinitialmortality.DHW,log(Hughesinitialmortality.InitMort+1))

save('BleachingModelHughes.mat','BleachingLinearModel')
