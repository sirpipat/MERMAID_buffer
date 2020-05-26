function timfreqplot(y, dt_begin, nfft, fs, lwin, olap, sfax, beg, unit, p)
% TIMFREQPLOT(y, dt_begin, nfft, fs, lwin, olap, sfax, beg, unit)
% plot seismogram, power spectral density, spectograms, and filtered
% seismogram
% 
% INPUT
% y             Data
% dt_begin      Beginning datetime
% nfft          Number of FFT points [default: lwin]
% fs            Sampling frequency [Default: 40.01406]
% lwin          Window length, in samples [default: 256]
% olap          Window overlap, in percent [default: 70]
% sfax          Y-axis scaling factor [default: 10]
% beg           Signal beginning [Default: 0]
% unit          String with the unit name [Default: 's']
% p             Position of the section in the raw buffer file
%               when y is a sliced section. Otherwise, leave it blank
%
% OUTPUT
% No output returned. The plot is saved in 
% 
% Last modified by Sirawich Pipatprathanporn: 05/27/2020

% parameter list
defval('fs', 40.01406);
defval('nfft', 1024);
defval('lwin', 1024);
defval('olap', 70);
defval('sfax', 10);
defval('beg', 0);
defval('unit', 's');
wolap = olap / 100;

dt_begin.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

% dt bp2-10
yf1 = bandpass(detrend(y,1), fs, 2, 10, 2, 2, 'butter', 'linear');

% dt dc5 dt bp0.05-0.1
d_factor = 5;
yd = detrend(decimate(detrend(y,1), d_factor),1);
yf2 = bandpass(yd, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');

%% Create figure
figure(2)
set(gcf, 'Unit', 'inches', 'Position', [18 8 6.5 7.5]);
clf

% plot title
ax0 = subplot('Position',[0.05 0.93 0.9 0.02]);
title(string(dt_begin));
[x_pos, y_pos] = norm2trueposition(ax0, 3/8, 3/4);
% report
text(x_pos, y_pos, sprintf('%2.2f - %3.2f percent', p(1), p(2)), ...
    'FontSize', 12);
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';

%%% plot spectogram
ax1 = subplot('Position', [0.07 4/7 0.42 3/7-0.12]);
timspecplot_ns(y,nfft,fs,lwin,wolap,beg,unit);
title('');
% insert colorbar
c = colorbar;
c.Label.String = 'spectral density (energy/Hz)';
% change xticks to HH:mm and date
t_ph = previous_hour(dt_begin);
ax1.XTick = (0:900:7200) - seconds(dt_begin - t_ph);
t_ph.Format = 'HH:mm';
ax1.XTickLabel = string(t_ph + seconds(0:900:7200));
% fix the precision of the time on XAxis label
ax1.XAxis.Label.String = sprintf('time (s): %d s window', round(nfft/fs));
% add label on the top and right
ax1.TickDir = 'both';
ax1s = doubleaxes(ax1);
ax1s.YAxis.Visible = 'off';
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax1, 1/8, 7/8);
text(x_pos, y_pos, 'a', 'FontSize', 12);

%%% plot power spectral density profile
ax2 = subplot('Position', [0.61 4/7 0.33 3/7-0.12]);
[p,xl,yl,F,SD,Ulog,Llog]=specdensplot(y,nfft,fs,lwin,olap,sfax,unit);
grid on
ylim([40 140]);
% change color line
p(1).Color = [0.8 0.25 0.25];
p(2).Color = [0.5 0.5 0.5];
p(3).Color = [0.5 0.5 0.5];
% fix the precision of the time on XAxis label
ax2.XAxis.Label.String = sprintf('frequency (Hz): %d s window', round(nfft/fs));
% fix the precision of the frequency on YAxis label
y_label = ax2.YAxis.Label.String;
y_split = split(y_label, '=');
f_string = sprintf(' %.4f', fs/nfft);
y_label = strcat(y_split{1}, ' =', f_string);
ax2.YAxis.Label.String = y_label;
% add label on the top and right
ax2.TickDir = 'both';
ax2s = doubleaxes(ax2);
% add axis label
inverseaxis(ax2s.XAxis, 'Period (s)');
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax2, 1/800, 7/8);
text(x_pos, y_pos, 'b', 'FontSize', 12);

%%% plot raw signal
ax3 = subplot('Position', [0.07 2/6+0.02 0.87 1/6-0.06]);
ax3 = signalplot(y, fs, dt_begin, ax3, '', 'left');
% add moving average
mov_mean = movmean(y, round(fs * 30));
t_plot = dt_begin + seconds((0:length(y)-1) / fs);
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off
% add moving rms
y_sq = y .^ 2;
mov_rms = movmean(y_sq, round(fs * 30)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off
title('Raw buffer -- green = mov avg, red = mov rms, win = 30 s')
ax3.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(y);
ylim([-5*r 5*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax3, 1/12, 7/8);
text(x_pos, y_pos, 'c', 'FontSize', 12);
% remove xlabel
nolabels(ax3, 1);
ax3.XAxis.Label.Visible = 'off';

%%% plot filered signal 2-10 Hz
ax4 = subplot('Position', [0.07 1/6+0.04 0.87 1/6-0.06]);
ax4 = signalplot(yf1, fs, dt_begin, ax4, '', 'left');
% add moving average
mov_mean = movmean(yf1, round(fs * 30));
t_plot = dt_begin + seconds((0:length(yf1)-1) / fs);
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off
% add moving rms
yf1_sq = yf1 .^ 2;
mov_rms = movmean(yf1_sq, round(fs * 30)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off
title('Filtered: bp2-10 -- green = mov avg, red = mov rms, win = 30 s')
ax4.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(yf1);
ylim([-10*r 10*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax4, 1/12, 7/8);
text(x_pos, y_pos, 'd', 'FontSize', 12);
% remove xlabel
nolabels(ax4, 1);
ax4.XAxis.Label.Visible = 'off';

%%% plot filtered signal 0.05-0.1 Hz
ax5 = subplot('Position', [0.07 0.06 0.87 1/6-0.06]);
ax5 = signalplot(yf2, fs/d_factor, dt_begin, ax5, '', 'left');
% add moving average
mov_mean = movmean(yf2, round(fs/d_factor * 150));
t_plot = dt_begin + seconds((0:length(yf2)-1) / (fs/d_factor));
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off
% add moving rms
yf2_sq = yf2 .^ 2;
mov_rms = movmean(yf2_sq, round(fs/d_factor * 150)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off
title('Filtered: dc5 dt bp0.05-0.1 -- green = mov avg, red = mov rms, win = 150 s')
ax5.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(yf2);
ylim([-5*r 5*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax5, 1/12, 7/8);
text(x_pos, y_pos, 'e', 'FontSize', 12);

%% Save figure
savefile = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
figdisp(savefile, [], [], 2, [], 'epstopdf');
end

function ph = previous_hour(dt)
    ph = dt;
    ph.Minute = 0;
    ph.Second = 0;
end
