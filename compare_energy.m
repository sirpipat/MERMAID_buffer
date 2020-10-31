function compare_energy(option, f_WW, f_MM, Escale)
% COMPARE_ENERGY(option, f_WW, f_MM, Escale)
% compares energy of WAVEWATCH surface equivalent pressure and 
% spectral density of 1500-m depth pressure recorded by MERMAID.
% E(a <= f <= b) = \int_a^b s(f) df where s(f) is spectral density.
%
% INPUT
% option        1 - weekly
%               2 - biweekly (every 2 weeks)
%               3 - monthly
% f_WW          WAVEWATCH frequency band
% f_MM          MERMAID frequency band
% Escale       scale of energy axes ['raw' (default) or 'scaled']
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 10/27/2020

defval('Escale', 'raw')

%% get all filenames
% WAVEWATCH spectral density files
% MERMAID spectral density files
if option == 1
    WWdir = '/Users/sirawich/research/processed_data/weekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';
    SD_shift = 56.5765;
    f_scale = 2.2583;
    t = datetime(2018,9,13,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calweeks(0:48);
    titlename = 'Energy level (weekly scale)';
    savetitle = strcat(mfilename, '_weekly');
elseif option == 2
    WWdir = '/Users/sirawich/research/processed_data/biweekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/biweekly_SD_profiles/';
    SD_shift = 56.8158;
    f_scale = 2.2503;
    t = datetime(2018,9,13,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calweeks(0:2:46);
    titlename = 'Energy level (biweekly scale)';
    savetitle = strcat(mfilename, '_biweekly');    
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
    SD_shift = 56.6312;
    f_scale = 2.446;
    t = datetime(2018,9,1,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calmonths(0:11);
    titlename = 'Energy level (monthly scale)';
    savetitle = strcat(mfilename, '_monthly');
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

%% compute energies
% energy from f(1) - f(end)
E = zeros(pndex, 1);
m_E = zeros(pndex, 1);

for idt = 1:pndex
    % read WAVEWATCH spectral density
    fid = fopen(allp2ls{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    E(idt, 1) = boundtrapz(f, 10 .^ (sd/10), f_WW(1), f_WW(end));
    
    % read MERMAID spectral density
    fid = fopen(allSDs{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    m_f = data(1,:);
    m_sd = data(2,:);
    m_E(idt, 1) = boundtrapz(m_f, 10 .^ (m_sd/10), f_MM(1), f_MM(end));
end

%% plot overall energy level

E = 10 * log10(E); %+ SD_shift;
m_E = 10 * log10(m_E);

% scaled option
if strcmp(Escale, 'scaled')
    E = (E - mean(E)) / std(E);
    m_E = (m_E - mean(m_E)) / std(m_E);
end

% plot results
figure;
set(gcf, 'Unit', 'inches', 'Position', [18 8 4 3.5]);
ah = subplot(2,1,1);
plot(t,E,'LineWidth',1.5);
hold on
plot(t,m_E,'LineWidth',1.5);
hold off
grid on
xlim([t(1) t(end)])
if strcmp(Escale, 'raw')
    ylabel(sprintf('%g log_{10} (Energy)', 10))
else
    ylabel(sprintf('z-score of %g log_{10} (Energy)', 10))
end
titlename = sprintf('%s, cc = %5.3f', titlename, corr(E,m_E));
title(titlename)
label_WW = sprintf('WAVEWATCH (%5.3f - %5.3f Hz)', f_WW(1), f_WW(end));
label_MM = sprintf('MERMAID        (%5.3f - %5.3f Hz)', f_MM(1), f_MM(end));
legend(label_WW,label_MM,'Location','best')
set(gca, 'FontSize', 10, 'TickDir', 'both');
ax = gca;
ax.Title.Position(2) = ax.Title.Position(2) + 0.2;

savetitle = sprintf('%s_f_WW_%5.3f_%5.3f_f_MM_%5.3f_%5.3f.eps', ...
    savetitle, f_WW(1), f_WW(end), f_MM(1), f_MM(end));
figdisp(savetitle, [], [], 2, [], 'epstopdf');
end