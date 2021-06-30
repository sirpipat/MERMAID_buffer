function fig = timfreqplot(y, yf1, yf2, yf1_trigs, yf1_dtrigs, dt_begin, ...
    nfft, fs, lwindow, olap, sfax, beg, unit, p, save, trig, fscale, ...
    yunit)
% fig = TIMFREQPLOT(y, yf1, yf2, yf1_trigs, yf1_dtrigs, dt_begin, nfft, ...
%                   fs, lwindow, olap, sfax, beg, unit, p, save, trig, ...
%                   fscale, y_unit)
% plot seismogram, power spectral density, spectograms, and filtered
% seismogram
% 
% INPUT
% y             Data
% yf1           Filtered data 2-10 Hz       [optional]
% yf2           Filtered data 0.05-0.10 Hz  [optional]
% yf1_trigs     Triggers in yf1             [optional]
% yf1_dtrigs    Detriggers in yf1           [optional]
% dt_begin      Beginning datetime
% nfft          Number of FFT points        [default: 1024]
% fs            Sampling frequency          [default: 40.01406]
% lwindow          window length, in samples   [default: nfft]
% olap          window overlap, in percent  [default: 70]
% sfax          Y-axis scaling factor       [default: 10]
% beg           Signal beginning            [Default: 0]
% unit          String with the unit name   [Default: 's']
% p             Position of the section in the raw buffer file
%               when y is a sliced section. Otherwise, leave it blank
% save          whether to save the figure or not [Default: true]
% trig          whether to plot the (de)triggers in yf1 [Default: false]
% fscale        Scaling option for frequency axis: 
%                   'linear' or 'log' [default: 'log']
% yunit         unit of the data:
%                   'counts' or 'Pa'  [default: 'counts']
%
% OUTPUT
% fig           figure handling the plots
%
% If save is true, the output file is saved as $EPS.
% 
% Last modified by Sirawich Pipatprathanporn: 06/30/2021

% parameter list
defval('fs', 40.01406);
defval('nfft', 1024);
defval('lwindow', 1024);
defval('olap', 70);
defval('sfax', 10);
defval('beg', 0);
defval('unit', 's');
defval('save', true);
defval('trig', false);
defval('fscale', 'log');
defval('yunit', 'counts');
wolap = olap / 100;

dt_begin.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

dt_end = dt_begin + seconds((length(y)-1)/fs);

% dt bp2-10
if isempty(yf1)
    yf1 = bandpass(detrend(y,1), fs, 2, 10, 2, 2, 'butter', 'linear');
end

% dt dc5 dt bp0.05-0.1
d_factor = 5;
if isempty(yf2)
    yd = detrend(decimate(detrend(y,1), d_factor),1);
    yf2 = bandpass(yd, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');
end

%% Create figure
figure(2)
set(gcf, 'Unit', 'inches', 'Position', [18 8 6.5 7.5]);
clf

% plot title
ax0 = subplot('Position',[0.05 0.94 0.9 0.02]);
if length(p) == 2
    title(string(dt_begin), 'FontWeight', 'normal');
else
    title(sprintf('%s--%s', string(dt_begin), string(dt_end)), ...
        'FontWeight', 'normal');
end
[x_pos, y_pos] = norm2trueposition(ax0, 3/8, 3/4);
% report
if length(p) == 2
    text(x_pos, y_pos, sprintf('%2.2f - %3.2f percent', p(1), p(2)), ...
        'FontSize', 12);
end
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';

%% plot spectrogram
ax1 = subplot('Position', [0.075 4/7 0.42 3/7-0.12]);
timspecplot_ns(y,nfft,fs,lwindow,wolap,beg,unit,fscale);
title('');

% insert colorbar
c = colorbar;
c.Label.String = 'spectral density (energy/Hz)';
cPosition = c.Position;

% fix colormap for pressure case
if strcmp(yunit, 'Pa')
    m = colormap('jet');
    k = zeros(192, 3);
    m = [k; m];
    colormap(ax1, m)
    c.Limits = [-100 40];
end

% change xticks to HH:mm and date
t_ph = previous_hour(dt_begin);
ax1.XTick = (0:900:7200) - seconds(dt_begin - t_ph);
t_ph.Format = 'HH:mm';
ax1.XTickLabel = string(t_ph + seconds(0:900:7200));

% fix the precision of the time on XAxis label
ax1.XAxis.Label.String = sprintf('time (hh:mm): %d s window', round(nfft/fs));

% add label on the top and right
ax1.TickDir = 'both';
ax1s = doubleaxes(ax1);
ax1s.YAxis.Visible = 'off';
ax1.Position = ax1s.Position;
axes(ax1);
c.Position = cPosition;

% add subplot label
ax1b = addbox(ax1, [0 0.9 0.1 0.1]);
[x_pos, y_pos] = norm2trueposition(ax1b, 0.28, 3/5);
text(x_pos, y_pos, 'a', 'FontSize', 12);

%% plot power spectral density profile
ax2 = subplot('Position', [0.615 4/7 0.33 3/7-0.12]);
[p,xl,yl,F,SD,Ulog,Llog]=specdensplot(y,nfft,fs,lwindow,olap,sfax,unit);
grid on

xlim([0.0095 F(end)]);
xticks([0.01 0.1 1 10]);
xticklabels({'0.01', '0.1', '1', '10'});
if strcmp(yunit, 'counts')
    ylim([40 145]);
elseif strcmp(yunit, 'Pa')
    ylim([-80 40]);
end

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
inverseaxis(ax2s.XAxis, 'period (s)');

% add frequency bands label
hold on
ax2 = vline(ax2, [0.05, 0.1], '-', 1, rgbcolor('green'));
ax2 = vline(ax2, [2, 10], '-', 1, rgbcolor('brown'));
hold off
% move the frequency bands to the back
ax2.Children = ax2.Children([5:end 1:4]);

% add subplot label
ax2b = addbox(ax2, [0 0.9 0.1 0.1]);
[x_pos, y_pos] = norm2trueposition(ax2b, 0.28, 3/5);
text(x_pos, y_pos, 'b', 'FontSize', 12);

%% plot raw signal
ax3 = subplot('Position', [0.075 2/6+0.03 0.87 1/6-0.06], 'Box', 'on');
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

% set ylimit to exclude outliers
r = rms(y);
ylim([-5.25*r 5.25*r]);

% add title
tt = title('raw buffer -- green = mov avg, red = mov rms, window = 30 s', ...
    'FontWeight', 'normal');
tt.Position(2) = ax3.YLim(2) * 1.15;
%title('')
ylabel(yunit)
ax3.TitleFontSizeMultiplier = 1.0;
ax3.TickDir = 'both';

% add subplot label
ax3b = addbox(ax3, [0 0.75 0.04 0.25]);
[x_pos, y_pos] = norm2trueposition(ax3b, 0.28, 3/5);
text(x_pos, y_pos, 'c', 'FontSize', 12);

% remove xlabel
nolabels(ax3, 1);
ax3.XAxis.Label.Visible = 'off';

%% plot filered signal 2-10 Hz
ax4 = subplot('Position', [0.075 1/6+0.05 0.87 1/6-0.06], 'Box', 'on');
ax4 = signalplot(yf1, fs, dt_begin, ax4, '', 'left');

% add moving average
mov_mean = movmean(yf1, round(fs * 30));
t_plot = dt_begin + seconds((0:length(yf1)-1) / fs);
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off

% add moving rms
r = rms(yf1);
yf1_sq = yf1 .^ 2;
mov_rms = movmean(yf1_sq, round(fs * 30)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off

% set ylimit to exclude outliers
ylim([-10.5*r 10.5*r]);

% add title
tt = title('filtered: bp2-10 -- green = mov avg, red = mov rms, window = 30 s', ...
    'FontWeight', 'normal');
tt.Position(2) = ax4.YLim(2) * 1.15;
%title('')
ylabel(yunit)
ax4.TitleFontSizeMultiplier = 1.0;
ax4.TickDir = 'both';

% add trigger times and detrigger times
if trig && (isempty(yf1_trigs) || isempty(yf1_dtrigs))
    fprintf('Run pickpeaks in timfreqplot.m\n');
    [yf1_trigs,yf1_dtrigs] = pickpeaks(yf1, fs, 30, 600, 1.5, 1.5, 60);
%     fprintf('Run stalta in timfreqplot.m\n');
%     [trigt,~,~,ratio,~,~,~,~,~]=stalta(yf1 ,1/fs , ...
%         [0 ((length(yf1)-1) / fs)], 30, 600, 1.5, 1.5, 180, 60, 30, 20);
%     [yf1_trigs,yf1_dtrigs] = simplifyintervals(trigt(:,1), trigt(:,2));
    yf1_trigs = dt_begin + seconds(yf1_trigs);
    yf1_dtrigs = dt_begin + seconds(yf1_dtrigs);
end

% remove trigger/detrigger times outside the section
if trig
    yf1_trigs = yf1_trigs(and(yf1_trigs >= dt_begin, yf1_trigs <= dt_end));
    yf1_dtrigs = yf1_dtrigs(and(yf1_dtrigs >= dt_begin, yf1_dtrigs <= dt_end));

    hold on
    for ii = 1:length(yf1_trigs)
        vline(ax4, yf1_trigs(ii), '-', 1, [0.9 0.5 0.2]);
    end
    for ii = 1:length(yf1_dtrigs)
        vline(ax4, yf1_dtrigs(ii), '-', 1, [0.2 0.5 0.9]);
    end
    hold off
end

% move trigger/detrigger times to the back
ax4.Children = ax4.Children([(end-2):end 1:(end-3)]);

% add subplot label
ax4b = addbox(ax4, [0 0.75 0.04 0.25]);
[x_pos, y_pos] = norm2trueposition(ax4b, 0.28, 3/5);
text(x_pos, y_pos, 'd', 'FontSize', 12);

% remove xlabel
nolabels(ax4, 1);
ax4.XAxis.Label.Visible = 'off';

%% plot filtered signal 0.05-0.1 Hz
ax5 = subplot('Position', [0.075 0.07 0.87 1/6-0.06], 'Box', 'on');
ax5 = signalplot(yf2, fs/d_factor, dt_begin, ax5, '', 'left');
xlabel('time (hh:mm)')

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

% set ylimit to exclude outliers
r = rms(yf2);
ylim([-5.25*r 5.25*r]);

% add title
tt = title('filtered: dc5 dt bp0.05-0.1 -- green = mov avg, red = mov rms, window = 150 s', ...
    'FontWeight', 'normal');
tt.Position(2) = ax5.YLim(2) * 1.15;
%title('')
ylabel(yunit)
ax5.TitleFontSizeMultiplier = 1.0;
ax5.TickDir = 'both';

% add subplot label
ax5b = addbox(ax5, [0 0.75 0.04 0.25]);
[x_pos, y_pos] = norm2trueposition(ax5b, 0.28, 3/5);
text(x_pos, y_pos, 'e', 'FontSize', 12);

fig = gcf;

%% Save figure
if save
    savefile = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
end
end

function ph = previous_hour(dt)
    ph = dt;
    ph.Minute = 0;
    ph.Second = 0;
end
