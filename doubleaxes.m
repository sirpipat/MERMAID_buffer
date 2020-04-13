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
% Last modified by Sirawich Pipatprathanporn: 04/13/2020

ax2 = axes();
ax2.XAxisLocation = 'top';
ax2.XScale = ax.XScale;
ax2.XLim = ax.XLim;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Make this statement independent from the origial plot
if ax2.XScale == "log" && ax2.XLim(1) == 0
    ax2.XLim(1) = ax.Children(1).XData(2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax2.XTick = ax.XTick;
ax2.XTickLabel = ax.XTickLabel;

ax2.YAxisLocation = 'right';
ax2.YScale = ax.YScale;
ax2.YLim = ax.YLim;

ax2.YTick = ax.YTick;
ax2.YTickLabel = ax.YTickLabel;

ax2.Position = ax.Position;
ax2.Title.String = ax.Title.String;
ax.Title.String = '';
axes(ax);
end
