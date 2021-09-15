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
% Last modified by Sirawich Pipatprathanporn: 09/14/2021

ax2 = axes();
ax2.Position = ax.Position;
ax2.DataAspectRatio = ax.DataAspectRatio;
ax2.DataAspectRatioMode = ax.DataAspectRatioMode;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Switches the second axes axis rulers to datetime or duration if necessary
% Otherwise, setting limits to the axes will yield an error.
xlimits = ax.XAxis.Limits;
ylimits = ax.YAxis.Limits;
if isdatetime(xlimits)
    xval = datetime('today', 'TimeZone', 'UTC');
elseif isduration(xlimits)
    xval = seconds(1);
else
    xval = 1;
end
if isdatetime(ylimits)
    yval = datetime('today', 'TimeZone', 'UTC');
elseif isduration(ylimits)
    yval = seconds(1);    
else
    yval = 1;
end
plot(xval, yval);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
ax2.XTickLabel = ax.XTickLabel(where);

ax2.YAxisLocation = 'right';
ax2.YScale = ax.YScale;
ax2.YLim = ax.YLim;

ax2.YTick = ax.YTick;
ax2.YTickLabel = ax.YTickLabel;

ax2.Title.String = ax.Title.String;
ax.Title.String = '';
axes(ax);
end
