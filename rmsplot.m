function rmsplot(x,fs,dt_begin,win,longwin,method,savedir,plt,plt_trigs)
% RMSPLOT(x,fs,dt_begin,win,longwin,method,savedir,plt,plt_trigs)
% Plots moving rms of the signal. Then, identifies the peaks of moving rms
% and writes into a text file saved to 'savedir' directory.
% 
% INPUT
% x             signal
% fs            sampling rate
% dt_begin      beginning datetime
% win           window length for moving average (short-term)
% longwin       window length for peaks identification (long-term)
% method        a method of finding peaks [default: 'pickpeaks']
%               - 'pickpeaks'
%               - 'stalta'
% savedir       saving directiory for the output file
% plt           whether to plot or not
% plt_trigs     whether to plot triggers and detriggers
%
% OUTPUT
%
% SEE ALSO
% PICKPEAKS, STALTA
%
% Last modified by Sirawich Pipatprathanporn: 07/11/2021

dt_begin.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
% calculation of mov rms
t = dt_begin + seconds((0:length(x)-1) / fs);
zero_line = zeros(1,length(x));
x_mov_rms = movmean(x .^ 2, round(fs * win)) .^ 0.5;
x_mov_rms_long = movmean(x .^ 2, round(fs * win * 20)) .^ 0.5;
x_total_rms = rms(x);
x_rms_mean = mean(x_mov_rms);
base_line = ones(1,length(x)) * 1.5;

% add trigger times and detrigger times
lta = min((length(x)-1) / fs, longwin);
if strcmp(method, 'stalta')
    [trigt,~,~,ratio,~,~,~,~,~] = stalta(x, 1/fs, [0 ((length(x)-1) / fs)], ...
        10, lta, 1.5, 1.5, 60, 60, 5, 1);
    if isempty(trigt)
        trigs = [];
        dtrigs = [];
    elseif isnan(trigt)
        trigs = [];
        dtrigs = [];
    else
        [trigs,dtrigs] = simplifyintervals(trigt(:,1), trigt(:,2));
    end
else
    [trigs,dtrigs,ratio] = pickpeaks(x,fs,30,lta,1.5,1.5,60);
end
if ~isempty(trigs)
    trigs = dt_begin + seconds(trigs);
    dtrigs = dt_begin + seconds(dtrigs);
end
%% plot
if plt
    figure(1)
    set(gcf,'Unit','inches','Position',[2 2 6.5 3]);
    clf
    plot(t,x/x_total_rms,'Color',rgbcolor('k'));
    hold on
    plot(t,zero_line,'Color',rgbcolor('v'),'LineWidth',1.5);
    plot(t,base_line,'Color',rgbcolor('my blue'),'LineWidth',1.5);
    plot(t,x_mov_rms/x_total_rms,'Color',rgbcolor('r'),'LineWidth',1);
    plot(t,ratio,'Color',rgbcolor('green'),'LineWidth',1);
    % add trigger times and detrigger times
    if plt_trigs
        if ~isempty(trigs)
            vline(gca, trigs, 'LineStyle', '--', 'LineWidth', 0.75, ...
                'Color', [0.9 0.5 0.2]);
        end
        if ~isempty(dtrigs)
            vline(gca, dtrigs, 'LineStyle', '--', 'LineWidth', 0.75, ...
                'Color', [0.2 0.5 0.9]);
        end
    end
    hold off
    grid on
    xlim([t(1) t(end)]);
    ylim([-1 1] * 10);
    xlabel('time')
    % label
    if strcmp(method,'stalta')
        tag = 'sta-lta ratio';
        ylabel(sprintf('x / rms( x ), green: %s', tag))
    else
        tag = 'adjusted moving rms';
        ylabel('x / rms( x )')
    end
    title(sprintf('bp 2-10, Moving rms: window = %.2f s (red), %s (green)', win, tag))
    set(gca,'Position',[0.10 0.16 0.88 0.76],'TickDir','both');
    %% save figure
    savefile = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
end
%% record trigger and detrigger datetimes
if ~isempty(savedir)
    filename = strcat(savedir, mfilename, '_', ...
        replace(string(dt_begin),':','_'), '.txt');
    fid = fopen(filename,'w');
    for ii = 1:length(trigs)
        fprintf(fid, '%s\t%s\n', string(trigs(ii)), string(dtrigs(ii)));
    end
    fclose(fid);
end
end