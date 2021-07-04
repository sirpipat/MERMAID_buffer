function energy_z_score_plot
% ENERGY_Z_SCORE_PLOT
% Plots the correlation coefficients of energy of WAVEWATCH surface 
% equivalent pressure and spectral density of 1500-m depth pressure 
% recorded by MERMAID and illustrate energy comparisons in 3 regions.
% 
% E(a <= f <= b) = \int_a^b s(f) df where s(f) is spectral density.
%
% No input and output beside a figure saved at $EPS.
%
% SEE ALSO
% ENERGY_CC, COMPARE_ENERGY
%
% Last modified by Sirawich Pipatprathanporn, 07/05/2021

F_WW = [0.06 0.08; 0.21 0.23; 0.10 0.12];
F_MM = [0.13 0.15; 0.36 0.38; 0.44 0.46];
t_label = {'b', 'c', 'd'};
t_color = {'k', 'w', 'k'};

figure
set(gcf, 'Unit', 'inches', 'Position', [2 8 6 9]);

WWdir = '/Users/sirawich/research/processed_data/weekly_WWSD_profiles/';
SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';
[allp2ls, pndex] = allfile(WWdir);
[allSDs, ~] = allfile(SDdir);

%% compute energies

% energies in different frequency bands
binscale = 1.01;
f_limit = logspace(log10(0.041),log10(0.304),...
                   round(log(0.304/0.040)/log(binscale)));
m_f_limit = logspace(log10(0.040),log10(1.000),...
                     round(log(1.000/0.040)/log(binscale)));
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

ax = subplot('Position', [0.05 0.58 0.8 0.34]);
imagesc(f_limit, m_f_limit, cc, [-1 1]);
axis xy
colors = jet(7);
colors = [0.25*ones(3,3); colors];
colormap(colors);
c = colorbar('WestOutside');
c.Label.String = 'correlation coefficient';
c.Label.FontSize = 9;
c.TickDirection = 'both';

xlabel('WAVEWATCH frequency (Hz)')
ylabel('MERMAID frequency (Hz)')

% fix x-label for log scale
xlim([f_limit(1) f_limit(end)])
ax.XTick = lin2logpos([0.041 0.05 0.1 0.2 0.3], f_limit(1), f_limit(end));
ax.XTickLabel = {'0.041'; '0.05'; '0.1'; '0.2'; '0.3'};

% fix y-label for log scale
ylim([m_f_limit(1) m_f_limit(end)])
ax.YTick = lin2logpos([0.04 0.05 0.1 0.2 0.4 0.8 1.0], m_f_limit(1), ...
    m_f_limit(end));
ax.YTickLabel = {'0.04'; '0.05'; '0.1'; '0.2'; '0.4'; '0.8'; '1.0'};
ax.TickDir = 'both';
ax.FontSize = 10;
grid on

% add f(MERMAID) = 2 * f(WAVEWATCH) line
hold on
plot(lin2logpos([0.04 0.3], f_limit(1), f_limit(end)), ...
     lin2logpos([0.08 0.6], m_f_limit(1), m_f_limit(end)), '--k', ...
     'LineWidth', 2.5);

% add period axes
ax2 = doubleaxes(ax);
inverseaxis(ax2.YAxis, 'MERMAID period (s)');
inverseaxis(ax2.XAxis, 'WAVEWATCH period (s)');

% fix axes misalignment
ax2.Position = ax.Position;

% add title
ax2.Title.String = 'Energy correlation coefficient (weekly scale)';
ax2.Title.FontWeight = 'normal';

% annotate cc-plot
for ii = 1:3
    f_WW = F_WW(ii,:);
    f_MM = F_MM(ii,:);
    [x, y] = boxcorner(f_WW, f_MM);
    plot(lin2logpos(x,0.041,0.304), lin2logpos(y,0.04,1.0), ...
        'Color', t_color{ii}, 'LineWidth', 1.5);
    text(lin2logpos((x(1)+x(2))/2,0.041,0.304), ...
        lin2logpos(y(3)*1.1,0.04,1.0), ...
        t_label{ii}, 'FontSize', 11, 'Color', t_color{ii});
end

% label the cc-plot
boxedlabel(ax, 'northwest', 0.25, [], 'a', 'FontSize', 12);

%% plot z-score
for ii = 1:3
    y_pos = 0.15 * (3-ii);
    y_shift = 0.08 * floor(ii/3);
    ax1 = subplot('Position', [0.15 0.08+y_pos-y_shift 0.8 0.12+y_shift]);
    f_WW = F_WW(ii,:);
    f_MM = F_MM(ii,:);
    [t,E_WW,E_MM] = compare_energy(1, f_WW, f_MM, 'scaled', false);
    plot(t,E_WW,'o-','LineWidth',1.5,'MarkerSize',2.5,'MarkerFaceColor',...
        rgbcolor('1'));
    hold on
    plot(t,E_MM,'o-','LineWidth',1.5,'MarkerSize',2.5,'MarkerFaceColor',...
        [0.95 0.1 0.1],'Color',[0.95 0.1 0.1]);
    hold off
    grid on
    xlim([t(1) t(end)])
    ylim([-4 4])
    ylabel(sprintf('z-score of\n%g log_{10} (Energy)', 10))
    titlename = 'Energy level (weekly scale)';
    titlename = sprintf('%s, cc = %5.3f', titlename, corr(E_WW,E_MM));
    title('')%title(titlename, 'FontWeight', 'normal')
    label_WW = sprintf('WAVEWATCH (%5.3f - %5.3f Hz)', f_WW(1), f_WW(end));
    label_MM = sprintf('MERMAID        (%5.3f - %5.3f Hz)', f_MM(1), f_MM(end));
    if ii == 3
        legend('WAVEWATCH','MERMAID','Location','SouthOutside')
    end
    set(gca, 'FontSize', 10, 'TickDir', 'both');
    ax1.Title.Position(2) = ax1.Title.Position(2) + 0.2;
    
    boxedlabel(ax1, 'northwest', 0.25, [], t_label{ii}, 'FontSize', 12);
    
    % remove redundant labels
    if ii < 3
        set(gca, 'XTickLabel', []);
    end
end
% save figure
figdisp('coherence_plot.eps',[],[],2,[],'epstopdf')
end
