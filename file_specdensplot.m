function [ax, ax2] = file_specdensplot(file, dt_begin, dt_end, nfft, fs, ...
    lwin, olap, title)
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