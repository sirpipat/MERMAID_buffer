function [ax, v] = vline(ax, x, varargin)
% [ax, v] = VLINE(ax, x, varargin)
% plots a vertical line at x
%
% INPUT:
% ax            Current axes
% x             x position of the vertical line
% varargin      arguments for plot()
%
% OUTPUT:
% ax            The handling axes of the vertical line
% v             Line(s) being plotted
%
% Last modified by Sirawich Pipatprathanporn, 01/31/2022

if size(x,1) > 1
    x = reshape(x,1,size(x,1));
end

axes(ax)
hold on
v = plot([x; x], [ax.YLim(1) ax.YLim(2)], varargin{:});
% % this last part is so that it doesn't show up on legends
% set(v,'tag','vline','handlevisibility','off');
end