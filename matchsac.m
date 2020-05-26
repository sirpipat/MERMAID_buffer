function [dt_B, dt_E, CCmax, CCfmax, t_shift, t_shiftf] = matchsac(sacfile, oneyeardir, savedir, maxmargin, plt, plotfilter)
% [dt_B, dt_E, Cmax, Cfmax, t_shift, t_shiftf] = MATCHSAC(sacfile, oneyeardir, savedir, plt)
% Finds a section in OneYearData that SAC file belongs to
% Then plots xcorr and matched signals
%
% INPUT:
% sacfile       Full filename of the sacfile
% oneyeardir    Directory of the raw buffer files [Default: $ONEYEAR]
% savedir       Directory you wish to save the figures
% maxmargin     Maximum time shift for time shift search [Default: 200]
% plt           Plot options: 
%                   true (default)  = print, 
%                   false           = not print
% plotfilter    Plot filter version options: 
%                   true            = plot,
%                   false (default) = not plot
%
% OUTPUT:
% dt_B          Beginning datetime of SAC data
% dt_E          Ending datetime of SAC data
% CCmax         Maximum cross correlation of raw signals
% CCfmax        Maximum cross correlation of filtered signals: returns NaN
%               if plotfilter is set to false
% t_shift       Best-fitted time shift for raw signals
% t_shiftf      Best-fitted time shift for filtered signals: returns NaN if
%               plotfilter is set to false
%
% SEE ALSO:
% READSAC, GETSECTIONS, READSECTION, 
%
% Last modified by Sirawich Pipatprathanporn, 05/25/2020

defval('oneyeardir', getenv('ONEYEAR'));
defval('savedir', getenv('EPS'));
defval('maxmargin', 200);
defval('plt', true);
defval('plotfilter',false);

% file name for figures
split_name = split(removepath(sacfile), '.');
filename = cell2mat(split_name(1));

% maximum margin from both end of SAC datetimes in seconds
maxmargin = seconds(maxmargin);

% reads data from SAC file
[x_sac, Hdr, ~, ~, tims] = readsac(sacfile);
dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
    Hdr.NZMSEC, 'TimeZone', 'UTC') + days(Hdr.NZJDAY);
dt_B = dt_ref + seconds(Hdr.B);
dt_E = dt_ref + seconds(Hdr.E);

fprintf("Reported section: %s -- %s\n", string(dt_B), string(dt_E));

% Assume the buffer's sampling rate to be twice of the SAC's sampling rate
fs = (Hdr.NPTS - 1) / (Hdr.E - Hdr.B);
fs_buffer = 2 * fs;

% finds raw file(s) containing dt_B and dt_E
[sections, intervals] = getsections(oneyeardir, dt_B - maxmargin, ...
    dt_E + maxmargin, fs_buffer);

% reads the section from raw file(s)
% Assuming there is only 1 secion
[x_raw, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
    intervals{1}{2}, fs_buffer);

% decimate the raw section to obtain sampling rate about 20 Hz
x_rawd20 = decimate(x_raw, 2);

% zero pads before and after the SAC section to get the same length as
% the raw section 
x_before = zeros(round(seconds(dt_B - dt_begin) * fs), 1);
x_after = zeros(length(x_rawd20) - length(x_before) - length(x_sac) , 1);
x_sac_plot = cat(1, x_before, x_sac, x_after);

% finds timeshift for raw SAC signal
[C, lag] = xcorr(detrend(x_rawd20,1), detrend(x_sac,1));
[Cmax, Imax] = max(C);
t_shift = ((Imax - length(x_rawd20)) / fs) - seconds(dt_B - dt_begin);
fprintf('shifted time [RAW]      = %f s\n', t_shift);

if plotfilter
    % decimates to obtain sampling rate about 20/d_factor Hz then detrend
    d_factor = 3;
    x_sacd10 = detrend(decimate(x_sac, d_factor), 1);
    x_rawd10 = detrend(decimate(x_rawd20, d_factor), 1);

    % applies Butterworth bandpass 0.05-0.10 Hz
    x_sacf = bandpass(x_sacd10, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');
    x_rawf = bandpass(x_rawd10, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');
    
    % finds timeshift for filtered SAC signal
    [Cf, lagf] = xcorr(detrend(x_rawf,1), detrend(x_sacf,1));
    [Cfmax, Ifmax] = max(Cf);
    t_shiftf = ((Ifmax - length(x_rawf)) / (fs / d_factor)) - seconds(dt_B - dt_begin);
    fprintf('shifted time [FILTERED] = %f s\n', t_shiftf);
else
    t_shiftf = NaN;
end

% exit if the time shift is maximum margin
if or(abs(t_shift) > seconds(maxmargin), abs(t_shiftf) > seconds(maxmargin))
    fprintf('Cannot match\n');
    CCmax = 0;
    CCfmax = 0;
    t_shift = 9999;
    t_shiftf = 9999;
    return
end

%% OLD CODE: Quicker but does not calculate CC vs. time shift
% % computes correlation coefficients between sliced raw buffer and raw SAC
% x_rawd20_slice = x_rawd20((1:length(x_sac)) + Imax - length(x_rawd20));
% CC = xcorr(detrend(x_rawd20_slice,1), detrend(x_sac,1), 'coeff');
% [CCmax, IImax] = max(CC);
% tt_shift = (IImax - length(x_rawd20_slice)) / fs;
% fprintf('shifted time [CC]       = %f s\n', tt_shift);
% lag = lag / fs - max_margin;
% CC = C;
% 
% % computes correlation coefficients between sliced fileted buffer and 
% % filtered SAC
% x_rawf_slice = x_rawf((1:length(x_sacf)) + Ifmax - length(x_rawf));
% CCf = xcorr(detrend(x_rawf_slice,1), detrend(x_sacf,1), 'coeff');
% [CCfmax, IIfmax] = max(CCf);
% tt_shiftf = (IIfmax - length(x_rawf_slice)) / (fs / d_factor);
% fprintf('shifted time [CCf]      = %f s\n', tt_shiftf);
% lagf = lagf / (fs/d_factor) - max_margin;
% CCf = Cf;

%% compute correlation coefficients between raw buffer and raw SAC at
% different windows
x_rawd20 = cat(1, x_rawd20, zeros(length(x_sac),1));
num_window = length(x_rawd20) - length(x_sac) + 1;
CC = zeros(1, num_window);
lag = seconds(dt_begin - dt_B):(1/fs):seconds(dt_end - dt_E);
% correct the length of lag
size_diff = length(CC) - length(lag);
if size_diff > 0
    lag_extension = (1:size_diff) / fs + lag(end);
    lag = [lag lag_extension];
elseif size_diff < 0
    lag = lag(1:length(CC));
end
for ii = 1:num_window
    x_raw_slice = x_rawd20((1:length(x_sac)) + ii - 1);
    CC(1,ii) = corr(detrend(x_raw_slice,1), detrend(x_sac,1));
end
% remove any data that lag is beyond +- maximum margin
CC(abs(lag) > seconds(maxmargin)) = 0;
% find best CC and timeshift
[CCmax, IImax] = max(CC);
t_shift = lag(IImax);

%% compute correlation coefficients between filtered buffer and filtered SAC
% at different windows
if plotfilter
    x_rawf = cat(1, x_rawf, zeros(length(x_sacf),1));
    num_window = length(x_rawf) - length(x_sacf) + 1;
    CCf = zeros(1, num_window);
    lagf = seconds(dt_begin - dt_B):(1/(fs/d_factor)):seconds(dt_end - dt_E);
    % correct the length of lagf
    size_diff = length(CCf) - length(lagf);
    if size_diff > 0
        lagf_extension = (1:size_diff) / (fs/d_factor) + lagf(end);
        lagf = [lagf lagf_extension];
    elseif size_diff < 0
        lagf = lagf(1:length(CCf));
    end
    for ii = 1:num_window
        x_raw_slice = x_rawf((1:length(x_sacf)) + ii - 1);
        CCf(1, ii) = corr(detrend(x_raw_slice,1), detrend(x_sacf,1));
    end
    % remove any data that lag is beyond +/- max_margin
    CCf(abs(lagf) > seconds(maxmargin)) = 0;
    % find best CC and time shift
    [CCfmax, IIfmax] = max(CCf);
    t_shiftf = lagf(IIfmax);
end
%% plots
if plt
    figure(6)
    clf
    set(gcf,'Units','inches','Position',[2 2 6.5 7.5]);
    % plot head title
    ax0 = subplot('Position',[0.05 0.94 0.9 0.02]);
    title(replace(removepath(sacfile), '_', '\_'));
    set(ax0, 'FontSize', 10, 'Color', 'none');
    ax0.XAxis.Visible = 'off';
    ax0.YAxis.Visible = 'off';

    % plot raw buffer
    ax1 = subplot('Position',[0.05 6/7 0.9 1/7-0.06]);
    ax1 = signalplot(x_raw, fs_buffer, dt_begin, ax1, ...
        sprintf('Buffer [Raw], fs = %6.3f Hz', fs_buffer), ...
        'left', 'blue');
    ax1.XLabel.String = 'Buffer Time';
    hold on
    vline(ax1, dt_B + seconds(t_shift), '--', 2, 'r');
    [~,y] = norm2trueposition(ax1, 0, 0.9);
    text(dt_B + seconds(t_shift + 10), y, 'Begin', 'Color', 'r');
    vline(ax1, dt_E + seconds(t_shift), '--', 2, 'r');
    text(dt_E + seconds(t_shift - 40), y, 'End', 'Color', 'r');
    hold off
    ax1.FontSize = 8;

    % plot raw event sac report
    ax2 = subplot('Position',[0.05 5/7 0.9 1/7-0.06]);
    ax2 = signalplot(x_sac_plot, fs, dt_begin, ax2, ...
        sprintf('Reported [raw], fs = %6.3f Hz', fs), ...
        'left', 'black');
    ax2.XLabel.String = 'Processed Time';
    hold on
    vline(ax2, dt_B, '--', 2, 'r');
    [~,y] = norm2trueposition(ax2, 0, 0.9);
    text(dt_B + seconds(10), y, 'Begin', 'Color', 'r');
    vline(ax2, dt_E, '--', 2, 'r');
    text(dt_E - seconds(45), y, 'End', 'Color', 'r');
    hold off
    ax2.FontSize = 8;

    % plot zoom-in sections of raw buffer from dt_B to dt_E
    if plotfilter
        ax3 = subplot('Position',[0.05 4/7 0.42 1/7-0.06]);
    else
        ax3 = subplot('Position',[0.05 4/7 0.9 1/7-0.06]);
    end
    ax3 = signalplot(x_raw, fs_buffer, dt_begin, ax3, ... 
        sprintf('Buffer [raw], fs = %6.3f Hz', fs_buffer), ...
        'left', 'blue');
    ax3.XLabel.String = 'Buffer Time';
    ax3.XLim = [dt_B dt_E];
    ax3.FontSize = 8;

    % plot zoom-in sections of raw sac report from dt_B to dt_E
    if plotfilter
        ax4 = subplot('Position',[0.05 3/7 0.42 1/7-0.06]);
    else
        ax4 = subplot('Position',[0.05 3/7 0.9 1/7-0.06]);
    end
    ax4 = signalplot(x_sac, fs, dt_B, ax4, ...
        sprintf('Reported [raw], fs = %6.3f Hz', fs), ...
        'left', 'black');
    ax4.XLabel.String = 'Processed Time';
    ax4.XLim = [dt_B dt_E];
    ax4.FontSize = 8;

    if plotfilter
        % plot zoom-in sections of filtered buffer
        ax5 = subplot('Position',[0.53 4/7 0.42 1/7-0.06]);
        ax5 = signalplot(x_rawf, fs/d_factor, dt_begin, ax5, ...
            sprintf('Buffer [dc%d, dt, bp 0.05-0.10 Hz], fs = %6.3f Hz', ...
            2 * d_factor, fs / d_factor), 'left', 'blue');
        ax5.XLabel.String = 'Buffer Time';
        ax5.XLim = [dt_B dt_E];
        ax5.FontSize = 8;

        % plot zoom-in sections of filtered sac report
        ax6 = subplot('Position',[0.53 3/7 0.42 1/7-0.06]);
        ax6 = signalplot(x_sacf, fs/d_factor, dt_B, ax6, ...
            sprintf('Reported [dc%d, dt, bp 0.05-0.10 Hz], fs = %6.3f Hz', ...
            d_factor, fs / d_factor), 'left', 'black');
        ax6.XLabel.String = 'Processed Time';
        ax6.XLim = [dt_B dt_E];
        ax6.FontSize = 8;
    end

    % plot raw cc
    if plotfilter
        ax7 = subplot('Position',[0.05 2/7 0.42 1/7-0.06]);
    else
        ax7 = subplot('Position',[0.05 2/7 0.9 1/7-0.06]);
    end
    scatter(lag, CC, '.k');
    hold on
    plot(t_shift, CCmax, 'Marker', '+', 'Color', 'r', 'MarkerSize', 8);
    hold off
    grid on
    title('Correlation Coefficient [raw]');
    xlabel('time shift [s]');
    ylabel('CC');
    if and(t_shift > -1, t_shift < 1)
        ax7.XLim = [-1 1];
    else
        ax7.XLim = [-1 1] + t_shift;
    end
    ax7.YLim = [-1 1];
    ax7.FontSize = 8;

    % plot filter cc
    if plotfilter
        ax8 = subplot('Position',[0.53 2/7 0.42 1/7-0.06]);
        scatter(lagf, CCf, '.k');
        hold on
        plot(t_shiftf, CCfmax, 'Marker', '+', 'Color', 'r', 'MarkerSize', 8);
        hold off
        grid on
        title('Correlation Coefficient [filtered]');
        xlabel('time shift [s]');
        ylabel('CC');
        if and(t_shiftf > -1, t_shiftf < 1)
            ax8.XLim = [-1 1];
        else
            ax8.XLim = [-1 1] + t_shiftf;
        end
        ax8.YLim = [-1 1];
        ax8.FontSize = 8;
    end

    % plot 2 signals on top of each other
    if plotfilter
        ax9 = subplot('Position',[0.05 1/7 0.42 1/7-0.06]);
    else
        ax9 = subplot('Position',[0.05 1/7 0.9 1/7-0.06]);
    end
    ax9 = signalplot(x_rawd20, fs, dt_begin-seconds(t_shift), ax9, '', ...
        'left', 'blue');
    hold on
    ax_title = sprintf('Shifted Buffer and Reported [raw]');
    ax9 = signalplot(x_sac, fs, dt_B, ax9, ax_title, 'left', 'black');
    hold off
    x_left = dt_B + (dt_E - dt_B) * 4/5;
    x_right = dt_B + (dt_E - dt_B) * 5/5;
    xlim([x_left x_right]);
    ax9.XLabel.String = 'Processed Time';
    legend('shifted buffer','reported','Location','northwest');
    ax9.FontSize = 8;

    % plot 2 filtered signals on top of each other
    if plotfilter
        ax10 = subplot('Position',[0.53 1/7 0.42 1/7-0.06]);
        ax10 = signalplot(x_rawf, fs/d_factor, ...
            dt_begin-seconds(t_shiftf), ax10, '', 'left', 'blue');
        hold on
        ax_title = sprintf('Shifted Buffer and Reported [filtered]');
        ax10 = signalplot(x_sacf, fs/d_factor, dt_B, ax10, ax_title, ...
            'left', 'black');
        hold off
        x_left = dt_B + (dt_E - dt_B) * 4/5;
        x_right = dt_B + (dt_E - dt_B) * 5/5;
        xlim([x_left x_right]);
        ax10.XLabel.String = 'Processed Time';
        legend('shifted buffer','reported','Location','northwest');
        ax10.FontSize = 8;
    end

    % report t_shift and Cmax on an empty axes
    if plotfilter
        ax11 = subplot('Position',[0.02 0 0.42 1/7-0.06]);
    else
        ax11 = subplot('Position',[0.02 0 0.9 1/7-0.06]);
    end
    ax11.Color = 'none';
    if plotfilter
        x_begin = 1/9;
    else
        x_begin = 1/3;
    end
    text(8/9*ax11.XLim(1)+x_begin*ax11.XLim(2),1/4*ax11.YLim(1)+3/4*ax11.YLim(2),...
        sprintf('Time shift  = %7.3f seconds',t_shift),'FontSize',12);
    text(8/9*ax11.XLim(1)+x_begin*ax11.XLim(2),3/4*ax11.YLim(1)+1/4*ax11.YLim(2),...
        sprintf('maximum cc = %5.3f',CCmax),'FontSize',12);
    ax11.XAxis.Visible = 'off';
    ax11.YAxis.Visible = 'off';

    % report t_shiftf and Cfmax on an empty axes
    if plotfilter
        ax12 = subplot('Position',[0.53 0 0.42 1/7-0.06]);
        ax12.Color = 'none';
        text(15/16*ax12.XLim(1)+1/16*ax12.XLim(2),1/4*ax12.YLim(1)+3/4*ax12.YLim(2),...
            sprintf('Time shift  = %7.3f seconds',t_shiftf),'FontSize',12);
        text(15/16*ax12.XLim(1)+1/16*ax12.XLim(2),3/4*ax12.YLim(1)+1/4*ax12.YLim(2),...
            sprintf('maximum cc = %5.3f',CCfmax),'FontSize',12);
        ax12.XAxis.Visible = 'off';
        ax12.YAxis.Visible = 'off';
    end

    % add panel labels
    norm_x = 0.05;
    norm_y = 0.85;
    axlabel = 97;     % ASCII code for 'a'
    
    axes(ax1)
    [x,y] = norm2trueposition(ax1,norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    axes(ax2)
    [x,y] = norm2trueposition(ax2,norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    axes(ax3)
    [x,y] = norm2trueposition(ax3,norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    axes(ax4)
    [x,y] = norm2trueposition(ax4,norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    if plotfilter
        axes(ax5)
        [x,y] = norm2trueposition(ax5,norm_x,norm_y);
        text(x,y,char(axlabel),'FontSize',12);
        axlabel = axlabel + 1;
        
        axes(ax6)
        [x,y] = norm2trueposition(ax6,norm_x,norm_y);
        text(x,y,char(axlabel),'FontSize',12);
        axlabel = axlabel + 1;
    end
    
    axes(ax7)
    [x,y] = norm2trueposition(ax7,norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    if plotfilter
        axes(ax8)
        [x,y] = norm2trueposition(ax8,norm_x,norm_y);
        text(x,y,char(axlabel),'FontSize',12);
        axlabel = axlabel + 1;
    end
    
    axes(ax9)
    [x,y] = norm2trueposition(ax9,1-norm_x,norm_y);
    text(x,y,char(axlabel),'FontSize',12);
    axlabel = axlabel + 1;
    
    if plotfilter
        axes(ax10)
        [x,y] = norm2trueposition(ax10,1-norm_x,norm_y);
        text(x,y,char(axlabel),'FontSize',12);
        axlabel = axlabel + 1;
    end
    
    %% save the figure
    figdisp(filename,[],[],2,[],'epstopdf');
end

if ~plotfilter
    CCfmax = NaN;
    t_shiftf = NaN;
end

end
