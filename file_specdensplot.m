function [ax, ax2] = file_specdensplot(file, dt_begin, dt_end, nfft, fs, ...
    lwin, olap, title)
% [ax, ax2] = FILE_SPECDENSPLOT(file, dt_begin, dt_end, nfft, fs, ...
%                               lwin, olap, title)
% Makes a spectral density plot from a file
%
% INPUT:
% file      Full-filename
% dt_begin  Datetime at the beginning
% dt_end    Datetime at the end
% nfft      Number of frequencies
% fs        Sampling frequency (Hz)
% lwin      Length of windowed segment, in samples
% olap      Overlap of data segments, in percent
% title     Title of the plot
%
% OUTPUT:
% ax        Axes handling the frequency axis and the plot
% ax2       Axes handling the period axis
% 
% SEE ALSO:
% READONEYEARDATA, PLOT_SPECDENSPLOT

% reads the file
[x, dt_file_begin, dt_file_end] = readOneYearData(file, fs);

defval('dt_begin', dt_file_begin);
defval('dt_end', dt_file_end);

% check if dt_begin and dt_end is valid
if dt_begin >= dt_end || dt_begin > dt_file_end || dt_end < dt_file_begin
    fprintf('ERROR: invalid dt_begin or dt_end\n');
    return
end

dt_begin = max(dt_begin, dt_file_begin);
dt_end = min(dt_end, dt_file_end);
defval('title', strcat(string(dt_begin), " -- ", string(dt_end)));

% slices the data
first_index = fs * seconds(dt_begin - dt_file_begin) + 1;
last_index = fs * seconds(dt_end - dt_file_begin);
x = x(first_index:last_index);

% makes a plot
[ax, ax2] = plot_specdensplot(x, nfft, fs, lwin, olap, title);
end