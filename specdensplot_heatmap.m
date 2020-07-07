function [ax,ax2,axb] = specdensplot_heatmap(ax,up,np,F,SDbins,Swcounts,...
    Swmean,SwU,SwL,Fscale,plt_title)


p = imagesc([F(1) F(end)],[SDbins(1) SDbins(end)], Swcounts');
axis xy

% make zero bins white
cmap = colormap('parula');
cmap = [1 1 1; cmap];
colormap(gcf, cmap);

% add colorbar
c = colorbar('southoutside');
c.Label.String = sprintf('counts (total = %i)', sum(Swcounts(1,:), 2));

% fix x-label for log scale
if strcmp(Fscale, 'log')
    ax.XTick = log10([0.1 1 10] / F(1)) * F(end) / ...
        log10(F(end)/F(1));
    ax.XTickLabel = {'0.1'; '1'; '10'};
end
grid on

% fix the precision of the time on XAxis label
if strcmp(Fscale, 'linear')
    winlen = round(1 / (F(2) - F(1)));
else
    winlen = round(1 / F(1));
end
ax.XAxis.Label.String = sprintf('frequency (Hz): %d s window', winlen);

% fix the precision of the frequency on YAxis label
yfreq = 'spectral density (energy/Hz)';
y_label = ylabel(sprintf('%s ; %s = %.4f', yfreq, '\Delta\itf', 1/winlen));

% add label on the top and right
ax.TickDir = 'both';
ax2 = doubleaxes(ax);

% add axis label
inverseaxis(ax2.XAxis, 'Period (s)');

% add title
ax2.Title.String = plt_title;

% add mean and upper and lower interval lines
hold on
if strcmp(Fscale, 'log')
    plot(lin2logpos(F, F(1), F(end)), Swmean, 'LineWidth', 1, ...
        'Color', rgbcolor('red'));
    plot(lin2logpos(F, F(1), F(end)), SwU, 'LineWidth', 1, ...
        'Color', rgbcolor('white'));
    plot(lin2logpos(F, F(1), F(end)), SwL, 'LineWidth', 1, ...
        'Color', rgbcolor('white'));
else
    plot(F, Swmean, 'LineWidth', 1, 'Color', rgbcolor('red'));
    plot(F, SwU, 'LineWidth', 1, 'Color', rgbcolor('white'));
    plot(F, SwL, 'LineWidth', 1, 'Color', rgbcolor('white'));
end
hold off

% add frequency bands label
hold on
if strcmp(Fscale, 'log')
    ax = vline(ax, log10([0.05, 0.1] / F(1)) * F(end) / ...
        log10(F(end)/F(1)), '--', 1, rgbcolor('green'));
    ax = vline(ax, log10([2, 10] / F(1)) * F(end) / ...
        log10(F(end)/F(1)), '--', 1, rgbcolor('brown'));
else
    ax = vline(ax, [0.05, 0.1], '--', 1, rgbcolor('green'));
    ax = vline(ax, [2, 10], '--', 1, rgbcolor('brown'));
end
hold off

% add annotation about uptime and noisetime
axb = addbox(ax, [0.6 0.75 0.38 0.23]);
[x_up, y_up] = norm2trueposition(axb, 0.05, 0.75);
[x_np, y_np] = norm2trueposition(axb, 0.05, 0.35);
text(x_up, y_up, sprintf('Uptime: %2.2f %%', up), 'FontSize', 9);
text(x_np, y_np, sprintf('Signal: %2.2f %%', 100-np), 'FontSize', 9);
end