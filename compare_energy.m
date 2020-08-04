function compare_energy(option)

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
else
    WWdir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
    SD_shift = 56.6312;
    f_scale = 2.446;
    t = datetime(2018,9,1,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calmonths(0:11);
end

[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

%% compute energies
% energy from f(1) - f(end)
E = zeros(pndex, 1);
m_E = zeros(pndex, 1);

% energies in different frequency bands
Ebands = zeros(pndex, 21);       % E = E(idt, ifreq)
m_Ebands = zeros(pndex, 44);     % m_E = m_E(idt, ifreq)
for idt = 1:pndex
    % read WAVEWATCH spectral density
    fid = fopen(allp2ls{idt},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    f = data(1,:);
    sd = data(2,:);
    E(idt, 1) = boundtrapz(f, 10 .^ (sd/10), f(1), f(end));
    
    % limit of frequency bands
    f_limit = f;
    for ifreq = 1:21
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
    m_f_limit = f(1) * (1.1 .^ (0:44));
    for ifreq = 1:44
        m_Ebands(idt,ifreq) = boundtrapz(m_f, 10 .^ (m_sd/10), ...
            m_f_limit(ifreq), m_f_limit(ifreq+1));
    end
end

%% plot overall energy level
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

c = corr(m_Ebands,Ebands);

% plot
f_WW = 0.5 * (f_limit(1:end-1) + f_limit(2:end));
f_MM = 0.5 * (m_f_limit(1:end-1) + m_f_limit(2:end));
figure;
imagesc(f_WW, f_MM, c);
axis xy
colorbar

ylim([f_MM(1) f_MM(end)])
xlim([f_WW(1) f_WW(end)])

ylogpos = lin2logpos([f_MM(1) 0.1 1 f_MM(end)], f_MM(1), f_MM(end));
xlogpos = lin2logpos([f_WW(1) 0.1 0.2 f_WW(end)], f_WW(1), f_WW(end));

xticks(xlogpos);
yticks(ylogpos);
yticklabels([f_MM(1) 0.1 1 f_MM(end)]);
xticklabels([f_WW(1) 0.01 0.02 f_WW(end)]);
ylabel('MERMAID frequency (Hz)')
xlabel('WAVEWATCH frequency (Hz)')

ax2 = doubleaxes(gca);
inverseaxis(ax2.YAxis, 'MERMAID period (s)');
inverseaxis(ax2.XAxis, 'WAVEWATCH period (s)');
end