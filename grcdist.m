function [distKM, distDeg] = grcdist(lon1lat1, lon2lat2)
% [distKM, distDeg] = GRCDIST([lon1 lat1], [lon2 lat2])
% Calculates the distance between two points on a great circle.
%
% INPUT:
% [lon1 lat1]       longitude and latitude of the starting point (degrees)
% [lon2 lat2]       longitude and latitude of the ending point (degrees)
%
% OUTPUT:
% distKM            distance in kilometers
% distDeg           distance in degrees
%
% Last modified by Sirawich Pipatprathanporn: 09/15/2020

% Conversion to radians
lon1lat1=lon1lat1 * pi / 180;
lon2lat2=lon2lat2 * pi / 180;

dist = acos(sin(lon1lat1(2)) * sin(lon2lat2(2)) + ...
    cos(lon1lat1(2)) * cos(lon2lat2(2)) * cos(lon1lat1(1) - lon2lat2(1)));

distDeg = dist * 180 / pi;
distKM = dist * 6371;
end