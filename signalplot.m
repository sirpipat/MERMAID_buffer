function signalplot(x, fs)

L = length(x);
t = (0:L-1) / fs;

plot(t, x);
title('Signal');       
xlabel('Time (s)')         
ylabel('Response');

end