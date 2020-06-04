function [t_shift, CCmax, lag, CC] = ...
    ccshift(x1,x2,dt_begin1,dt_begin2,fs,maxmargin)
% [t_shift, CCmax, lag, CC] = ...
%   CCSHIFT(x1,x2,fs,dt_begin1,dt_begin2,fs,maxmargin)
%
% Compute correlation coefficients for all lags in [-maxmargin, maxmargin]
%
% INPUT:
% x1            A signal containing x2
% x2            A signal contained in x1
% dt_begin1     Begin datetime of x1
% dt_begin2     Begin datetime of x2
% fs            Sampling rate of both signals
% maxmargin     Maximum time shift as a duration
%
% OUTPUT:
% t_shift       Best time shift where CC is maximum
% CCmax         Maximum correlation coefficient
% lag           Vector of all time shifts
% CC            Vector of CC for every time shift in lag
%
% Last modified by Sirawich Pipatprathanporn: 06/01/2020

% Figure out the end time of each section
dt_end1 = dt_begin1 + seconds((length(x1) - 1) / fs);
dt_end2 = dt_begin1 + seconds((length(x2) - 1) / fs);

% create windows, CC (just a container), and lag
x1 = cat(1, x1, zeros(length(x2), 1));
num_window = length(x1) - length(x2) + 1;
CC = zeros(1, num_window);
lag = seconds(dt_begin1 - dt_begin2):(1/fs):seconds(dt_end1 - dt_end2);

% correct the length of lag
size_diff = length(CC) - length(lag);
if size_diff > 0
    lag_extension = (1:size_diff) / fs + lag(end);
    lag = [lag lag_extension];
elseif size_diff < 0
    lag = lag(1:length(CC));
end

% compute correlation coefficient between each sliced section of x1 and x2
for ii = 1:num_window
    x1_slice = x1((1:length(x2)) + ii - 1);
    CC(1,ii) = corr(detrend(x1_slice,1), detrend(x2,1));
end

% remove any data that lag is beyond +- maximum margin
CC(abs(lag) > seconds(maxmargin)) = 0;

% find best CC and timeshift
[CCmax, IImax] = max(CC);
t_shift = lag(IImax);
end