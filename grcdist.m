function [distKM, distDeg] = grcdist(lon1lat1, lon2lat2)

% Conversion to radians
lon1lat1=lon1lat1 * pi / 180;
lon2lat2=lon2lat2 * pi / 180;

dist = acos(sin(lon1lat1(2)) * sin(lon2lat2(2)) + ...
    cos(lon1lat1(2)) * cos(lon2lat2(2)) * cos(lon1lat1(1) - lon2lat2(1)));

distDeg = dist * 180 / pi;
distKM = dist * 6371;
end