function Clog = plotlogcontour(ax, C, H, xmin, xmax, ymin, ymax)
% Clog = PLOTLOGCONTOUR(ax, C, H, xmin, xmax, ymin, ymax)
% plot contour lines on the plot where the coordinates are linear, but the 
% label is logarithmic. (See SPECDENSPLOT_HEATMAP for examples of such
% plots.)
%
% INPUT:
% ax        axes to plot
% C         contour matrix
% H         coutour object
% xmin      minimum value of x-axis
% xmax      maximum value of x-axis
% ymin      minimum value of y-axis
% ymax      maximum value of y-axis
% 
% OUTPUT:
% Clog      contour object containing logarithmic position on the plot
%
% SEE ALSO:
% CONTOUR, LIN2LOGPOS, SPECDENSPLOT_HEATMAP
%
% Last modified by Sirawich Pipatprathanporn: 08/25/2020

defval('ax', gca)

axes(ax)

len = size(C,2);
index = 1;
% iterate over each line
hold on
while index < len
    num_items = C(2,index);
    plot(ax, lin2logpos(C(1,(1:num_items) + index), xmin, xmax), ...
         lin2logpos(C(2,(1:num_items) + index), ymin, ymax), 'Color', 'k', ...
         'LineWidth', 1);
    index = index + num_items + 1;
end
hold off
Clog = C;
end