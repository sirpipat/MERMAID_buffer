function plottrack(ax, lon1lat1, lon2lat2, cutofflon, npts, varargin)
% PLOTTRACK(ax, [lon1 lat1], [lon2 lat2], cutofflon, npts, varargin)
% Plots the shortest path between 2 points on the map
%
% INPUT:
% ax            axes to plot the track
% [lon1 lat1]   latitude and longitude of the first point
% [lon2 lat2]   latitude and longitude of the second point
% cutofflon     cut off longitude of the map (map boundary) [-180, 180]
% npts          number of points on the track
% varargin      arguments for plot()
%
% OUTPUT:
% No output, but updates the axes ax
%
% Definition of cutofflon
% cutofflon = 0 [0:180,-180:0]
% cutofflon = 90 [90:180,-180:90]
% cutofflon = -120 [-120:180,-180:-120]
% cutofflon = 180,-180 [-180:180]
% cutofflon = x for -180 <= x <= 180 [x:180,-180:x]
%
% Last modified by Sirawich Pipatprathanporn: 09/24/2020

% compute the track
[lattrk, lontrk] = track([lon1lat1(2) lon2lat2(2)], ...
                         [lon1lat1(1) lon2lat2(1)], [], [], npts);

% convert longitude to x-position on the plot
xtrk = mod(lontrk - cutofflon, 360);
% find if the track cross the cut-off longitude
is_cross = (abs(xtrk(2:end) - xtrk(1:end-1)) > 90);
where_cross = find(is_cross > 0);
% add NaN points at the crossing
xtrk = insert(xtrk, NaN(size(where_cross)), where_cross + 1);
lattrk = insert(lattrk, NaN(size(where_cross)), where_cross + 1);

% plot the track
hold on
plot(ax, xtrk, lattrk, varargin{:});
end