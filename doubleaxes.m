function ax2 = doubleaxes(ax)
% ax2 = DOUBLEAXES(ax)
%
% Added second axes to the top-right
%
%
% INPUT
% ax    the exisiting axes of a plot
%
% OUTPUT
% ax2   the second axes
%
% Last modified by Sirawich Pipatprathanporn: 11/10/2020

ax2 = axes();
ax2.Position = ax.Position;
ax2.DataAspectRatio = ax.DataAspectRatio;
ax2.DataAspectRatioMode = ax.DataAspectRatioMode;
ax2.XAxisLocation = 'top';
ax2.FontSize = ax.FontSize;
ax2.XScale = ax.XScale;
ax2.XLim = ax.XLim;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Make this statement independent from the origial plot
if ax2.XScale == "log" && ax2.XLim(1) == 0
    ax2.XLim(1) = ax.Children(end-3).XData(2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax2.XTick = ax.XTick;
% remove ticks beyond the XLim
where = and(ax2.XTick >= ax2.XLim(1), ax2.XTick <= ax2.XLim(end));
ax2.XTick = ax2.XTick(where);
ax2.XTickLabel = ax.XTickLabel;

ax2.YAxisLocation = 'right';
ax2.YScale = ax.YScale;
ax2.YLim = ax.YLim;

ax2.YTick = ax.YTick;
ax2.YTickLabel = ax.YTickLabel;

ax2.Title.String = ax.Title.String;
ax.Title.String = '';
axes(ax);
end
