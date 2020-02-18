function [x, t_begin, t_end] = readOneYearData(filename, fs, direction)
% [x, t_begin, t_end] = readOneYearData(filename, fs)
%
% read a OneYearData file and return the data with beginning time and end time
%
% INPUT:
% filename    Full filename of the OneYearData file
% fs          Sampling rate [Default: 40]
% direction   0 - Using the filename as the start time  [Default]
%             1 - Using the filename as the end time
%
% OUTPUT:
% x           The data
% t_begin     Datetime at the beginning
% t_end       Datetime at the end
% 
% SEE ALSO:
% FILE2DATETIME, REMOVEPATH, LOADB
%
% Last modified by Sirawich Pipatprathanporn: 02/08/2020

defval('fs', 40);
defval('direction', 0);

x = loadb(filename, 'int32', 'l');

if (direction == 0)
    t_begin = file2datetime(filename);
    t_end = t_begin + second((length(x) - 1) / fs);
else
    t_end = file2datetime(filename);
    t_begin = t_end - second((length(x) - 1) / fs);
end
end