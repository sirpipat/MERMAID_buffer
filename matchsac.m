function [dt_B, dt_E, Cmax, Cfmax, t_shift, t_shiftf] = matchsac(sacfile, oneyeardir, savedir)
% Finds a section in OneYearData that SAC file belongs to
% Then plots xcorr and matched signals
%
% INPUT:
% sacfile       Full filename of the sacfile
% merdir        Directory of the MERMAID files [Default: $ONEYEAR]
% savedir       Directory you wish to save the figures
%
% OUTPUT:
% Cmax          Maximum cross correlation of raw signals
% Cfmax         Maximum cross correlation of filtered signals
% t_shift       Best-fitted time shift for raw signals
% t_shift       Best-fitted time shift for filtered signals
%
% SEE ALSO:
% READSAC, GETSECTIONS, READSECTION, 
%
% Last modified by Sirawich Pipatprathanporn, 02/06/2020

defval('merdir', getenv('ONEYEAR'));

% file name for figures
split_name = split(removepath(sacfile), '.');
filename = cell2mat(split_name(1));

% maximum margin from both end of SAC datetimes in seconds
max_margin = seconds(200);

% reads data from SAC file
[x_sac, Hdr, ~, ~, tims] = readsac(sacfile);
dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
    Hdr.NZMSEC, 'TimeZone', 'UTC') + days(Hdr.NZJDAY);
dt_B = dt_ref + seconds(Hdr.B);
dt_E = dt_ref + seconds(Hdr.E);

fprintf("Reported section: %s -- %s\n", string(dt_B), string(dt_E));

%% Second round: interpolate before xcorr
% interpolates SAC data to obtain sampling frequency at 20 Hz
dt_sac = dt_ref + seconds(tims);
dt_interp = transpose(dateshift(dt_B,'start','second'):seconds(1/20):dt_E);
x_sac = lowpass(x_sac,1/Hdr.DELTA,10,2,2,'butter','linear');
x_sac_interp = interp1(dt_sac,x_sac,dt_interp,'linear');
% removes NaN datapoints
dt_interp = dt_interp(~isnan(x_sac_interp));
x_sac_interp = x_sac_interp(~isnan(x_sac_interp));

dt_B = dt_interp(1);
dt_E = dt_interp(end);

% finds raw file(s) containing dt_B and dt_E
[sections, intervals] = getsections(oneyeardir, dt_B - max_margin, ...
    dt_E + max_margin);
% update max_margin
max_margin = seconds(dt_B - intervals{1}{1});

% reads the section from raw file(s)
% Assuming there is only 1 secion
[x_raw, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
    intervals{1}{2});

% decimate the raw section to obtain sampling rax_rawd10te about 20 Hz
x_rawd20 = decimate(x_raw, 2);

% zero pads before and after the SAC section to get the same length as
% the raw setion
x_before = zeros(round(seconds(dt_B - dt_begin) * 20), 1);
x_after = zeros(length(x_rawd20) - length(x_before) - length(x_sac_interp) , 1);
x_sac = cat(1, x_before, x_sac_interp, x_after);

% decimates to obtain sampling rate about 10 Hz
fs = 10;
x_sacd10 = decimate(x_sac, 2);
x_rawd10 = decimate(x_raw, 4);

% applies Butterworth bandpass 0.05-0.10 Hz
x_sacf = bandpass(x_sacd10, fs, 0.05, 0.10, 2, 2, 'butter', 'linear');
x_rawf = bandpass(x_rawd10, fs, 0.05, 0.10, 2, 2, 'butter', 'linear');

% finds timeshift for raw SAC signal
[C, lag] = xcorr(x_rawd20, x_sac, 'coeff');
[Cmax, Imax] = max(C);
t_shift = ((Imax - length(x_rawd20)) / 20);
fprintf('shifted time [RAW]      = %f s\n', t_shift);

% find timeshift for filtered SAC signal
[Cf, lagf] = xcorr(x_rawf, x_sacf, 'coeff');
[Cfmax, Ifmax] = max(Cf);
t_shiftf = ((Ifmax - length(x_rawf)) / 10);
fprintf('shifted time [FILTERED] = %f s\n', t_shiftf);

%% plots
figure(6)
clf
set(gcf,'Units','inches','Position',[2 2 6.5 7.5]);
% plot raw buffer
ax1 = subplot('Position',[0.05 6/7+0.02 0.9 1/7-0.06]);
ax1 = signalplot(x_rawd10, fs, dt_begin, ax1, 'Unfiltered RAW', 'left', 'blue');
hold on
vline(ax1, dt_B + seconds(t_shift), '--', 2, 'r');
[~,y] = norm2trueposition(ax1, 0, 0.9);
text(dt_B + seconds(t_shift + 10), y, 'Begin', 'Color', 'r');
vline(ax1, dt_E + seconds(t_shift), '--', 2, 'r');
text(dt_E + seconds(t_shift - 40), y, 'End', 'Color', 'r');
hold off

% plot event sac
ax2 = subplot('Position',[0.05 5/7+0.02 0.9 1/7-0.06]);
ax2 = signalplot(x_sacd10, fs, dt_begin, ax2, 'Unfiltered SAC', 'left', 'black');
hold on
vline(ax2, dt_B, '--', 2, 'r');
[~,y] = norm2trueposition(ax2, 0, 0.9);
text(dt_B + seconds(10), y, 'Begin', 'Color', 'r');
vline(ax2, dt_E, '--', 2, 'r');
text(dt_E - seconds(45), y, 'End', 'Color', 'r');
hold off

% plot zoom-in sections
ax3 = subplot('Position',[0.05 4/7+0.02 0.42 1/7-0.06]);
ax3 = signalplot(x_rawd10, fs, dt_begin, ax3, 'Unfiltered RAW', 'left', 'blue');
ax3.XLim = [dt_B dt_E];

ax4 = subplot('Position',[0.05 3/7+0.02 0.42 1/7-0.06]);
ax4 = signalplot(x_sacd10, fs, dt_begin, ax4, 'Unfiltered SAC', 'left', 'black');
ax4.XLim = [dt_B dt_E];

% plot zoom-in sections
ax5 = subplot('Position',[0.53 4/7+0.02 0.42 1/7-0.06]);
ax5 = signalplot(x_rawf, fs, dt_begin, ax5, 'Filtered RAW', 'left', 'blue');
ax5.XLim = [dt_B dt_E];

ax6 = subplot('Position',[0.53 3/7+0.02 0.42 1/7-0.06]);
ax6 = signalplot(x_sacf, fs, dt_begin, ax6, 'Filtered SAC', 'left', 'black');
ax6.XLim = [dt_B dt_E];

% plot raw cc
ax7 = subplot('Position',[0.05 2/7+0.02 0.42 1/7-0.06]);
plot(lag / 20, C, 'Color', 'black');
hold on
plot(t_shift, Cmax, 'Marker', '+', 'Color', 'r', 'MarkerSize', 8);
hold off
grid on
title('XCORR [unfiltered]');
xlabel('time shift [s]');
ylabel('XCORR');
xlim([-200 200]);
ylim([-1 1]);

% plot filter cc
ax8 = subplot('Position',[0.53 2/7+0.02 0.42 1/7-0.06]);
plot(lagf / 10, Cf, 'Color', 'black');
hold on
plot(t_shiftf, Cfmax, 'Marker', '+', 'Color', 'r', 'MarkerSize', 8);
hold off
grid on
title('XCORR [filtered, 0.05-0.10 Hz]');
xlabel('time shift [s]');
ylabel('XCORR');
xlim([-200 200]);
ylim([-1 1]);

% plot 2 signals on top of each other
ax9 = subplot('Position',[0.05 1/7+0.02 0.42 1/7-0.06]);
ax9 = signalplot(x_rawd10, fs, dt_begin-seconds(t_shift), ax9, '', ...
    'left', 'blue');
hold on
ax_title = sprintf('Unfiltered: aligned');
ax9 = signalplot(x_sacd10, fs, dt_begin, ax9, ax_title, 'left', 'black');
hold off
x_left = dt_B + (dt_E - dt_B) * 1/3;
x_right = dt_B + (dt_E - dt_B) * 2/3;
xlim([x_left x_right]);
legend('raw','sac');

% plot 2 signals on top of each other
ax10 = subplot('Position',[0.53 1/7+0.02 0.42 1/7-0.06]);
ax10 = signalplot(x_rawf, fs, dt_begin-seconds(t_shiftf), ax10, '', ...
    'left', 'blue');
hold on
ax_title = sprintf('Filtered: aligned');
ax10 = signalplot(x_sacf, fs, dt_begin, ax10, ax_title, 'left', 'black');
hold off
x_left = dt_B + (dt_E - dt_B) * 1/3;
x_right = dt_B + (dt_E - dt_B) * 2/3;
xlim([x_left x_right]);
legend('raw','sac');

% report t_shift and Cmax on an empty axes
ax11 = subplot('Position',[0.02 0.02 0.42 1/7-0.06]);
ax11.Color = 'none';
text(8/9*ax11.XLim(1)+1/9*ax11.XLim(2),1/4*ax11.YLim(1)+3/4*ax11.YLim(2),...
    sprintf('Time shift  = %7.3f seconds',t_shift),'FontSize',12);
text(8/9*ax11.XLim(1)+1/9*ax11.XLim(2),3/4*ax11.YLim(1)+1/4*ax11.YLim(2),...
    sprintf('maxium cc = %7.3f',Cmax),'FontSize',12);
ax11.XAxis.Visible = 'off';
ax11.YAxis.Visible = 'off';

% report t_shiftf and Cfmax on an empty axes
ax12 = subplot('Position',[0.53 0.02 0.42 1/7-0.06]);
ax12.Color = 'none';
text(15/16*ax12.XLim(1)+1/16*ax12.XLim(2),1/4*ax12.YLim(1)+3/4*ax12.YLim(2),...
    sprintf('Time shift  = %7.3f seconds',t_shiftf),'FontSize',12);
text(15/16*ax12.XLim(1)+1/16*ax12.XLim(2),3/4*ax12.YLim(1)+1/4*ax12.YLim(2),...
    sprintf('maxium cc = %7.3f',Cfmax),'FontSize',12);
ax12.XAxis.Visible = 'off';
ax12.YAxis.Visible = 'off';

%% save the figure
savefile = strcat(savedir, filename, '.eps');
saveas(gcf, savefile, 'epsc');
% 
% % plot filtered signals
% figure(4);
% ax1 = subplot(2,1,2);
% ax1 = signalplot(x_sacf, fs, dt_begin, ax1, ...
%     'Filtered SAC [0.05-0.10 Hz]');
% ax2 = subplot(2,1,1);
% ax2 = signalplot(x_merf, fs, dt_begin, ax2, ...
%     'Filtered RAW [0.05-0.10 Hz]');
% ax1.XLim = ax2.XLim  - seconds(t_shiftf);
% ax1.YLim = ax2.YLim;
% 
% savefile = strcat(savedir, filename, '_match_fil.eps');
% saveas(gcf, savefile, 'epsc');
end