function signalplot(x, fs)

L = length(x);
t = (0:L-1) / fs;
max_x = max([max(x) abs(min(x))]);

plot(t, x);
title('Signal');       
xlabel('Time (s)')         
ylabel('Response');
xlim([0 (L-1)/fs]);
ylim([-max_x max_x]);
end