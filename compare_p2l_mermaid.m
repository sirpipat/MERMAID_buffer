function compare_p2l_mermaid(option)
% COMPARE_P2L_MERMAID(option)
% compares spectral density of WAVEWATCH surface equivalent pressure and 
% spectral density of 1500-m depth pressure recorded by MERMAID.
%
% INPUT
% option        'weekly'
%               'biweekly'
%               'monthly'
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 06/20/2021

% WAVEWATCH spectral density files
% MERMAID spectral density files
if strcmp(option, 'weekly')
    WWdir = '/Users/sirawich/research/processed_data/weekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';
    % WWdir = '/Users/sirawich/research/processed_data/weekly_WWSD_profiles_before_conversion/';
    % SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles_before_conversion/';
elseif strcmp(option, 'biweekly')
    WWdir = '/Users/sirawich/research/processed_data/biweekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/biweekly_SD_profiles/';
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

% titles of specdensplot
if strcmp(option, 'weekly')
    dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
        'uuuu_MM_dd');
    dt_week = dt_0 + calweeks(0:48);
    save_titles = string(dt_week);
    titles = replace(save_titles, '_', '-');
elseif strcmp(option, 'biweekly')
    dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
        'uuuu_MM_dd');
    dt_week = dt_0 + calweeks(0:2:48);
    save_titles = string(dt_week);
    titles = replace(save_titles, '_', '-');
else
    titles = {'September 2018', 'October 2018', 'November 2018', ...
              'December 2018', 'January 2019', 'February 2019', ...
              'March 2019', 'April 2019', 'May 2019', ...
              'June 2019', 'July 2019', 'August 2019'};

    save_titles = {'2018_09', '2018_10', '2018_11', '2018_12', '2019_01', ...
                   '2019_02', '2019_03', '2019_04', '2019_05', '2019_06', ...
                   '2019_07', '2019_08'};
end

y_shifts = zeros(1,pndex);
f_scales = zeros(1,pndex);
for ii = 1:pndex
    % read monthly WAVEWATCH spectral density
    fid = fopen(allp2ls{ii},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    sdU = data(4,:);
    sdL = data(5,:);
    
    % read monthly MERMAID spectral density
    fid = fopen(allSDs{ii},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    m_f = data(1,:);
    m_sd = data(2,:);
    m_sdU = data(4,:);
    m_sdL = data(5,:);
    
    % find best SD shift
    y_shift = max(m_sd,[],'all') - max(sd,[],'all');
    % find best frequency ratio
    h = 40;
    fp = f(max(sd) - sd <= h);
    sdp = sd(max(sd) - sd <= h) - (max(sd) - h);
    f_highest = sum(fp .* sdp) / sum(sdp);
    m_fp = m_f(and(and(m_f > 0.06, m_f <= 0.5), max(m_sd) - m_sd <= h));
    m_sdp = m_sd(and(and(m_f > 0.06, m_f <= 0.5), max(m_sd) - m_sd <= h)) - (max(m_sd) - h);
    m_f_highest = sum(m_fp .* m_sdp) / sum(m_sdp);
    f_scale = m_f_highest / f_highest;
    
    y_shifts(1,ii) = y_shift;
    f_scales(1,ii) = f_scale;
    
    y_shift = 0;
    f_scale = 1;
    
    % read MERMAID gain curve
    [f_curve, gain] = mermaidcurve;
    
    m_sd_interp = interp1(m_f, m_sd, 2 * f);
    
    % adjust MERMAID response
    where = (f < 0.2);
    m_sd_interp(where) = m_sd_interp(where) + (30 - ...
        interp1(f_curve/2, gain, f(where)));
    offset = m_sd_interp - sd;
    
    % create figure
    figure(5);
    clf;
    set(gcf, 'Unit', 'inches', 'Position', [2 2 8.5 4]);
    
    % plot SD
    ax1 = subplot('Position', [0.1 0.16 0.35 0.64]);
    p2 = semilogx(f * f_scale, sdU + y_shift, '.-', ...'MarkerSize', 3, ...
        'Color', rgbcolor('silver'), 'MarkerFaceColor', rgbcolor('silver'));
    hold on
    p3 = semilogx(f * f_scale, sdL + y_shift, '.-', ...'MarkerSize', 3, ...
        'Color', rgbcolor('silver'), 'MarkerFaceColor', rgbcolor('silver'));
    p1 = semilogx(f * f_scale, sd + y_shift, '^-k', 'MarkerSize', 5, ...
        'MarkerFaceColor', 'k');
    p4 = semilogx(m_f, m_sd, '.-r');
    p5 = semilogx(m_f, m_sdU, '.-', 'Color', rgbcolor('gray'));
    p6 = semilogx(m_f, m_sdL, '.-', 'Color', rgbcolor('gray'));
    % plot f_MH = 2 f_WW
    where = and(m_f >= 2*f(1), m_f <= 2*f(end));
    p7 = semilogx(m_f(where), m_sd(where), 'v-r', 'MarkerSize', 5, ...
        'MarkerFaceColor', 'r');
    p8 = semilogx(m_f(where), m_sdU(where), '.-', 'MarkerSize', 3, ...
        'Color', rgbcolor('gray'), 'MarkerFaceColor', rgbcolor('gray'));
    p9 = semilogx(m_f(where), m_sdL(where), '.-', 'MarkerSize', 3, ...
        'Color', rgbcolor('gray'), 'MarkerFaceColor', rgbcolor('gray'));
    hold off
    grid on
    xlim([0.0099 2.0001]);
    ylim([-60 120]);
    ax1.XTick = sort([0.01 0.02 0.04 0.1 0.2 0.4 1 2]);
    ax1.XTickLabel = string(round(ax1.XTick, 2));
    xlabel('frequency (Hz)');
    ylabel('10 log_{10} spectral density');
    
    % add limit marker
    vline(ax1, [f(1) f(end)], '-', 1, [1 0.5 1]);
    vline(ax1, 2 * [f(1) f(end)], '-', 1, [0.2 0.8 0.4]);
    %vline(ax1, 0.4, '--', 1, [1 0.5 0]);
    hold on
    %plot([f(end) ax1.XLim(2)], sd(end) * [1 1], '--', 'LineWidth', 1, ...
    %    'Color', [1 0.5 1]);
    %plot([m_f(61) ax1.XLim(2)], m_sd(61) * [1 1], '--', 'LineWidth', 1, ...
    %    'Color', [0.2 0.8 0.4]);
    legend([p1 p7], {'WAVEWATCH', 'MERMAID'}, 'Location', 'southeast')
    ax1.TickDir = 'both';
    
    ax1s = doubleaxes(ax1);
    inverseaxis(ax1s.XAxis, 'period (s)');
    
    title(ax1s,sprintf('%s (%s)\nspectral density', titles{ii}, option));
    axeslabel(ax1, 0.1, 0.9, 'a', 'FontSize', 12);
        
    % sends the vertical lines to the back
    ax1.Children = ax1.Children([1 6 7 8 9 10 11 12 13 14 2 3 4 5]);
    
    % plot offset
    ax2 = subplot('Position', [0.6 0.16 0.35 0.64]); 
    semilogx(2 * f, offset, '^-k', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    xlim([0.0099 2.0001]);
    ylim([50 110]);
    ax2.XTick = sort([0.01 0.1 0.2 1 2 f(1) f(end)]);
    ax2.XTickLabel = string(round(ax2.XTick, 2));
    hold on
    hold off
    grid on
    xlabel('MERMAID frequency (Hz)');
    ylabel('10 log_{10} spectral density');
    ax2.TickDir = 'both';
    ax2.YLim = [-110 -20];
    ax2s = doubleaxes(ax2);
    inverseaxis(ax2s.XAxis, 'MERMAID period (s)');
    
    title(ax2s,sprintf('(f-scale = %.3f, SD-shift = %.3f)\nspectral density offset', ...
        f_scale, y_shift));
    axeslabel(ax2, 0.1, 0.9, 'b', 'FontSize', 12);
    
    % save figure
    figdisp(strcat(mfilename,'_',save_titles{ii},'_',option,'.eps'),...
        [],[],2,[],'epstopdf');
end

fprintf('SD-shift = %.4f\n', mean(y_shifts));
fprintf('f-scale  = %.4f\n', mean(f_scales));
end