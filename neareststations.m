function [stations, networks, dists] = neareststations(sfile, lon, lat, n)
% [stations, networks, dists] = NEARESTSTATIONS(sfile, lon, lat, n)
% Finds n nearest stations in STATION file from (lon,lat).
%
% INPUT:
% sfile         STATION file
% lon           longitude
% lat           latitude
% n             the number of nearest station [default: 1]
%
% OUTPUT:
% stations      station name
% networks      network name
% dists         distance
%
% Last modified by Sirawich Pipatprathanporn: 09/22/2020

defval('n', 1)

% read text from STATION file
fid = fopen(sfile);
txt = fscanf(fid, '%c');
fclose(fid);

% reshape text into 6 columns
% 1. station name
% 2. network name
% 3. latitude
% 4. longitude
% 5. depth (m)
% 6. burial (m)
data = split(txt);
data = data(1:end-1);
data = reshape(data, 6, size(data, 1)/6)';
lons = str2double(data(:,4));
lats = str2double(data(:,3));

% find the nearest stations
[dist, ~] = distance(lats, lons, lat, lon, 'degree');
[dists, indices] = mink(dist, n);
stations = data(indices, 1);
networks = data(indices, 2);
end