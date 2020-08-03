function [lon,lat] = mposition(dt,fname)
% [lon,lat] = MPOSITION(dt,fname)
% calculate MERMAID position for any given time by interpolating
% surfacing locations from vit file
%
% INPUT
% dt        datetime
% fname     name of the vit file
%
% OUTPUT
% lon       longitude
% lat       latitude
%
% Last modified by Sirawich Pipatprathanporn: 08/01/2020

defval('fname','/Users/sirawich/research/raw_data/metadata/P023_all.txt')

% read vit file
opts = detectImportOptions(fname);
T = readtable(fname,opts);
T.Properties.VariableNames = {'Station', ...
                              'Date', ...
                              'Time', ...
                              'stla', ...
                              'stlo', ...
                              'HDil', ...
                              'VDil', ...
                              'VBat', ...
                              'Vmin', ...
                              'PInt', ...
                              'PExt', ...
                              'PRange', ...
                              'NumCommand', ...
                              'NumQueued', ...
                              'NumUploaded'};

% remove redundant logs
[~, ia] = unique(T.Date);
T = T(ia,:);

% remove time zone from input datetimes
dt.TimeZone = '';

% interpolate the position
lon = interp1(T.Date, T.stlo, dt);
lat = interp1(T.Date, T.stla, dt);
end