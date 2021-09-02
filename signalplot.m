function ax = signalplot(x, fs, t, ax, title_name, position, color, varargin)
% ax = SIGNALPLOT(x, fs, t, ax, title_name, position, color, varargin)
% Make a plot of the signal
%
% INPUT
% x             input signal
% fs            sampling frequency
% t             time/datetime at the beginning
% ax            current axes
% title_name    title of the plot
% position      position of zero either left or center
% color         the color of the line
% varargin      arguments for plot()
%
% OUTPUT
% ax        = handling axes of the plot
%
% Last modified by Sirawich Pipatprathanporn, 09/01/2021

defval('title_name', 'signal');
defval('position', 'left');
defval('color', 'black');

% seconds to days
s2d = 86400;

L = length(x);

% time (s) input
if isnumeric(t)
    t_plot = t + (0:L-1) / fs;
    if strcmp(position, 'center') == 1
        t_plot = t_plot - L/2/fs;
    end
% datetime input
else
    t_plot = t + (0:L-1) / fs / s2d;
    if strcmp(position, 'center') == 1
        t_plot = t_plot - L/2/fs / s2d;
    end
end

max_x = max([max(x) abs(min(x))]);

% plots the signal
axes(ax);
hold on
plot(t_plot, x, 'Color', color, varargin{:});
title('Signal');       
xlabel('time')
if max_x == 0
    ylim([-1 1]);
else
    ylim([-max_x max_x]);
end
xlim([min(t_plot) max(t_plot)]);
title(title_name);
grid on

% return the axes
ax = gca();
end