function hoursection_rmsplot(filename,fs,win,longwin,method,savedir,plt,plt_trigs)
% HOURSECTION_RMSPLOT(filename,fs,win,longwin,method,savedir,plt,plt_trigs)
%
% INPUT
% filename      The name of raw MERMAID data file
% fs            Sampling frequency [Default: 40.01406]
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
% Last modified by Sirawich Pipatprathanporn: 10/02/2020

% default parameter list
defval('fs', 40.01406);

fprintf("hoursection_rmsplot('%s')\n", filename);

% read file
[y, dt_start, dt_end] = readOneYearData(filename, fs);

fprintf('size = %d, interval = %d, fs = %f\n', length(y), length(y)/fs, fs);

% filter the signal
x = bandpass(y, fs, 2, 10, 2, 2, 'butter', 'linear');

%% calculation of mov rms
dt_start.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
t = dt_start + seconds((0:length(x)-1) / fs);
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
        % trigs = trigt(:,1);
        % dtrigs = trigt(:,2);
        [trigs,dtrigs] = simplifyintervals(trigt(:,1), trigt(:,2));
    end
else
    [trigs,dtrigs,ratio] = pickpeaks(x,fs,30,lta,1.5,1.5,60);
end
if ~isempty(trigs)
    trigs = dt_start + seconds(trigs);
    dtrigs = dt_start + seconds(dtrigs);
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
            vline(gca, trigs, '--', 0.75, [0.9 0.5 0.2]);
        end
        if ~isempty(dtrigs)
            vline(gca, dtrigs, '--', 0.75, [0.2 0.5 0.9]);
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
    
    %% slice to hourplots
    % keep track of the current time
    dt_curr = dt_start;
    xlim([dt_curr min(dt_curr+hours(1), dt_end)]);
    % save figure
    savefile = strcat(mfilename, '_', replace(string(dt_curr), ':', '_'), '.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
    
    dt_curr = dt_curr + minutes(30);
    
    while dt_end - dt_curr > minutes(30)
        %pause(0.8);
        xlim([dt_curr min(dt_curr+hours(1), dt_end)]);
        % save figure
        savefile = strcat(mfilename, '_', replace(string(dt_curr), ':', '_'), '.eps');
        figdisp(savefile, [], [], 2, [], 'epstopdf');
        dt_curr = dt_curr + minutes(30);
    end
end
%% record trigger and detrigger datetimes
if ~isempty(savedir)
    filename = strcat(savedir, mfilename, '_', ...
        replace(string(dt_start),':','_'), '.txt');
    fid = fopen(filename,'w');
    for ii = 1:length(trigs)
        fprintf(fid, '%s\t%s\n', string(trigs(ii)), string(dtrigs(ii)));
    end
    fclose(fid);
end

end