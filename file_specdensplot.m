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
% READSECTION, PLOT_SPECDENSPLOT
%
% Last modified by Sirawich Pipatprathanporn: 02/05/2020

% reads the file
[x, dt_begin, dt_end] = readsection(file, dt_begin, dt_end);

defval('title', strcat(string(dt_begin), " -- ", string(dt_end)));

% makes a plot
[ax, ax2] = plot_specdensplot(x, nfft, fs, lwin, olap, title);
end