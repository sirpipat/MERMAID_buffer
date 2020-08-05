function compare_yearly_p2l_mermaid()
% COMPARE_YEARLY_SD_P2L_MERMAID()
% compares spectral density of WAVEWATCH surface equivalent pressure and 
% spectral density of 1500-m depth pressure recorded by MERMAID.
%
% INPUT
% no input
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 08/04/2020

% WAVEWATCH spectral density files
WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
[allp2ls, pndex] = allfile(WWdir);

% MERMAID spectral density files
SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
[allSDs, ~] = allfile(SDdir);

% titles of specdensplot
titles = {'September 2018', 'October 2018', 'November 2018', ...
          'December 2018', 'January 2019', 'February 2019', ...
          'March 2019', 'April 2019', 'May 2019', ...
          'June 2019', 'July 2019', 'August 2019'};
      
save_titles = {'2018_09', '2018_10', '2018_11', '2018_12', '2019_01', ...
               '2019_02', '2019_03', '2019_04', '2019_05', '2019_06', ...
               '2019_07', '2019_08'};
           
% create figure
figure(1);
clf;
set(gcf, 'Unit', 'inches', 'Position', [2 2 15 13]);
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
    
    % grid coordinates for panels (1,1) = bottom left, (4,3) = top right
    yy = 3 - ceil(ii/4);
    xx = ii - 4 * ceil(ii/4) + 3;
    ax = subplot('Position',[xx/4+0.04 yy/3+0.05 1/4-0.07 1/3-0.1]);
    % plot
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
    ylim([20 140]);
    legend([p1 p4], {'WAVEWATCH', 'MERMAID'}, 'Location', 'southeast')
    ax.TickDir = 'both';
    
    ax2 = doubleaxes(ax);
    inverseaxis(ax2.XAxis, 'period (s)');
    
    title(ax2,sprintf('%s (f-scale = %.3f, SD-shift = %.3f)', titles{ii}, ...
        f_scale, y_shift));
    
%     % save figure
%     figdisp(strcat(mfilename,'_',save_titles{ii},'.eps'),...
%         [],[],2,[],'epstopdf');
end

% save figure
figdisp(strcat(mfilename,'_one_year.eps'),[],[],2,[],'epstopdf');
end