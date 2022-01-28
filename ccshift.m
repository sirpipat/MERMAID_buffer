function [t_shift, CCmax, lag, CC] = ...
    ccshift(x1,x2,dt_begin1,dt_begin2,fs,maxmargin,windowtype)
% [t_shift, CCmax, lag, CC] = ...
%   CCSHIFT(x1,x2,dt_begin1,dt_begin2,fs,maxmargin,windowtype)
%
% Compute correlation coefficients for all lags in [-maxmargin, maxmargin]
% between two unequal-length signals. If the two signals are equal in 
% length, you may use XCORR instead.
%
% INPUT:
% x1            A signal containing x2
% x2            A signal contained in x1
% dt_begin1     Begin datetime of x1
% dt_begin2     Begin datetime of x2
% fs            Sampling rate of both signals
% maxmargin     Maximum time shift as a duration
% windowtype    How to apply window to CC outside [-maxmargin maxmargin]
%               options are the following
%               'hard' -- boxcar window, zero outside  [default]
%               'soft' -- Gaussian curve outside the window with the
%                         variance of (maxmargin / 2)^2
%
% OUTPUT:
% t_shift       Best time shift where CC is maximum
% CCmax         Maximum correlation coefficient
% lag           Vector of all time shifts
% CC            Vector of CC for every time shift in lag
%
% Last modified by Sirawich Pipatprathanporn: 01/26/2022

defval('windowtype', 'hard')

% convert x1 and x2 to column vectors
if size(x1, 1) == 1
    x1 = x1';
end
if size(x2, 1) == 1
    x2 = x2';
end

% % detrend the signals
% x1 = detrend(x1, 1);
% x2 = detrend(x2, 1);

% swap x1 and x2 (if needed) to have x1 longer than x2
% then populate the lag time accordingly
if size(x1, 1) <= size(x2, 2)
    temp = x1;
    x1 = x2;
    x2 = temp;
    is_swapped = true;
    m = size(x1, 1);
    n = size(x2, 1);
    lag = seconds(dt_begin2 - dt_begin1) + ((-n+1):(m-1)) / fs;
else
    is_swapped = false;
    m = size(x1, 1);
    n = size(x2, 1);
    lag = seconds(dt_begin1 - dt_begin2) + ((-n+1):(m-1)) / fs;
end

% construct a (m+n-1) x n array to hold slices of x1 (longer section)
% n-1 zeros are padded on EACH end of x1
x1 = [zeros(n-1, 1); x1; zeros(n-1, 1)];
X = zeros(m+n-1, n);
for ii = 1:(m+n-1)
    X(ii, :) = x1(ii + (0:n-1))';
end

% compute the correlation coefficient at any lag time
CC = (n-1) / n * (X * x2) ./ sqrt(sum(X .* X, 2) * (x2' * x2));

% do not forget to swap back
if is_swapped
    lag = -lag;
    [lag, i_sort] = sort(lag);
    CC = CC(i_sort);
end

%%
switch lower(windowtype)
    case 'hard'
        CC(abs(lag) > seconds(maxmargin)) = 0;
    case 'soft'
        % soft window (flat within maxmargin, normal outside) to put less
        % weight on peaks outside the maxmargin window
        mm = seconds(maxmargin);
        w = exp(-(max(abs(lag), mm) - mm).^2 / (2 * (mm/2).^2))';
        CC = CC .* w;
    otherwise
        fprintf('Invalid option. Hard window is applied\n');
        CC(abs(lag) > seconds(maxmargin)) = 0;
end

% find best CC and timeshift
[CCmax, IImax] = max(CC);
t_shift = lag(IImax);
end