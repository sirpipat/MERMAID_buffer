function [lons, lats, elev, ax, c] = bathymetry(fname, lonlim, latlim, plt, ax)
% [lons, lats, elev, ax, c] = bathymetry(fname, [minlon maxlon], [minlat maxlat], plt, ax)
% Reads a GEBCO bathymetry grid, stored in NETCDF format, and plots the
% bathymetry map bounded by [minlon maxlon] and [minlat maxlat].
%
% INPUT
% fname             GEBCO full filename
% [minlon maxlon]   left and right boundary of the map
% [minlat maxlat]   lower and upper boundary of the map
% plt               whether to plot or not
% ax                target axes
%
% OUTPUT
% lons              longitudes of the requested bathymetry grid
% lats              latitudes of the requested bathymetry grid
% elev              elevations of the requested bathymetry grid
% ax                axes containing the plot
% c                 colorbar
%
% Last modified by Sirawich Pipatprathanporn, 09/01/2021

defval('fname', fullfile(getenv('IFILES'), 'TOPOGRAPHY', 'EARTH', ...
    'GEBCO', 'GEBCO_2020.nc'))
defval('lonlim', [-180 180])
defval('latlim', [-90 90])
defval('plt', false)
defval('sname', sprintf('%s_%s.mat', mfilename, hash([lonlim latlim], 'SHA-1')))

pname = fullfile(getenv('IFILES'), 'HASHES', sname);

if ~exist(pname, 'file')
    % converts lon range from [0, 360] to [-180, 180]
    lonlim = mod(lonlim + 180, 360) - 180;

    % reads available lat,lon of the GEBCO bathymetry grid
    lons_full = ncread(fname, 'lon');
    lats_full = ncread(fname, 'lat');

    % determines the first and last indices of the requested area
    [~, i_lon1] = min(abs(lons_full - lonlim(1)));
    [~, i_lon2] = min(abs(lons_full - lonlim(2)));
    [~, i_lat1] = min(abs(lats_full - latlim(1)));
    [~, i_lat2] = min(abs(lats_full - latlim(2)));

    % reads the elevation from the GEBCO file
    % CASE 1: the region does not across 180E longitude
    if lonlim(2) >= lonlim(1)
        lons = lons_full(i_lon1:i_lon2);
        lats = lats_full(i_lat1:i_lat2);
        elev = ncread(fname, 'elevation', [i_lon1 i_lat1], ...
            [i_lon2-i_lon1+1 i_lat2-i_lat1+1]);
    % CASE 2: the region acrosses 180E longitude
    else
        lons = lons_full([i_lon1:end, 1:i_lon2]);
        lats = lats_full(i_lat1:i_lat2);
        elev1 = ncread(fname, 'elevation', [i_lon1 i_lat1], ...
            [length(lons_full)-i_lon1+1 i_lat2-i_lat1+1]);
        elev2 = ncread(fname, 'elevation', [1 i_lat1], ...
            [i_lon2 i_lat2-i_lat1+1]);
        elev = [elev1; elev2];
    end

    % converts longitudes back to [0,360]
    lons = mod(lons, 360);

    % plots the bathymetry map
    if plt
        defval('ax', gca)
        axes(ax)
        imagesc(lons, lats, elev', [-11000 9000]);
        axis xy;
        [cb,cm] = cax2dem([-7000 3500], 'hor');
        delete(cb);
        c = colorbar;
        grid on
        set(gca, 'DataAspectRatio', [1 1 1], 'FontSize', 13, 'LineWidth', 1);
    else
        ax = [];
        c = [];
    end
    save(pname, 'lons', 'lats', 'elev', 'ax', 'c');
else
    load(pname);
end