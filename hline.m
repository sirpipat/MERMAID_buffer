function [ax, h] = hline(ax, y, varargin)
% [ax, h] = HLINE(ax, y, varargin)
% plots a horizontal line at y
%
% INPUT:
% ax            Current axes
% y             y position of the horizontal line
% varargin      arguments for plot()
%
% OUTPUT:
% ax            The handling axes of the horizontal line
% h             Line(s) being plotted
%
% Last modified by Sirawich Pipatprathanporn, 05/02/2025

if size(y,1) > 1
    y = reshape(y,1,size(y,1));
end

axes(ax)
hold on
h = plot([ax.XLim(1) ax.XLim(2)], [y; y], varargin{:});
% this last part is so that it doesn't show up on legends
% set(h,'tag','hline','handlevisibility','off');
end