function signalplot(x, fs, position)

defval('position','left');

L = length(x);
t = (0:L-1) / fs;
if strcmp(position, 'center') == 1
    t = t - L/2/fs;
end

max_x = max([max(x) abs(min(x))]);

plot(t, x);
title('Signal');       
xlabel('Time (s)')         
ylabel('Response');
ylim([-max_x max_x]);
xlim([min(t) max(t)]);
end