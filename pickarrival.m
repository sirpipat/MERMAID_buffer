function [pick, snr] = pickarrival(x, fs, t_begin, win_noise, win_signal, plt)
% Determines arrival time by dividing the time-series data into noise
% (before the arrival time) and signal (after the arrival time) which gives
% the maximum signal-to-noise ratio.
%
% INPUT
% x             data
% fs            sampling rate
% t_begin       time or datetime of the first sample [default: 0.0]
% win_noise     window length of the moving mean-squared of the noise
% win_signal    window length of the moving mean-squared of the signal
% plt           whether to plot the picks or not [default: false]
%
% OUTPUT
% pick          best-picked arrival time
%
% Last modified by Sirawich Pipatprathanporn, 07/11/2021

defval('plt', false)
defval('t_begin', 0.0)

if size(x, 1) == 1
    x = x';
end

if and(win_noise > 0, win_signal > 0)
    % compute moving mean square
    w1 = ones(round(fs * win_noise), 1) / round(fs * win_noise);
    ms_noise = conv(x .^ 2, w1, 'same');
    w2 = ones(round(fs * win_signal), 1) / round(fs * win_signal);
    ms_signal = conv(x .^ 2, w2, 'same');

    % determines the signal-to-noise ratio
    snr = ones(size(x));
    for ii = 1:size(snr, 1)
        snr(ii, 1) = ms_signal(min(ii + round(fs * win_signal/2), ...
            length(snr)), 1) / ...
            ms_noise(max(ii - round(fs * win_noise/2), 1), 1);
    end
else
    snr = ones(size(x));
    for ii = 1:size(snr, 1)
        index = max(round(fs * 100), min(ii, length(x) - round(fs * 100)));
        snr(ii, 1) = mean(x(index:end).^2) / mean(x(1:index).^2);
    end
end
[~, index] = max(snr);
if isdatetime(t_begin)
    pick = seconds(index - 1) / fs + t_begin;
else
    pick = (index - 1) / fs + t_begin;
end

if plt
    figure(5)
    clf
    ax1 = subplot(2, 1, 1);
    signalplot(x, fs, t_begin, ax1, 'time-series plot', [], 'k');
    hold on
    if isdatetime(t_begin)
        t = seconds((0:length(x) - 1)' / fs) + t_begin;
    else
        t = (0:length(x) - 1)' / fs + t_begin;
    end
    if and(win_noise > 0, win_signal > 0)
        plot(t, sqrt(ms_noise), 'Color', rgbcolor('r'), 'LineWidth', 1);
        plot(t, sqrt(ms_signal), 'Color', rgbcolor('my green'), ...
            'LineWidth', 1);
    end
    vline(ax1, pick, 'LineStyle', '-', 'LineWidth', 2, ...
        'Color', rgbcolor('my blue'));
    grid on
    xlabel('time (s)')
    if and(win_noise > 0, win_signal > 0)
        legend('data', 'noise moving rms', 'signal moving rms', ...
            'Location', 'best')
    end
    ax2 = subplot(2, 1, 2);
    plot(t, snr, 'Color', rgbcolor('pp'), 'LineWidth', 1);
    vline(ax2, pick, 'LineStyle', '-', 'LineWidth', 2, ...
        'Color', rgbcolor('my blue'));
    grid on
    ax2.XLim = ax1.XLim;
    xlabel('time(s)')
    ylabel('signal-to-noise ratio')
    title('signal-to-noise ratio')
end
end
