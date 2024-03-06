function [lons, lats, elev, ax, c, xoffset] = bathymetry(fname, lonlim, latlim, plt, ax)
% [lons, lats, elev, ax, c, xoffset] = bathymetry(fname, [minlon maxlon], [minlat maxlat], plt, ax)
% Reads a GEBCO bathymetry grid, stored in NETCDF format, and plots the
% bathymetry map bounded by [minlon maxlon] and [minlat maxlat]. The
% x-coordinate 
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
% xoffset           the offset between the x-coordinate on the plot and the
%                   actual longitude. Used when plotting over the map
%
% EXAMPLES
% % plot entire globe (takes some time)
% [lons, lats, elev, ax, c] = bathymetry([], [], [], true);
%
% % plot a region (Africa)
% [lons, lats, elev, ax, c, xoffset] = bathymetry([], [-70 20], ...
%       [-5 45], true);
% % plot a track
% hold on
% plot([-30 -55] + xoffset, [-10 40], 'LineWidth', 1, 'Color', 'k');
%
% % request the elevation at a location
% lonlat = [-143, -24];
% [lons, lats, elev, ax, c] = bathymetry([], [-0.1 0.1] + lonlat(1), ...
%       [-0.1 0.1] + lonlat(2), false, []);
%
% SEE ALSO
% BATHYMETRYPROFILE
%
% Last modified by sirawich-at-princeton.edu, 02/22/2024

defval('fname', fullfile(getenv('IFILES'), 'TOPOGRAPHY', 'EARTH', ...
    'GEBCO', 'GEBCO_2020.nc'))
defval('lonlim', [-180 180])
defval('latlim', [-90 90])
defval('plt', false)
defval('sname', sprintf('%s_%s.mat', mfilename, hash([fname lonlim latlim], 'SHA-1')))

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
    if lonlim(2) > lonlim(1)
        lons = lons_full(i_lon1:i_lon2);
        lats = lats_full(i_lat1:i_lat2);
        elev = ncread(fname, 'elevation', [i_lon1 i_lat1], ...
            [i_lon2-i_lon1+1 i_lat2-i_lat1+1]);
    % CASE 2: the region acrosses 180E longitude
    elseif lonlim(2) < lonlim(1)
        lons = lons_full([i_lon1:end, 1:i_lon2]);
        lats = lats_full(i_lat1:i_lat2);
        elev1 = ncread(fname, 'elevation', [i_lon1 i_lat1], ...
            [length(lons_full)-i_lon1+1 i_lat2-i_lat1+1]);
        elev2 = ncread(fname, 'elevation', [1 i_lat1], ...
            [i_lon2 i_lat2-i_lat1+1]);
        elev = [elev1; elev2];
    % CASE 3: the region is all longitudes
    else
        lons = lons_full([i_lon1:end, 1:i_lon2-1]);
        lats = lats_full(i_lat1:i_lat2);
        elev1 = ncread(fname, 'elevation', [i_lon1 i_lat1], ...
            [length(lons_full)-i_lon1+1 i_lat2-i_lat1+1]);
        if i_lon2 > 1
            elev2 = ncread(fname, 'elevation', [1 i_lat1], ...
                [i_lon2-1 i_lat2-i_lat1+1]);
            elev = [elev1; elev2];
        else
            elev = elev1;
        end
    end

    % converts longitudes back to [0,360]
    lons = mod(lons, 360);
    
    fprintf('save the output to a file to %s ...\n', pname);
    save(pname, 'lons', 'lats', 'elev');
else
    fprintf('found the save in a file in %s\n', pname);
    load(pname, 'lons', 'lats', 'elev');
end

% plots the bathymetry map
if plt
    % x-value for the plot
    xval = mod(lons -lons(1), 360);
    
    defval('ax', gca)
    axes(ax)
    imagesc(xval, lats, elev', [-11000 9000]);
    axis xy;
    [cb,cm] = cax2dem([-7000 3500], 'hor');
    delete(cb);
    c = colorbar;
    grid on
    set(gca, 'DataAspectRatio', [1 1 1], 'FontSize', 13, 'LineWidth', 1);
    
    % adjust the longitude ticks and ticks label
    dx = ax.XTick(2) - ax.XTick(1);
    lon1EW = mod(lons(1) + 180, 360) - 180;
    shift = mod(lon1EW, dx);
    ax.XTick = ax.XTick - shift;
    ax.XTick = [ax.XTick ax.XTick(end)+dx];
    ax.XTickLabel = string(mod(ax.XTick + lons(1) + 180, 360) - 180);
    xoffset = ax.XTick(1) - str2double(ax.XTickLabel{1});
else
    ax = [];
    c = [];
    xoffset = [];
end
end