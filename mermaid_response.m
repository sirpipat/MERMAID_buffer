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
% ratio         MERMAID frequency to WAVEWATCH frequency ratio[default: 2]
% shift         shift from f_MM[default: 0]
%               f_WW = (ratio * f_MM) + shift
%
% OUTPUT
% no output beside figures saved at $EPS
%
% Last modified by Sirawich Pipatprathanporn, 11/03/2020

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
    [~, E_WW, E_MM] = compare_energy(option, f, ...
        f * ratio + f_width * (ratio-1) / 2 * [1,-1] + shift, ...
        'raw', true);
    offsets(1,ii) = mean(E_MM - E_WW);
    corrs(1,ii) = corr(E_MM, E_WW);
end

%% plot results
figure
set(gcf, 'Unit', 'inches', 'Position', [18 8 8 3.5]);
ax1 = subplot(1,2,1);
plot(f_WW_middle, offsets, 'LineWidth', 2);
xlim(f_WW_middle([1 end]));
grid on
xlabel('WAVEWATCH frequency (Hz)');
ylabel('10 log_{10} (E_{MM} / E_{WW})');
if option == 1
    scale_string = 'weekly';
elseif option == 2
    scale_string = 'biweekly';
else
    scale_string = 'monthly';
end
title(sprintf('%s scale, f-width = %6.4f', scale_string, f_width));
set(gca, 'FontSize', 10, 'TickDir', 'both');

ax2 = subplot(1,2,2);
plot(f_WW_middle, corrs, 'LineWidth', 2);
xlim(f_WW_middle([1 end]));
grid on
xlabel('WAVEWATCH frequency (Hz)');
ylabel('correlation coefficient');
title(sprintf('f_{MM} = %4.2f f_{WW} + %4.2f', ratio, shift));
set(gca, 'FontSize', 10, 'TickDir', 'both');

%% save figure
save_title = strcat(mfilename, '_', scale_string);
save_title = sprintf('%s_%5.3f_%5.3f_%5.3f.eps', save_title, f_width, ...
    ratio, shift);
figdisp(save_title, [], [], 2, [], 'epstopdf');
end