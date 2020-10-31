function energy_cc(option, Fscale)
% ENERGY_CC(option, Fscale)
% Computes the correlation coefficients of energy of WAVEWATCH surface 
% equivalent pressure and spectral density of 1500-m depth pressure 
% recorded by MERMAID.
% E(a <= f <= b) = \int_a^b s(f) df where s(f) is spectral density.
%
% INPUT
% option        1 - weekly
%               2 - biweekly (every 2 weeks)
%               3 - monthly
% Fscale        scale of frequency axes ['linear' or 'log' (default)]
%
% OUTOUT
% no output beside figures saved at $EPS
% 
% Last modified by Sirawich Pipatprathanporn: 10/27/2020

defval('Fscale', 'log')

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
    title = 'Energy correlation coefficient (weekly scale)';
    savetitle = strcat(mfilename, '_weekly_cc.eps');
elseif option == 2
    WWdir = '/Users/sirawich/research/processed_data/biweekly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/biweekly_SD_profiles/';
    SD_shift = 56.8158;
    f_scale = 2.2503;
    t = datetime(2018,9,13,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calweeks(0:2:46);
    title = 'Energy correlation coefficient (biweekly scale)';
    savetitle = strcat(mfilename, '_biweekly_cc.eps');    
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
    SD_shift = 56.6312;
    f_scale = 2.446;
    t = datetime(2018,9,1,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calmonths(0:11);
    title = 'Energy correlation coefficient (monthly scale)';
    savetitle = strcat(mfilename, '_monthly_cc.eps');
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

%% compute energies

% energies in different frequency bands
if strcmp(Fscale, 'linear')
    % linear scale
    binwidth = 0.001;
    f_limit = 0.041:binwidth:0.304;
    m_f_limit = 0.040:binwidth:1.000;
else
    % log scale
    binscale = 1.01;
    f_limit = logspace(log10(0.041),log10(0.304),...
                       round(log(0.304/0.040)/log(binscale)));
    m_f_limit = logspace(log10(0.040),log10(1.000),...
                         round(log(1.000/0.040)/log(binscale)));
end
Ebands = zeros(pndex, size(f_limit,2)-1);       % E = E(idt, ifreq)
m_Ebands = zeros(pndex, size(m_f_limit,2)-1);     % m_E = m_E(idt, ifreq)
for idt = 1:pndex
    % read WAVEWATCH spectral density
    fid = fopen(allp2ls{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    
    % limit of frequency bands
    for ifreq = 1:size(f_limit,2)-1
        Ebands(idt,ifreq) = boundtrapz(f, 10 .^ (sd/10), ...
            f_limit(ifreq), f_limit(ifreq+1));
    end
    % fix NaN value at the boundary
    Ebands(:,1) = Ebands(:,2);
    Ebands(:,end) = Ebands(:,end-1);
    
    % read MERMAID spectral density
    fid = fopen(allSDs{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    m_f = data(1,:);
    m_sd = data(2,:);
    
    % energy of frequency bands
    for ifreq = 1:size(m_f_limit,2)-1
        m_Ebands(idt,ifreq) = boundtrapz(m_f, 10 .^ (m_sd/10), ...
            m_f_limit(ifreq), m_f_limit(ifreq+1));
    end
end
%% compute correlations between WAVEWATCH energy bands and MERMAID energy bands
cc = corr(m_Ebands,Ebands);

figure;
clf;
set(gcf, 'Unit', 'inches', 'Position', [18 10 6.5 6.5]);
ax = subplot('Position', [0.10 0.08 0.8 0.8]);
imagesc(f_limit, m_f_limit, cc, [-1 1]);
axis xy
colors = jet(7);
colors = [0.25*ones(3,3); colors];
colormap(colors);
c = colorbar('SouthOutside');
c.Label.String = 'correlation coefficient';
c.Label.FontSize = 11;
c.TickDirection = 'both';

xlabel('WAVEWATCH frequency (Hz)')
ylabel('MERMAID frequency (Hz)')

% fix x-label for log scale
xlim([f_limit(1) f_limit(end)])
if strcmp(Fscale, 'log')
    ax.XTick = lin2logpos([0.041 0.05 0.1 0.2 0.3], f_limit(1), f_limit(end));
    ax.XTickLabel = {'0.041'; '0.05'; '0.1'; '0.2'; '0.3'};
end

% fix y-label for log scale
ylim([m_f_limit(1) m_f_limit(end)])
if strcmp(Fscale, 'log')
    ax.YTick = lin2logpos([0.04 0.05 0.1 0.2 0.4 0.8 1.0], m_f_limit(1), ...
        m_f_limit(end));
    ax.YTickLabel = {'0.04'; '0.05'; '0.1'; '0.2'; '0.4'; '0.8'; '1.0'};
end

ax.TickDir = 'both';
ax.FontSize = 12;
grid on

% add f(MERMAID) = 2 * f(WAVEWATCH) line
hold on
if strcmp(Fscale, 'linear')
    plot([0.05 0.3], [0.1 0.6], '--k', 'LineWidth', 2.5);
else
    plot(lin2logpos([0.04 0.3], f_limit(1), f_limit(end)), ...
         lin2logpos([0.08 0.6], m_f_limit(1), m_f_limit(end)), '--k', 'LineWidth', 2.5);
end
hold off

% add period axes
ax2 = doubleaxes(ax);
inverseaxis(ax2.YAxis, 'MERMAID period (s)');
inverseaxis(ax2.XAxis, 'WAVEWATCH period (s)');

% fix axes misalignment
ax2.Position = ax.Position;

% add title
ax2.Title.String = title;

% save figure
figdisp(savetitle, [], [], 2, [], 'epstopdf');
end