** GBR_centroids.mat
Longitude and latitude of 3806 reef polygons
(same ordering than in connectivity matrices)


** GBR_sectors.mat
Sectors of the 3806 reef polygons
(1- North, 2- Centre, 3- South)
See their geographical distribution on the map "sectors.tif"


** GBR_acroyp.mat
Acropora millepora yearly matrices – split spawnings already combined; values are portion of larvae emitted by source (do not add up to 1 because larvae are also lost due to mortality or not reaching any sink); include estimates of self-recruitment on diagonal, but those are highly unreliable
Spawning seasons are for summers:
	'2008-09'
	'2010-11'
->	'2011-12'
->	'2012-13'
->	'2014-15'
->	'2015-16'
->	'2016-17'

** EREEFS_physical.mat
- botz: average depth at sea bottom for each 4km pixel (depth of seabed)
- zc: average depth values of the 47 depth layers used by eReefs
- x_centre, y_centre: coordinates (lon, lat) of each pixel centre
- x_grid, y_grid: coordinates (lon, lat) of the topleft(?) corner of each pixel


** EREEFS_surface_GBR4_v2p0_Chyd.mat
eReefs extract at the surface layer (-0.5m depth)
Contains daily values for TSS, Mud, FineSand and CarbSand for the following months:

    '2017-12';'2017-11';'2017-10';
    '2016-12';'2016-11';'2016-10';
    '2015-12';'2015-11';'2015-10';
    '2014-12';'2014-11';'2014-10';
    '2013-12';'2013-11';'2013-10';
    '2012-12';'2012-11';'2012-10';
    '2011-12';'2011-11';'2011-10';

See details of the extraction in NEW1_EXTRACTION.m         

