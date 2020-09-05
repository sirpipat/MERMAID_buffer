function taupPlotRayPath(ax, model, depth, phase, varargin)
% TAUPPLOTRAYPATH plot ray paths on an Earth cross-section
%
% taupPlotRayPath(ax, model, depth, phase, varargin)
%
% Input arguments:
% The first four arguments are fixed:
%   ax:         Axes to plot
%   model:      Global velocity model. Default is "iasp91".
%   depth:      Event depth in km
%   phase:      Phase list separated by comma
% The other arguments are variable:
%   'deg' value:   Epicentral distance in degree
%   'km'  value:   Epicentral distance in kilometer
%   'sta'/'station' value:  Station location [Lat Lon]
%   'evt'/'event' value:    Event location [Lat Lon]
%
% SEE ALSO
% TAUPPATH
%
% Last modified by Sirawich Pipatprathanporn: 09/05/2020

defval('model', 'iasp91');

axes(ax)

%% draw earth
R_earth = 6371;
R_moho = R_earth - 35;
R_210 = R_earth - 210;
R_410 = R_earth - 440;
R_660 = R_earth - 660;
R_outcore = R_earth - 2891.50;
R_incore = R_earth - 5153.50;
Rs = [R_earth R_moho R_210 R_410 R_660 R_outcore R_incore];

d = (0:0.001:1)' * 2 * pi;
Cxs = Rs .* sin(d);
Cys = Rs .* cos(d);

plot(Cxs(:,1), Cys(:,1), 'LineWidth', 1.5, 'Color', rgbcolor('gray'));
hold on
plot(Cxs(:,2:end), Cys(:,2:end), 'LineWidth', 1, 'Color', rgbcolor('gray'));

%% draw ray paths
paths = taupPath(model, depth, phase, varargin{:});
color = {'1','2','3','4','5','6','7'};
lines = [];
phaselist = cell(0);
for ii = 1:size(paths,2)
    radius = R_earth - paths(1,ii).path.depth;
    angle = paths(1,ii).path.distance * pi / 180;
    path = [radius .* sin(angle), radius .* cos(angle)];
    l = plot(path(:,1), path(:,2), 'LineWidth', 2, 'Color', ...
         rgbcolor(color{mod(ii,7)+1}));
    lines = [lines, l];
    phaselist{size(phaselist,2)+1} = paths(ii).phaseName;
end

%% plot event and station
scatter(0, R_earth - depth, 150, 'Marker', 'p', 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'y');
scatter(radius(end) * sin(angle(end)), radius(end) * cos(angle(end)), ...
        100, 'Marker', 'v', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
hold off

%% adjust axes details
legend(lines,phaselist);
axis equal

ax.Color = 'none';
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
end