% samples
n_samples = 4000;
fs_true = 500;
t = linspace(0, n_samples/fs_true, n_samples+1);

% construct the synthetic
% y = A_i * cos(o_i * t + p_i) [sum over i]
% A_i = amplitude
% o_i = angular frequency
% p_i = phase
len = 3;
A = zeros(1,len);
o = zeros(1,len);
p = zeros(1,len);
for ii = 1:len
    A(1,ii) = 1/ii;
    o(1,ii) = 2 * pi * 2^(ii-1);  % gives 1 Hz, 2 Hz, and 4 Hz
    p(1,ii) = 0. * ii * pi;
end

y = A(1,1) *  cos(o(1,1) * t + p(1,1));

for ii = 2:length(A)
    y = y + (A(1,ii) *  cos(o(1,ii) * t + p(1,ii)));
end

% filter y by using butterworth filter
window = 4;
fcen = 2;
% this window, [0.5 8], should allow all signal to pass
fc = [fcen/window fcen*window];

y1 = butter_filter_1_way(y, fc, fs_true);
y2 = butter_filter_2_ways(y, fc, fs_true);

p = plot(t, y, t, y1-3, t, y2-6);
p(1).LineWidth = 3;
p(2).LineWidth = 2;
p(3).LineWidth = 2;
legend('synthetic','filter [1-way]','filtfilt [2-ways]');
xlabel('time [s]')
title('butterworth: true sample rate = 500, fc = [0.500 8.000]');

function yf = butter_filter_1_way(y, fc, fs)
    [b,a] = butter(2,fc/(fs/2),'bandpass');
    yf = filter(b,a,y);
end

function yf = butter_filter_2_ways(y, fc, fs)
    [b,a] = butter(2,fc/(fs/2),'bandpass');
    yf = filtfilt(b,a,y);
end