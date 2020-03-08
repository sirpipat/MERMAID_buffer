function [x,y] = norm2trueposition(ax,x_norm,y_norm)
% [x,y] = NORM2TRUEPOSITION(ax,x_norm,y_norm)
% converts normalized position to true position on an axes
%
% INPUT:
% ax        Axes of interest
% x_norm    Normalized x coordinate on the axes
% y_norm    Normalized y coordinate on the axes
%
% OUTPUT:
% x         True x coordinate on the axes
% y         True y coordinate on the axes
%
% Last modified by Sirawich Pipatprathanporn, 03/07/2020

x = ax.XLim(1) + x_norm * (ax.XLim(2) - ax.XLim(1));
y = ax.YLim(1) + y_norm * (ax.YLim(2) - ax.YLim(1));
end