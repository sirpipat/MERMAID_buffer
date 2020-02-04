function [ax, ax2] = plot_specdensplot(x, nfft, fs, lwin, olap, title)
% [ax, ax2] = PLOT_SPECDENSPLOT(x, nfft, fs, lwin, olap, title)
% Makes spectral density plot with both frequency and period axis from a 
% signal
%
% INPUT:
% x         Signal in time domain
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
% SEE ALSO
% SPECDENSPLOT, DOUBLEAXES, INVERSEAXIS
%
% Last modified by Sirawich Pipatprathanporn: 02/04/2020

% makes a plot
specdensplot(x, nfft, fs, lwin, olap, 10, 's');
grid on
ax = gca();
ax.TickDir = 'both';
ax.Position = [0.15 0.15 0.7 0.7];
ax.YLabel.String = ...
    strcat("spectral density (energy/Hz) ; \Delta\it f = ", ...
    sprintf("%0.4f", fs/nfft));
ax.Title.String = title;

% adds XTickLabels at both ends of XAxis
% works on specdensplot only
min_value = ax.Children(1).XData(2);
max_value = ax.XLim(2);
if min_value < ax.XTick(1)
    ax.XTick = cat(2, min_value, ax.XTick);
end
if max_value > ax.XTick(length(ax.XTick))
    ax.XTick = cat(2, ax.XTick, max_value);
end

% adds the second axes
ax2 = doubleaxes(ax);

% make inverse XAxis
inverseaxis(ax2.XAxis, 'period (s)');

% adjusts XTickLabel
ax2.XTickLabel{1} = string(nfft/fs);
% removes labels if they may overlap each other
if ax.XTick(2) < ax.XTick(1) * 2
    ax.XTickLabel{2} = '';
    ax2.XTickLabel{2} = '';
end
end