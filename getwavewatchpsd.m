function [f, psd] = getwavewatchpsd(dt, lat, lon, p2ldir)
% [f, psd] = GETWAVEWATCHPSD(dt, lat, lon, p2ldir)
%
% Reads data from P2L file and calculates power spectral density at the
% given location and time.
%
% INPUT:
% dt            datetime
% lat           latitude
% lon           longitude
% p2ldir        directory to P2L files
%
% OUTPUT:
% f             frequency
% psd           power spectral density
%
% Last modified by sirawich-at-princeton.edu, 11/22/2021

defval('p2ldir', strcat(getenv('NCFILES'), 'p2l/'))

% figure out which file to read
year = dt.Year;
month = dt.Month;

fname = sprintf('WW3-GLOB-30M_%04d%02d_p2l.nc', year, month);
fname = strcat(p2ldir, fname);

% read the file
lons_full = ncread(fname, 'longitude');
lats_full = ncread(fname, 'latitude');
time_full = ncread(fname, 'time');
dts_full = time_full + datetime(1990, 1, 1, 0, 0, 0, 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC');
f = ncread(fname, 'f');

% get indices to read p2l from the file
[dlons, i_lon] = mink(abs(lons_full - lon), 2);
[i_lon, i_sort] = sort(i_lon);
dlons = dlons(i_sort);

[dlats, i_lat] = mink(abs(lats_full - lat), 2);
[i_lat, i_sort] = sort(i_lat);
dlats = dlats(i_sort);

[ddts, i_dt] = mink(abs(dts_full - dt), 2);
[i_dt, i_sort] = sort(i_dt);
ddts = ddts(i_sort);

% read p2l from the file
p2l = ncread(fname, 'p2l', [i_lon(1) i_lat(1) 1 i_dt(1)], ...
    [2 2 length(f) 2]);

% linear interpolation
p2l = p2l(1,:,:,:) + dlons(1) / (dlons(2) + dlons(1)) * ...
    (p2l(2,:,:,:) - p2l(1,:,:,:));
p2l = p2l(1,1,:,:) + dlats(1) / (dlats(2) + dlats(1)) * ...
    (p2l(1,2,:,:) - p2l(1,1,:,:));
p2l = p2l(1,1,:,1) + ddts(1) / (ddts(2) + ddts(1)) * ...
    (p2l(1,1,:,2) - p2l(1,1,:,1));

p2l = reshape(p2l, [length(f) 1]);

% convert to psd
psd = p2l2psd(p2l, lat);
end