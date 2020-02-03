function [ax, ax2] = plot_specdensplot(dt, freqs, nfft, fs, lwin, olap, title)

% creates sine functions
t = 0:dt*fs;
x = 0;
for ii = 1:length(freqs)
    x = x + sin(2 * pi * freqs(ii) * t / fs);
end

% normalizes the funciton
x = 100 * x / length(freqs);

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