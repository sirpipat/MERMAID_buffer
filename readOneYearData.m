function [x, t_begin, t_end] = readOneYearData(filename, fs)
% [x, t_begin, t_end] = readOneYearData(filename, fs)
%
% read a OneYearData file and return the data with beginning time and end time
%
% INPUT:
% filename    Full filename of the OneYearData file
% fs          Sampling rate [Default: 40]
%
% OUTPUT:
% x           The data
% t_begin     Datetime at the beginning
% t_end       Datetime at the end
% 
% SEE ALSO:
% FILE2DATETIME, REMOVEPATH, LOADB
%
% Last modified by Sirawich Pipatprathanporn: 01/17/2020

defval('fs', 40);

% convert seconds to days
s2d = 86400;

x = loadb(filename, 'int32', 'l');
t_begin = file2datetime(filename);
t_end = t_begin + (length(x) / fs) / s2d;
end