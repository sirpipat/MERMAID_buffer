function signalplot(x, fs)

L = length(x);
t = (-L/2:L/2-1) / fs;

plot(t, x);
title('Signal');       
xlabel('Time (s)')         
ylabel('Response');

end