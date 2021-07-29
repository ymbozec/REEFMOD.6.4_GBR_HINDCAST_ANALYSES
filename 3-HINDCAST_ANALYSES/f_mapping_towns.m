function f_mapping_towns(markersize, FontSizeLabel)

% Display main towns
Cairns = [145.7206 -16.9180];
PortDouglas = [145.4651 -16.4834];
Cooktown = [145.2513 -15.4760];
Townsville = [146.815703 -19.262102];
Lizard = [145.4621 -14.6687];
Mackay = [ 149.181966 -21.144880];
Rockhampton = [ 150.509423 -23.381031];
Gladstone = [151.250934 -23.843128];

hold on
col = rgb('DarkSlateGray');
col = 'k';

plot(Cairns(1),Cairns(2),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',markersize)
t=text(Cairns(1)-0.2,Cairns(2),'Cairns','FontName', 'Arial' ,'FontSize',FontSizeLabel);
t.HorizontalAlignment='right';

plot(Cooktown(1),Cooktown(2),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',markersize)
t=text(Cooktown(1)-0.2,Cooktown(2),'Cooktown','FontName', 'Arial' ,'FontSize',FontSizeLabel);
t.HorizontalAlignment='right';

plot(Townsville(1),Townsville(2),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',markersize)
t=text(Townsville(1)-0.2,Townsville(2),'Townsville','FontName', 'Arial' ,'FontSize',FontSizeLabel);
t.HorizontalAlignment='right';

plot(Mackay(1),Mackay(2),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',markersize)
t=text(Mackay(1)-0.2,Mackay(2),'Mackay','FontName', 'Arial' ,'FontSize',FontSizeLabel);
t.HorizontalAlignment='right';

plot(Gladstone(1),Gladstone(2),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',markersize)
t=text(Gladstone(1)-0.2,Gladstone(2),'Gladstone','FontName', 'Arial' ,'FontSize',FontSizeLabel);
t.HorizontalAlignment='right';

% plot(Rockhampton(1),Rockhampton(2),'o','MarkerFaceColor',col,'MarkerSize',markersize)
% plot(PortDouglas(1),PortDouglas(2),'o','MarkerFaceColor',col,'MarkerSize',markersize)

