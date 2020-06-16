function rmsplot(x,fs,dt_begin,win,savedir,plt)
% RMSPLOT(x,fs,dt_begin,win,savedir,plt)
% Plots moving rms of the signal. Then, identifies the peaks of moving rms
% and writes into a text file saved to 'savedir' directory.
% 
% INPUT
% x             signal
% fs            sampling rate
% dt_begin      beginning datetime
% win           window length for moving average
% savedir       saving directiory for the output file
% plt           whether to plot or not
%
% OUTPUT
%
% Last modified by Sirawich Pipatprathanporn: 06/16/2020

dt_begin.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
% calculation of mov rms
t = dt_begin + seconds((0:length(x)-1) / fs);
zero_line = zeros(1,length(x));
x_mov_rms = movmean(x .^ 2, round(fs * win)) .^ 0.5;
x_mov_rms_long = movmean(x .^ 2, round(fs * win * 20)) .^ 0.5;
x_total_rms = rms(x);
x_rms_mean = mean(x_mov_rms);
one_line = ones(1,length(x));

% add trigger times and detrigger times
[trigs,dtrigs] = pickpeaks(x_mov_rms/x_rms_mean,fs,1.5,1.5,60);
trigs = dt_begin + seconds(trigs);
dtrigs = dt_begin + seconds(dtrigs);
%% plot
if plt
    figure(1)
    set(gcf,'Unit','inches','Position',[2 2 6.5 3]);
    clf
    plot(t,x/x_rms_mean,'Color',rgbcolor('k'));
    hold on
    plot(t,zero_line,'Color',rgbcolor('v'),'LineWidth',1.5);
    %plot(t,ones(1,length(x))*x_total_rms/x_rms_mean,'m','LineWidth',1.5');
    plot(t,x_mov_rms/x_rms_mean,'Color',rgbcolor('r'),'LineWidth',1);
    plot(t,x_mov_rms_long/x_rms_mean,'Color',rgbcolor('g'),'LineWidth',1);
    plot(t,one_line,'Color',rgbcolor('my blue'),'LineWidth',1.5);
    % add trigger times and detrigger times
    for ii = 1:length(trigs)
        vline(gca, trigs(ii), '--', 1, [0.9 0.5 0.2]);
        vline(gca, dtrigs(ii), '--', 1, [0.2 0.5 0.9]);
    end
    hold off
    grid on
    xlim([t(1) t(end)]);
    ylim([-1 1] * 10);
    xlabel('time')
    ylabel('x / mean(x_{mov rms})')
    title(sprintf('Moving rms: window = %.2f, %.2f s', win, win*20))
    set(gca,'Position',[0.08 0.16 0.9 0.76]);
    %% save figure
    savefile = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
end
%% record trigger and detrigger datetimes
filename = strcat(savedir, mfilename, '_', ...
    replace(string(dt_begin),':','_'), '.txt');
fid = fopen(filename,'w');
for ii = 1:length(trigs)
    fprintf(fid, '%s\t%s\n', string(trigs(ii)), string(dtrigs(ii)));
end
fclose(fid);
end