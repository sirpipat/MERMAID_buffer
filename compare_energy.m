function [t, E_WW, E_MM] = compare_energy(option, f_WW, f_MM, Escale, plt)
% [t, E_WW, E_MM] = COMPARE_ENERGY(option, f_WW, f_MM, Escale, plt)
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
% Escale        scale of energy axes ['raw' (default) or 'scaled']
% plt           whether to plot or not [true (default) or false]
%
% OUTPUT
% t             time
% E_WW          WAVEWATCH energy (10 log (Energy))
% E_MM          MERMAID energy   (10 log (Energy))
% 
% Last modified by Sirawich Pipatprathanporn: 11/02/2020

defval('Escale', 'raw')
defval('plt', true)

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
E_WW = zeros(pndex, 1);
E_MM = zeros(pndex, 1);

for idt = 1:pndex
    % read WAVEWATCH spectral density
    fid = fopen(allp2ls{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    E_WW(idt, 1) = boundtrapz(f, 10 .^ (sd/10), f_WW(1), f_WW(end));
    
    % read MERMAID spectral density
    fid = fopen(allSDs{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    m_f = data(1,:);
    m_sd = data(2,:);
    E_MM(idt, 1) = boundtrapz(m_f, 10 .^ (m_sd/10), f_MM(1), f_MM(end));
end

% change energy to log-scale (dB)
E_WW = 10 * log10(E_WW); %+ SD_shift;
E_MM = 10 * log10(E_MM);

% scaled option
if strcmp(Escale, 'scaled')
    E_WW = (E_WW - mean(E_WW)) / std(E_WW);
    E_MM = (E_MM - mean(E_MM)) / std(E_MM);
end

% energy offset
offset = E_MM - E_WW;
mean_offset = mean(offset);

if ~plt
    return
end

%% plot overall energy level
figure;
set(gcf, 'Unit', 'inches', 'Position', [18 8 4 3.5]);
ah = subplot(2,1,1);
plot(t,E_WW,'LineWidth',1.5);
hold on
plot(t,E_MM,'LineWidth',1.5);
hold off
grid on
xlim([t(1) t(end)])
if strcmp(Escale, 'raw')
    ylabel(sprintf('%g log_{10} (Energy)', 10))
else
    ylabel(sprintf('z-score of %g log_{10} (Energy)', 10))
end
titlename = sprintf('%s, cc = %5.3f', titlename, corr(E_WW,E_MM));
title(titlename)
label_WW = sprintf('WAVEWATCH (%5.3f - %5.3f Hz)', f_WW(1), f_WW(end));
label_MM = sprintf('MERMAID        (%5.3f - %5.3f Hz)', f_MM(1), f_MM(end));
legend(label_WW,label_MM,'Location','east')
set(gca, 'FontSize', 10, 'TickDir', 'both');
ah.Title.Position(2) = ah.Title.Position(2) + 0.2;

%% plot energy offset

ag = subplot(2,1,2);
plot(t,offset,'LineWidth',1.5)
grid on
xlim([t(1) t(end)]);
ylabel('10 log_{10}(E_{MM}/E_{WW})');
title(sprintf('Mean offset = %7.4f',mean_offset));
set(gca, 'FontSize', 10, 'TickDir', 'both');

savetitle = sprintf('%s_f_WW_%5.3f_%5.3f_f_MM_%5.3f_%5.3f.eps', ...
    savetitle, f_WW(1), f_WW(end), f_MM(1), f_MM(end));
figdisp(savetitle, [], [], 2, [], 'epstopdf');
end