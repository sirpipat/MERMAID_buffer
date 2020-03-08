function ax = vline(ax,x,linestyle,linewidth,linecolor)
% ax = VLINE(ax,x,linestyle,linewidth,linecolor)
% plots a vertical line at x
%
% INPUT:
% ax            Current axes
% x             x position of the vertical line
% linestyle     Line style
% linewidth     Line width
% linecolor     Line color
%
% OUTPUT:
% ax            The handling axes of the vertical line
%
% Last modified by Sirawich Pipatprathanporn, 03/07/2020

defval('linestyle','-');
defval('linewidth',0.5);
defval('linecolor','r');
defval('label','');

axes(ax)
v = plot([x x], [ax.YLim(1) ax.YLim(2)], 'LineStyle', linestyle, ...
    'LineWidth', linewidth, 'Color', linecolor);
% this last part is so that it doesn't show up on legends
set(v,'tag','vline','handlevisibility','off');
end