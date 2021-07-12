function mermaid_response(option, f_width, ratio, shift)
% MERMAID_RESPONSE(option, binwidth)
% Plots the mean energy offset between MERMAID and WAVEWATCH over the same
% frequency width on the double freuency line.
%
% INPUT
% option        1 - weekly
%               2 - biweekly (every 2 weeks)
%               3 - monthly
% f_width       frequency width
% ratio         MERMAID frequency to WAVEWATCH frequency ratio [default: 2]
% shift         shift from f_MH [default: 0]
%               f_WW = (ratio * f_MH) + shift
%
% OUTPUT
% no output beside figures saved at $EPS
%
% Last modified by Sirawich Pipatprathanporn, 07/11/2021

defval('ratio', 2)
defval('shift', 0)

% create frequency bands
f_WW = 0.0411:f_width:0.304;
f_WW_middle = 0.5 * (f_WW(1:end-1) + f_WW(2:end));

% energy offset: MERMAID - WAVEWATCH
offsets = zeros(size(f_WW_middle));
corrs = zeros(size(f_WW_middle));
for ii = 1:size(f_WW,2)-1
    f = f_WW(ii:ii+1);
    [~, E_WW, E_MH] = compare_energy(option, f, ...
        f * ratio + f_width * (ratio-1) / 2 * [1,-1] + shift, ...
        'raw', false);
    offsets(1,ii) = mean(E_MH - E_WW);
    corrs(1,ii) = corr(E_MH, E_WW);
end

% read MERMAID gain curve
[f, gain] = mermaidcurve;

%% plot results
figure
set(gcf, 'Unit', 'inches', 'Position', [18 8 8 3.5]);

% plot energy offset
ax1 = subplot('Position', [0.08 0.14 0.36 0.66]);
plot(f_WW_middle, offsets, 'LineWidth', 2);
hold on

hold off
xlim(round(f_WW_middle([1 end]), 2, 'significant'));
grid on
xlabel('WAVEWATCH frequency (Hz)');
ylabel('10 log_{10} (E_{MH} / E_{WW})');
set(gca, 'FontSize', 10, 'TickDir', 'both', 'Color', 'none');
ax1s = doubleaxes(ax1);
inverseaxis(ax1s.XAxis, 'WAVEWATCH period (s)');
if option == 1
    scale_string = 'weekly';
elseif option == 2
    scale_string = 'biweekly';
else
    scale_string = 'monthly';
end
ax1s.Title.String = sprintf('%s scale, f-width = %6.4f', scale_string, ...
    f_width);
axes(ax1s)
hold on
plot(ax1s, (f-shift)/ratio, gain, 'LineWidth', 2, 'Color', [1 0.5 0]);
hold off
grid on
ax1s.YLim = [20 34];
ax1s.YTick = 20:2:34;
ax1s.YTickLabel = 20:2:34;
ax1s.YLabel.String = 'MERMAID gain';
vline(ax1s, 0.2, 'LineStyle', '--', 'LineWidth', 1.5, 'Color', [1 0.5 0]);
axes(ax1)

% plot correlation coefficient
ax2 = subplot('Position', [0.58 0.14 0.36 0.66]);
plot(f_WW_middle, corrs, 'LineWidth', 2);
xlim(round(f_WW_middle([1 end]), 2, 'significant'));
ylim([-1 1]);
grid on
xlabel('WAVEWATCH frequency (Hz)');
ylabel('correlation coefficient');
set(gca, 'FontSize', 10, 'TickDir', 'both');
ax2s = doubleaxes(ax2);
inverseaxis(ax2s.XAxis, 'WAVEWATCH period (s)');
ax2s.Title.String = sprintf('f_{MH} = %4.2f f_{WW} + %4.2f', ratio, shift);

%% save figure
save_title = strcat(mfilename, '_', scale_string);
save_title = sprintf('%s_%5.3f_%5.3f_%5.3f.eps', save_title, f_width, ...
    ratio, shift);
figdisp(save_title, [], [], 2, [], 'epstopdf');
end