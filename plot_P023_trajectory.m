function plot_P023_trajectory
% NO INPUT
%
% plot P023 trajectory during 13 Sep 2018 to 15 Aug 2019
%
% Last edited by Sirawich Pipatprathanporn, 09/28/2021

% reads P023 vit file to obtain the trajectory
T = readvit('/Users/sirawich/research/raw_data/metadata/vit/P023_all.txt');

[C, ia] = unique(T.Date);
TC = T(ia,:);

C.Format = 'dd-MMM-uuuu';
c_str = string(C);

figure
set(gcf, 'Unit', 'inches', 'Position', [2 8 6.5 8])
clf

%% plot a small map, showing the trajectory
ax1 = subplot('Position',[0.14 0.77 0.76 0.18]);
ax1.DataAspectRatio = [1 1 1];
[lons,lats,elev,~,~] = bathymetry([], [-144 -140.5], [-24.45 -23.75]);
imagesc(lons, lats, elev', [-11000 9000]);
axis xy;
[cb,cm] = cax2dem([-7000 3500], 'hor');
delete(cb);
hold on
plot(mod(TC.stlo(1:46), 360), TC.stla(1:46), '.-w');
text(mod(TC.stlo(1), 360) - 0.2, TC.stla(1) - 0.06, c_str(1,:), ...
    'FontSize', 13, 'Color', 'w');
% text(TC.stlo(27)-0.2,TC.stla(27)-0.03,c_str(27,:), 'FontSize', 13);
text(mod(TC.stlo(46), 360) + 0.05,TC.stla(46) - 0.01, c_str(46,:), ...
    'FontSize', 13, 'Color', 'w');
ylabel('latitude (degrees)');
% title('Trajectory');
xlabel('longitude (degrees)');
grid on;
ylim([-24.45 -23.75]); 
% add box
set(gca, 'TickDir', 'both', 'Box', 'on', 'FontSize', 13);

% convert longitude ticks label to be from -180 and +180 degrees
ax1.XTickLabel = string(mod(ax1.XTick+180, 360) - 180);

% add second axes
doubleaxes(ax1);

%% plot the big map, showing the surrounding continents
ax2 = subplot('Position',[0.14 0.08 0.76 0.60]);
[lons,lats,elev,~,~] = bathymetry([], [140 280], [-55 30]);

imagesc(lons, lats, elev', [-11000 9000]);
axis xy;

% add colorbar
[cb,cm] = cax2dem([-7000 3500], 'hor');
cb.Label.String = 'elevation (m)';
cb.Label.FontSize = 13;
cb.TickDirection = 'both';

% plot coastlines
[axlim,handl,XYZ] = plotcont([140 30], [280 -55], 1, 0);
set(handl, 'LineWidth', 1)
% plot plate boundaries
[handlp, XYp] = plotplates([140 30], [280 -55], 1);
set(handlp, 'Color', 'r', 'LineWidth', 1);
% plot frame of the trajectory map
plot([-144 -140.5 -140.5 -144 -144] + 360, ...
    [-23.8 -23.8 -24.4 -24.4 -23.8], 'y', 'LineWidth', 1);
% label of places
text(142, -28, 'Australia', 'FontSize', 13, 'Color', 'k');
text(178, -40, 'New Zealand', 'FontSize', 13, 'Color', 'k');
text(198, 17, 'Hawaii', 'FontSize', 13, 'Color', 'w');
text(240, 10, 'North America', 'FontSize', 13, 'Color', 'k');
text(210, -15, 'Tahiti', 'FontSize', 13, 'Color', 'k');

grid on;
xlim([140 280]);
xticklabels({'140', '160', '180', '-160', '-140', '-120', '-100', ...
            '-80'});
ylim([-55 30]);
ylabel('latitude (degrees)');
xlabel('longitude (degrees)');

% add box
set(gca, 'TickDir', 'both', 'Box', 'on', 'FontSize', 13);

% add second axes
ax2s = doubleaxes(ax2);

% fix axes misalignment
ax2s.Position = ax2.Position;
ax2s.DataAspectRatio = ax2.DataAspectRatio;

%% save the figure
figdisp(mfilename, [], [], 2, [], 'epstopdf');
end