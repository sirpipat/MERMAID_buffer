function ax = signalplot(x, fs, t, ax, title_name, position, color)
% ax = SIGNALPLOT(x, fs, t, ax, title_name, position)
% Make a plot of the signal
%
% INPUT
% x         = input signal
% fs        = sampling frequency
% t         = time/datetime at the beginning
% ax        = current axes
% title     = title of the plot
% position  = position of zero either left or center
% color     = the color of the line
%
% OUTPUT
% ax        = handling axes of the plot
%
% Last modified by Sirawich Pipatprathanporn, 03/07/2020

defval('title_name', 'signal');
defval('position', 'left');
defval('color', 'black');

% seconds to days
s2d = 86400;

L = length(x);
t_plot = t + (0:L-1) / fs / s2d;
if strcmp(position, 'center') == 1
    t_plot = t_plot - L/2/fs / s2d;
end

max_x = max([max(x) abs(min(x))]);

% plots the signal
axes(ax);
plot(t_plot, x,'Color',color);
title('Signal');       
xlabel('Time')
ylim([-max_x max_x]);
xlim([min(t_plot) max(t_plot)]);
title(title_name);
grid on

% return the axes
ax = gca();
end