function sinefit_timperiodplot(t, x, w, u, f)
% SINEFIT_TIMPERIODPLOT(t, x, w, u, f)
%
% Plots time-series and periodogram of a signal x(t) like TIMPERIODPLOT,
% but instead of using MATLAB built-in PERIODOGRAM, it computes
% coefficients of the sine, cosine, and steady-state terms using SINEFIT.
%
% INPUT
% t         time
% x         signal
% w         window          [default: boxcar window with weight = 1]
% u         unit of time    [default: 's']
% f         target frequencies
%
% SEE ALSO
% TIMPERIODPLOT
%
% Last modified by Sirawich Pipatprathanporn, 12/06/2020

defval('w', ones(size(x)))
defval('u', 's')

[~, ~, ~, ~, F, P] = sinefit(t, x, [], f);
[~, ~, ~, ~, Fw, Pw] = sinefit(t, x, w, f);

figure
clf
set(gcf, 'Unit', 'inches', 'Position', [2 2 4 5.5])
% plot time-series
ax1 = subplot('Position', [0.13 0.65 0.75 0.3]);
plot(t, x, 'Color', [0.95 0.7 0.5]);
hold on
plot(t, x .* w, '-k');
grid on
xlabel(sprintf('time (%s)', u))
ylabel('value')
title('Time-domain Signal')
set(gca, 'FontSize', 12, 'TickDir', 'both')

% plot periodogram
ax2 = subplot('Position', [0.13 0.1 0.75 0.3]);
plot(F, 10*log10(P), 'Color', [0.95 0.7 0.5])
hold on
plot(Fw, 10*log10(Pw), 'k')
grid on
xlabel('frequency (Hz)')
ylabel('Power/frequency (dB/Hz)')
set(gca, 'FontSize', 12, 'TickDir', 'both')
ax2s = doubleaxes(ax2);
inverseaxis(ax2s.XAxis, sprintf('period (%s)', u));
ax2s.Title.String = 'Periodogram PSD Estimate';
end