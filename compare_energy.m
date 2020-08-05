function compare_energy(option)
% COMPARE_ENERGY(option)
% compares energy of WAVEWATCH surface equivalent pressure and 
% spectral density of 1500-m depth pressure recorded by MERMAID.
% E(a <= f <= b) = \int_a^b s(f) df where s(f) is spectral density.
%
% INPUT
% option        1 - weekly
%               2 - monthly
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 08/05/2020

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
    title = 'Energy correlation coefficient (weekly scale, bin = 0.01 x 0.01 Hz)';
    savetitle = strcat(mfilename, '_weekly_cc.eps');
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
    SD_shift = 56.6312;
    f_scale = 2.446;
    t = datetime(2018,9,1,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calmonths(0:11);
    title = 'Energy correlation coefficient (monthly scale, bin = 0.01 x 0.01 Hz)';
    savetitle = strcat(mfilename, '_monthly_cc.eps');
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

%% compute energies
% energy from f(1) - f(end)
E = zeros(pndex, 1);
m_E = zeros(pndex, 1);

% energies in different frequency bands
binwidth = 0.001;
f_limit = 0.041:binwidth:0.304;
m_f_limit = 0.040:binwidth:1.000;
Ebands = zeros(pndex, size(f_limit,2)-1);       % E = E(idt, ifreq)
m_Ebands = zeros(pndex, size(m_f_limit,2)-1);     % m_E = m_E(idt, ifreq)
for idt = 1:pndex
    % read WAVEWATCH spectral density
    fid = fopen(allp2ls{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    E(idt, 1) = boundtrapz(f, 10 .^ (sd/10), f(1), f(end));
    
    % limit of frequency bands
    for ifreq = 1:size(f_limit,2)-1
        Ebands(idt,ifreq) = boundtrapz(f, 10 .^ (sd/10), ...
            f_limit(ifreq), f_limit(ifreq+1));
    end
    
    % read MERMAID spectral density
    fid = fopen(allSDs{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    
    m_f = data(1,:);
    m_sd = data(2,:);
    m_E(idt, 1) = boundtrapz(m_f, 10 .^ (m_sd/10), f_scale * f(1), f_scale * f(end));
    
    % limit of frequency bands
    for ifreq = 1:size(m_f_limit,2)-1
        m_Ebands(idt,ifreq) = boundtrapz(m_f, 10 .^ (m_sd/10), ...
            m_f_limit(ifreq), m_f_limit(ifreq+1));
    end
end

%% plot overall energy level

% [~,iE] = min(abs(f_limit-0.2));
% [~,imE] = min(abs(m_f_limit-0.3));
% E = Ebands(:,iE);
% m_E = m_Ebands(:,imE);

E = 10 * log10(E) + SD_shift;
m_E = 10 * log10(m_E);

% plot results
figure;
plot(t,E,'LineWidth',1);
hold on
plot(t,m_E,'LineWidth',1);
hold off
grid on
ylabel(sprintf('%g log_{10} (Energy)', 10))
legend('WAVEWATCH','MERMAID','Location','best')

%% compute correlations between WAVEWATCH energy bands and MERMAID energy bands
Ebands = detrend(Ebands, 0);
m_Ebands = detrend(m_Ebands, 0);

cc = corr(m_Ebands,Ebands);

% plot
f_WW = 0.5 * (f_limit(1:end-1) + f_limit(2:end));
f_MM = 0.5 * (m_f_limit(1:end-1) + m_f_limit(2:end));
figure;
clf;
set(gcf, 'Unit', 'inches', 'Position', [18 10 6.5 6.5]);
ax = subplot('Position', [0.08 0.08 0.8 0.8]);
imagesc(f_WW, f_MM, cc);
axis xy
c = colorbar('SouthOutside');
c.Label.String = 'correlation coefficient';
c.Label.FontSize = 11;

xlim([f_WW(1) f_WW(end)])
ylim([f_MM(1) f_MM(end)])

xlabel('WAVEWATCH frequency (Hz)')
ylabel('MERMAID frequency (Hz)')

ax.TickDir = 'both';
grid on

% add f(MERMAID) = 2 * f(WAVEWATCH) line
hold on
plot([0.05 0.3], [0.1 0.6], '--r', 'LineWidth', 2);
hold off

% add period axes
ax2 = doubleaxes(ax);
inverseaxis(ax2.YAxis, 'MERMAID period (s)');
inverseaxis(ax2.XAxis, 'WAVEWATCH period (s)');

% add title
ax2.Title.String = title;

% save figure
figdisp(savetitle, [], [], 2, [], 'epstopdf');
end