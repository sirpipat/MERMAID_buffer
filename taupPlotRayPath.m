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

% draw earth
R_earth = 6371;
R_210 = R_earth - 210;
R_410 = R_earth - 440;
R_660 = R_earth - 660;
R_outcore = R_earth - 2891.50;
R_incore = R_earth - 5153.50;

d = (0:0.01:1)' * 2 * pi;
C_surface = R_earth * [sin(d), cos(d)];
C_210 = R_210 * [sin(d), cos(d)];
C_410 = R_410 * [sin(d), cos(d)];
C_660 = R_660 * [sin(d), cos(d)];
C_outcore = R_outcore * [sin(d), cos(d)];
C_incore = R_incore * [sin(d), cos(d)];

plot(C_surface(:,1), C_surface(:,2), 'LineWidth', 1.5, 'Color', rgbcolor('gray'));
hold on
plot(C_210(:,1), C_210(:,2), 'LineWidth', 1, 'Color', rgbcolor('gray'));
plot(C_410(:,1), C_410(:,2), 'LineWidth', 1, 'Color', rgbcolor('gray'));
plot(C_660(:,1), C_660(:,2), 'LineWidth', 1, 'Color', rgbcolor('gray'));
plot(C_outcore(:,1), C_outcore(:,2), 'LineWidth', 1, 'Color', rgbcolor('gray'));
plot(C_incore(:,1), C_incore(:,2), 'LineWidth', 1, 'Color', rgbcolor('gray'));

% calculate ray paths
paths = taupPath(model, depth, phase, varargin{:});
color = {'1','2','3','4','5','6','7'};
lines = [];
phaselist = cell(0);
for ii = 1:size(paths,2)
    radius = R_earth - paths(1,ii).path.depth;
    angle = paths(1,ii).path.distance * pi / 180;
    path = [radius .* sin(angle), radius .* cos(angle)];
    % draw ray paths
    l = plot(path(:,1), path(:,2), 'LineWidth', 2, 'Color', ...
         rgbcolor(color{mod(ii,7)+1}));
    lines = [lines, l];
    phaselist{size(phaselist,2)+1} = paths(ii).phaseName;
end
legend(lines,phaselist);

% plot event and station

hold off
end