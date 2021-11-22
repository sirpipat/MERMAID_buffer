function [lon,lat,f,t,dt,p2l] = readp2l(p2lfile)
% [lon,lat,f,t,dt,p2l] = READP2L(p2lfile)
% Reads data from a P2LFILE
%
% INPUT
% p2lfile       full filename
%
% OUTPUT
% lon           longitudes
% lat           latitudes
% f             frequencies
% t             number of days since 1990-01-01
% dt            datetimes
% p2l           wave spectral density
%               size(p2l) == [size(lon,1) size(lat,1) size(f,1) size(t,1)]
%
% Last modified by sirawich-at-princeton.edu: 11/22/2021

lon = ncread(p2lfile, 'longitude');
lat = ncread(p2lfile, 'latitude');
f = ncread(p2lfile, 'f');
t = ncread(p2lfile, 'time');
dt = t + datetime(1990, 1, 1, 0, 0, 0, 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC');
p2l = ncread(p2lfile, 'p2l');
end