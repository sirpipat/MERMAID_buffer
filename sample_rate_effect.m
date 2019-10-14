% time samples
n_samples = 10000;
fs_true = 500;
t = linspace(0, n_samples/fs_true, n_samples+1);

% construct the synthetic
len = 5;
A = zeros(1,len);
o = zeros(1,len);
p = zeros(1,len);
for ii = 1:len
    A(1,ii) = 1/ii;
    o(1,ii) = 2 * pi * 2^(ii-1);
    p(1,ii) = 0. * ii * pi;
end

% y = A_i * cos(o_i * t + p_i) [sum over i]
% A_i = amplitude
% o_i = angular frequency
% p_i = phase

y = A(1,1) *  cos(o(1,1) * t + p(1,1));

for ii = 2:length(A)
    y = y + (A(1,ii) *  cos(o(1,ii) * t + p(1,ii)));
end


% filter y
window = 1.1;
fcen = 4;
fc = [fcen/window fcen*window];

y1 = butter_filter_2_ways(y,fc,fs_true/4);
y2 = butter_filter_2_ways(y,fc,fs_true/2);
y3 = butter_filter_2_ways(y,fc,fs_true);
y4 = butter_filter_2_ways(y,fc,fs_true*2);
y5 = butter_filter_2_ways(y,fc,fs_true*4);

subplot(1,1,1)
p=plot(t,y,t,y1-2,t,y2-3,t,y3-4,t,y4-5,t,y5-6);
p(1).LineWidth = 3;
p(2).LineWidth = 2;
p(3).LineWidth = 2;
p(4).LineWidth = 2;
p(5).LineWidth = 2;
p(6).LineWidth = 2;
legend('synthetic','fs = 125','fs = 250','fs = 500','fs = 1000','fs = 2000');
xlabel('time [s]')
title('butterworth: true sample rate = 500, fc = [3.636 4.400]');

function yf = butter_filter_2_ways(y, fc, fs)
    [b,a] = butter(2,fc/(fs/2),'bandpass');
    yf = filtfilt(b,a,y);
end
