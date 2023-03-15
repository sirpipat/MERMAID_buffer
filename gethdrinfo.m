function [dt_ref, dt_B, dt_E, fs, npts, dts, tims] = gethdrinfo(HdrData)
% [dt_ref, dt_B, dt_E, fs, npts, dts, tims] = GETHDRINFO(HdrData)
%
% Gets useful information from SAC header primarily for plotting signal.
%
% INPUT
% HdrData       SAC header
%
% OUTPUT
% dt_ref        reference datetime
% dt_B          begining datetime of the SAC file
% dt_E          ending datetime of the SAC file
% fs            sampling rate
% npts          number of points
% dts           datetime of every sample
% tims          duration in seconds since the beginning datetime
%
% Example
% % sacfile is the filename of a SAC file
% [SeisData, HdrData] = readsac(sacfile);
% [dt_ref, dt_B, dt_E, fs, npts, dts, tims] = gethdrinfo(HdrData);
% plot(dts, SeisData);
%
% SEE ALSO
% READSAC
%
% Last modified by Sirawich Pipatprathanporn, 07/13/2022

% gets the reference datatime
dt_ref = datetime(HdrData.NZYEAR, 1, 0, HdrData.NZHOUR, HdrData.NZMIN, ...
                  HdrData.NZSEC, HdrData.NZMSEC, 'TimeZone', 'UTC','Format',...
                  'uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + days(HdrData.NZJDAY);
dt_B = dt_ref + seconds(HdrData.B);
dt_E = dt_ref + seconds(HdrData.E);

% determines the sampling rate
fs = (HdrData.NPTS - 1) / seconds(dt_E - dt_B);

% number of points
npts = HdrData.NPTS;

% datetimes
dts = dt_B + seconds(0:npts-1) / fs;

% time in seconds since the beginning datetime
tims = seconds(0:npts-1) / fs;
end
