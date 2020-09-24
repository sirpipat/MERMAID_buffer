function plotIRISstations(filename)
% PLOTIRISSTATIONS(filename)
% Plots all IRIS stations in filename and includes MERMAIDs to the map as
% well.
%
% INPUT:
% filename      filename containing IRIS stations
%
% OUTPUT:
% no output
%
% Last modified by Sirawich Pipatprathanporn: 09/24/2020

fid = fopen(filename);
% read header
header = fgetl(fid);
% read station data
lat = [];
lon = [];
line = fgetl(fid);
while line ~= -1
    data = split(line, '|');
    lat = [lat double(string(data{3}))];
    lon = [lon double(string(data{4}))];
    line = fgetl(fid);
end
fclose(fid);
% plot figure
figure;
set(gcf, 'Unit', 'inches', 'Position', [0 8 13 7]);
ax = subplot('Position',[0.07 0.1 0.86 0.8]);
% plot tcoastlines
[axlim,handl,XYZ] = plotcont([0 90], [360 -90], 1, 0);
% plot plate boundaries
[handlp, XYp] = plotplates([0 90], [360 -90], 1);
handlp.Color = 'r';
% plot iris stations
scatter(mod(lon, 360), lat, 2, 'Marker', 'v', ...
        'MarkerEdgeColor', rgbcolor('b'), ...
        'MarkerEdgeAlpha', 0.8, ...
        'MarkerFaceColor', rgbcolor('b'), ...
        'MarkerFaceAlpha', 0.8);

    
hold on
% add MERMAIDS
[allvitfiles,vndex] = allfile('/Users/sirawich/research/raw_data/metadata/');
mpos = NaN(0,2);
dt_fm = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
dt = datetime('2019-08-15T09:17:39.000000','InputFormat',dt_fm,...
    'Format',dt_fm,'TimeZone','UTC');
for ii = 1:vndex
    [mpos(ii,1),mpos(ii,2)] = mposition(dt, allvitfiles{ii});
end
scatter(mod(mpos(:,1),360), mpos(:,2), 50, 'Marker', 'v', ...
        'MarkerEdgeColor', rgbcolor('k'), ...
        'MarkerEdgeAlpha', 0.8, ...
        'MarkerFaceColor', rgbcolor('gray'), ...
        'MarkerFaceAlpha', 0.8, ...
        'LineWidth', 1.5);
% add P023
[m23lon, m23lat] = mposition(dt);
scatter(mod(m23lon,360), m23lat, 125, 'Marker', 'v', ...
        'MarkerEdgeColor', rgbcolor('k'), ...
        'MarkerEdgeAlpha', 0.8, ...
        'MarkerFaceColor', rgbcolor('lime green'), ...
        'MarkerFaceAlpha', 0.8, ...
        'LineWidth', 1.5);

ax.XLim = [0 360];
ax.YLim = [-90,90];
grid on
ax.XLabel.String = 'Longitude';
ax.YLabel.String = 'Latitude';
% ticks label
ax.XTick = [0 30 60 90 120 150 180 210 240 270 300 330 360];
ax.XTickLabel = {'0', '30', '60', '90', '120', '150', '180', '-150', ...
    '-120', '-90', '-60', '-30', '0'};
ax.YTick = [-90 -60 -30 0 30 60 90];
ax.YTickLabel = {'-90', '-60', '-30', '0', '30', '60', '90'};
ax.TickDir = 'both';
axs = doubleaxes(ax);
axs.TickDir = 'both';
end