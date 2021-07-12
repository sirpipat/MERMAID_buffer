function [ax,ax2,axb] = specdensplot_heatmap(ax,up,np,F,Swbins,Swcounts,...
    SwM,SwU,SwL,sfax,Fscale,plt_title)
% [ax,ax2,axb] = SPECDENSPLOT_HEATMAP(ax,up,np,F,SDbins,Swcounts,...
%    Swmean,SwU,SwL,Fscale,plt_title)
% Plot the heatmap of spectral density bins.
% 
% INPUT
% ax            axes to plot [default: gca]
% up            percent of uptime
% np            percent of noise time within the uptime
% F             frequnencies (linearly or logarithmic equally spaced)
% Swbins        spectral density bins
% Swcounts      spectral densities counts (Swcounts(freq, Swbin number))
% SwM           middle value of spectral densities for each frequency
% SwU           upper confidence limit
% SwL           lower confidence limit
% sfax          Y-axis scaling factor [default: 10]
% Fscale        scale of X-axis (linear or log) [default: 'log']
% plt_title     title for the plot
% 
% OUTPUT
% ax            axes handling the heatmap
% ax2           axes handling the period labels and rhs axis labels
% axb           axes handling the uptime and signal percents report
%
% SEE ALSO
% SPECDENSPLOT_SECTION
%
% Last modified by Sirawich Pipatprathanporn: 07/11/2021

defval('sfax',10)
defval('Fscale','log')

% plot the heatmap
axes(ax)
p = imagesc([F(1) F(end)],[Swbins(1) Swbins(end)], Swcounts');
axis xy

% make zero bins white
cmap = colormap('parula');
cmap = [1 1 1; cmap];
colormap(gcf, cmap);

% add colorbar
c = colorbar('southoutside');
c.Label.String = sprintf('counts (total = %i)', sum(Swcounts(1,:), 2));

grid on

% fix x-label for log scale
ax.XLim = [-0.0005 F(end)];
if strcmp(Fscale, 'log')
    ax.XTick = log10([0.0001 0.001 0.01 0.1 1 10 20] / F(1)) * F(end) / ...
        log10(F(end)/F(1));
    ax.XTickLabel = {'0.0001'; '0.001'; '0.01'; '0.1'; '1'; '10'; '20'};
end

% fix y-label
ax.YTick = (floor(Swbins(1) / 20) * 20):20:(ceil(Swbins(end) / 20) * 20);

% fix the precision of the time on XAxis label
if strcmp(Fscale, 'linear')
    winlen = round(1 / (F(2) - F(1)));
else
    winlen = round(1 / F(1));
end
ax.XAxis.Label.String = sprintf('frequency (Hz): %d s window', winlen);

% fix the precision of the frequency on YAxis label
yfreq = 'spectral density (energy/Hz)';
y_label = ylabel(sprintf('%g %s%s', sfax, 'log_{10}',  yfreq));

% add label on the top and right
ax.TickDir = 'both';

% add mean and upper and lower interval lines
hold on
if strcmp(Fscale, 'log')
    plot(lin2logpos(F, F(1), F(end)), SwM, 'LineWidth', 1, ...
        'Color', rgbcolor('red'));
    plot(lin2logpos(F, F(1), F(end)), SwU, 'LineWidth', 1, ...
        'Color', rgbcolor('white'));
    plot(lin2logpos(F, F(1), F(end)), SwL, 'LineWidth', 1, ...
        'Color', rgbcolor('white'));
else
    plot(F, SwM, 'LineWidth', 1, 'Color', rgbcolor('red'));
    plot(F, SwU, 'LineWidth', 1, 'Color', rgbcolor('white'));
    plot(F, SwL, 'LineWidth', 1, 'Color', rgbcolor('white'));
end
hold off

% add frequency bands label
hold on
if strcmp(Fscale, 'log')
    ax = vline(ax, log10([0.05, 0.1] / F(1)) * F(end) / ...
        log10(F(end)/F(1)), 'LineStyle', '--', 'LineWidth', 1, ...
        'Color', rgbcolor('green'));
    ax = vline(ax, log10([2, 10] / F(1)) * F(end) / ...
        log10(F(end)/F(1)), 'LineStyle', '--', 'LineWidth', 1, ...
        'Color', rgbcolor('brown'));
else
    ax = vline(ax, [0.05, 0.1], 'LineStyle', '--', 'LineWidth', 1, ...
        'Color', rgbcolor('green'));
    ax = vline(ax, [2, 10], 'LineStyle', '--', 'LineWidth', 1, ...
        'Color', rgbcolor('brown'));
end
hold off

% add the second axes
ax2 = doubleaxes(ax);
inverseaxis(ax2.XAxis, 'period (s)');

% add title
ax2.Title.String = plt_title;

% add annotation about uptime and noisetime
% axb = []; 
axb = addbox(ax, [0.6 0.75 0.38 0.23]);
[x_up, y_up] = norm2trueposition(axb, 0.05, 0.75);
[x_np, y_np] = norm2trueposition(axb, 0.05, 0.35);
text(x_up, y_up, sprintf('Uptime: %2.2f %%', up), 'FontSize', 9);
text(x_np, y_np, sprintf('Signal: %2.2f %%', 100-np), 'FontSize', 9);
end