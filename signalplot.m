function signalplot(x, fs, t, position)
% signalplot(x, fs, position)
% Make a plot of the signal
%
% INPUT
% x         = input signal
% fs        = sampling frequency
% position  = position of zero either left or center
% Last modified by Sirawich Pipatprathanporn, 11/23/2019

defval('position','left');

% seconds to days
s2d = 86400;

L = length(x);
t_plot = t + (0:L-1) / fs / s2d;
if strcmp(position, 'center') == 1
    t_plot = t_plot - L/2/fs / s2d;
end

max_x = max([max(x) abs(min(x))]);

plot(t_plot, x);
title('Signal');       
xlabel('Time')
ylim([-max_x max_x]);
xlim([min(t_plot) max(t_plot)]);
grid on
end