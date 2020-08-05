function compare_p2l_mermaid(option)
% COMPARE_P2L_MERMAID(option)
% compares spectral density of WAVEWATCH surface equivalent pressure and 
% spectral density of 1500-m depth pressure recorded by MERMAID.
%
% INPUT
% option        1 - weekly
%               2 - monthly
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 08/05/2020

% WAVEWATCH spectral density files
% MERMAID spectral density files
if option == 1
    WWdir = '/Users/sirawich/research/processed_data/weekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

% titles of specdensplot
if option == 1
    dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
        'uuuu_MM_dd');
    dt_week = dt_0 + calweeks(0:48);
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
    
    % create figure
    figure(1);
    clf;
    set(gcf, 'Unit', 'inches', 'Position', [2 2 6.5 6.5]);
    % plot
    ax = subplot('Position',[0.1 0.09 0.85 0.8]);
    p1 = semilogx(f * f_scale, sd + y_shift, '^-k', 'MarkerFaceColor', 'k');
    hold on
    p2 = semilogx(f * f_scale, sdU + y_shift, '^-', 'Color', ...
        rgbcolor('silver'), 'MarkerFaceColor', rgbcolor('silver'));
    p3 = semilogx(f * f_scale, sdL + y_shift, '^-', 'Color', ...
        rgbcolor('silver'), 'MarkerFaceColor', rgbcolor('silver'));
    p4 = semilogx(m_f, m_sd, '.-r');
    p5 = semilogx(m_f, m_sdU, '.-', 'Color', rgbcolor('gray'));
    p6 = semilogx(m_f, m_sdL, '.-', 'Color', rgbcolor('gray'));
    hold off
    grid on
    xlim([0.01 2]);
    xlabel('frequency (Hz)');
    ylabel('10 log_{10} spectral density');
    ylim([-20 140]);
    legend([p1 p4], {'WAVEWATCH', 'MERMAID'}, 'Location', 'southeast')
    ax.TickDir = 'both';
    
    ax2 = doubleaxes(ax);
    inverseaxis(ax2.XAxis, 'period (s)');
    
    title(ax2,sprintf('%s (f-scale = %.3f, SD-shift = %.3f)', titles{ii}, ...
        f_scale, y_shift));
    
    % save figure
    figdisp(strcat(mfilename,'_',save_titles{ii},'.eps'),...
        [],[],2,[],'epstopdf');
end

fprintf('SD-shift = %.4f\n', mean(y_shifts));
fprintf('f-scale  = %.4f\n', mean(f_scales));
end