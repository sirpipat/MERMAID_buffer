function ax = mapevents(s)
% ax = MAPEVENTS(s)
%
% Plots matched events distributions on a global map.
%
% INPUT:
% s         events struct
%
% OUTPUT:
% ax        axes handle of the plot
%
% EXAMPLE:
% [s, ~, ~] = eventcatalog();
% ax = mapevents(s);
%
% Last modified by Sirawich Pipatprathanporn, 03/18/2021

% create an axes for the map
ax = subplot('Position', [0.07 0.09 0.86 0.6]);

% Uncomment this section to plot bathymetry
% It takes a while to read a GEBCO file and plot. It tries to save the data
% for later use to speed up but fail to do so, because the savefile is too
% large. If you want to run again, remove the hash file before running.

% % plot bathymetry
% [lons,lats,elev,~,~] = bathymetry([], [1 360], [-90 90]);
% 
% imagesc(lons, lats, elev', [-11000 9000]);
% axis xy;
% 
% % add colorbar
% [cb,cm] = cax2dem([-7000 3500], 'hor');
% cb.Label.String = 'elevation (m)';
% cb.Label.FontSize = 13;
% cb.TickDirection = 'both';

% plot coastlines
[axlim,handl,XYZ] = plotcont([0 90], [360 -90], 1, 0);
% plot plate boundaries
[handlp, XYp] = plotplates([0 90], [360 -90], 1);
handlp.Color = 'r';

% find event locations
evlos = zeros(size(s));
evlas = zeros(size(s));
for ii = 1:size(s,1)
    evlos(ii) = mod(s(ii).evlo, 360);
    evlas(ii) = s(ii).evla;
end


% add P023 station
dt = datetime(2019, 1, 1, 0, 0, 0, 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC');
[mlon, mlat] = mposition(dt);

% plot paths from events to stations
for ii = 1:size(s,1)
    plottrack(ax, [evlos(ii) evlas(ii)], [mlon mlat], 0, ...
          100, 'LineWidth', 0.5, 'Color', [0.7 0.8 0.9]);
end

% add event locations
isDET = false(size(s));
for ii = 1:size(s,1)
    if strcmp(s(ii).tag, 'DET')
        isDET(ii) = true;
    end
end
scatter(evlos(~isDET), evlas(~isDET), 16, 'Marker', 'o', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.2 0.6 1])
scatter(evlos(isDET), evlas(isDET), 80, 'Marker', 'p', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y')

% plot P023 station
scatter(mod(mlon, 360), mlat, 50, 'Marker', 'v', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.3 0.9 0.3]);

grid on
xlim([0 360]);
ylim([-90 90]);

% add box
ax.Box = 'on';

% ticks label
ax.XTick = 0:30:360;
ax.XTickLabel = {'0', '30', '60', '90', '120', '150', '180', '-150', ...
                  '-120', '-90', '-60', '-30', '0'};
ax.YTick = -90:30:90;
ax.YTickLabel = {'-90', '-60', '-30', '0', '30', '60', '90'};
ax.TickDir = 'both';
axs = doubleaxes(ax);
axs.Position = ax.Position;
axs.TickDir = 'both';

% save the figure
figdisp(strcat(mfilename), [], [], 2, [], 'epstopdf');
end