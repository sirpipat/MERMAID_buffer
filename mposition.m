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
% Last modified by Sirawich Pipatprathanporn: 11/10/2020

defval('fname','/Users/sirawich/research/raw_data/metadata/vit/P023_all.txt')

% read vit file
T = readvit(fname);

% add Time to Date
T.Date = T.Date + T.Time;
T.Date.TimeZone = 'UTC';

% interpolate the position
lon = interp1(T.Date, T.stlo, dt);
lat = interp1(T.Date, T.stla, dt);
end