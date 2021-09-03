function [x_norm, y_norm] = true2normposition(ax, x, y)
% [x_norm, y_norm] = TRUE2NORMPOSITION(ax, x, y)
%
% converts true position to normalized position on an axes
%
% INPUT:
% ax        Axes of interest
% x         True x coordinate on the axes
% y         True y coordinate on the axes
%
% OUTPUT:
% x_norm    Normalized x coordinate on the axes
% y_norm    Normalized y coordinate on the axes
%
% Last modified by sirawich@princeton.edu, 07/26/2021

if strcmp(ax.XScale, 'linear')
    x_norm = (x - ax.XLim(1)) / (ax.XLim(2) - ax.XLim(1));
else
    x_norm = log(x / ax.XLim(1)) / log(ax.XLim(2) / ax.XLim(1));
end

if strcmp(ax.YScale, 'linear')
    y_norm = (y - ax.YLim(1)) / (ax.YLim(2) - ax.YLim(1));
else
    y_norm = log(y / ax.YLim(1)) / log(ax.YLim(2) / ax.YLim(1));
end
end