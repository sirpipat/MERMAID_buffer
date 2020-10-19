function eventcatalog(fname)
% EVENTCATALOG(fname)
% Plot distributions of earthquake magnitudes and epicentral distances
%
% INPUT:
% fname     full filename containing events
% 
% Last modified by Sirawich Pipatprathanporn: 10/06/2020

defval('fname', ...
    '/Users/sirawich/research/processed_data/events/catalog_events.txt');

% read the catalog file
fid = fopen(fname);
txt = fscanf(fid, '%c');
fclose(fid);

words = split(txt);
words = words(1:end-1);
words = reshape(words, 15, size(words, 1) / 15)';

mags = str2double(words(:,8));
dists = str2double(words(:,9));
tags = strcell(words(:,2));
where = (sum(tags == 'DET', 2) == 3);

% plot
figure(2)
clf
set(gcf, 'Unit', 'inches', 'Position', [2 2 6.5 6]);

% title
ax0 = subplot('Position', [0.1 0.95 0.8 0.01]);
title(sprintf('Catalog MERMAID P023: %d events', size(words,1)));
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';

ax1 = subplot('Position', [0.1 0.1 0.6 0.6]);
p_not_detect = scatter(dists(~where), mags(~where), 20, 'Marker', 'o', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', rgbcolor('deep sky blue'));
hold on
p_detect = scatter(dists(where), mags(where), 80, 'Marker', 'p', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.95 .95 0.1]);
xlabel('epicentral distance (degree)');
ylabel('magnitude');
ax1.XLim = [0 180];
ax1.YLim = [4.5 8.7];
ax1.Box = 'on';
ax1.TickDir = 'both';
grid on
legend([p_detect p_not_detect], 'automatically reported by MERMAID', ...
    'found manually in the buffer');

ax2 = subplot('Position', [0.75 0.1 0.2 0.6]);
histogram(mags, 'BinEdges', 4.45:0.1:8.05, 'Orientation', 'horizontal', ...
    'FaceColor', 'k');
xlabel('counts');
ax2.YLim = ax1.YLim;
ax2.TickDir = 'both';
nolabels(ax2, 2);
grid on

ax3 = subplot('Position', [0.1 0.75 0.6 0.2]);
histogram(dists, 'BinWidth', 5, 'FaceColor', 'k');
ylabel('counts');
ax3.XLim = ax1.XLim;
ax3.TickDir = 'both';
nolabels(ax3, 1);
grid on

% save figure
figdisp(strcat(mfilename, '.eps'), [], [], 2, [], 'epstopdf');
end