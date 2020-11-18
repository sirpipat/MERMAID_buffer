function ax = hline(ax,y,linestyle,linewidth,linecolor)
% ax = HLINE(ax,x,linestyle,linewidth,linecolor)
% plots a horizontal line at y
%
% INPUT:
% ax            Current axes
% y             y position of the horizontal line
% linestyle     Line style
% linewidth     Line width
% linecolor     Line color
%
% OUTPUT:
% ax            The handling axes of the horizontal line
%
% Last modified by Sirawich Pipatprathanporn, 11/10/2020

defval('linestyle','-');
defval('linewidth',0.5);
defval('linecolor','r');
defval('label','');

if size(y,1) > 1
    y = reshape(y,1,size(y,1));
end

axes(ax)
hold on
h = plot([ax.XLim(1) ax.XLim(2)], [y; y], 'LineStyle', linestyle, ...
    'LineWidth', linewidth, 'Color', linecolor);
% this last part is so that it doesn't show up on legends
set(h,'tag','vline','handlevisibility','off');
hold off
end