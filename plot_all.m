function plot_all(y, dt_begin, nfft, fs, lwin, olap, sfax, beg, unit)
% PLOT_ALL(y, dt_begin, nfft, fs, lwin, olap, sfax, beg, unit)
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
%
% OUTPUT
% No output returned. The plot is saved in 
% 
% Last modified by Sirawich Pipatprathanporn: 04/20/2020

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

% filters with f_c = [2 10] Hz
yf1 = bandpass(y, fs, 2, 10, 2, 2, 'butter', 'linear');

% filters with f_c = [0.05 0.10] Hz
d_factor = 5;
yd = detrend(decimate(y, d_factor),1);
yf2 = bandpass(yd, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');

%% Create figure
figure(2)
set(gcf, 'Unit', 'inches', 'Position', [18 8 6.5 7.5]);
clf

% plot title
ax0 = subplot('Position',[0.05 0.93 0.9 0.02]);
title(string(dt_begin));
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';

%%% plot spectogram
ax1 = subplot('Position', [0.06 4/7 0.43 3/7-0.12]);
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
% add label on the top and right
ax1.TickDir = 'both';
ax1s = doubleaxes(ax1);
ax1s.YAxis.Visible = 'off';
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax1, 1/8, 7/8);
text(x_pos, y_pos, 'A', 'FontSize', 12);

%%% plot power spectral density profile
ax2 = subplot('Position', [0.61 4/7 0.33 3/7-0.12]);
[p,xl,yl,F,SD,Ulog,Llog]=specdensplot(y,nfft,fs,lwin,olap,sfax,unit);
grid on
ylim([40 140]);
% change color line
p(1).Color = [0.8 0.25 0.25];
p(2).Color = [0.5 0.5 0.5];
p(3).Color = [0.5 0.5 0.5];
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
text(x_pos, y_pos, 'B', 'FontSize', 12);

%%% plot raw signal
ax3 = subplot('Position', [0.06 2/6+0.06 0.88 1/6-0.09]);
ax3 = signalplot(y, fs, dt_begin, ax3, '', 'left');
title('Raw buffer')
ax3.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(y);
ylim([-5*r 5*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax3, 1/12, 7/8);
text(x_pos, y_pos, 'C', 'FontSize', 12);

%%% plot raw signal
ax4 = subplot('Position', [0.06 1/6+0.06 0.88 1/6-0.09]);
ax4 = signalplot(yf1, fs, dt_begin, ax4, '', 'left');
title('Filtered: bp2-10')
ax4.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(yf1);
ylim([-10*r 10*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax4, 1/12, 7/8);
text(x_pos, y_pos, 'D', 'FontSize', 12);

%%% plot filtered signal
ax5 = subplot('Position', [0.06 0.06 0.88 1/6-0.09]);
ax5 = signalplot(yf2, fs/d_factor, dt_begin, ax5, '', 'left');
title('Filtered: dc5 dt bp0.05-0.1')
ax5.TickDir = 'both';
% set ylimit to exclude outliers
r = rms(yf2);
ylim([-5*r 5*r]);
% add subplot label
[x_pos, y_pos] = norm2trueposition(ax5, 1/12, 7/8);
text(x_pos, y_pos, 'E', 'FontSize', 12);

%% Save figure
savefile = strcat(string(dt_begin), '_all', '.eps');
figdisp(savefile, [], [], 2, [], 'epstopdf');
end

function ph = previous_hour(dt)
    ph = dt;
    ph.Minute = 0;
    ph.Second = 0;
end