function simplifyintervals_demo()
% SIMPLIFYINTERVALS_DEMO()
%
% Demo function to illustrate how SIMPLIFYINTERVALS works.
%
% INPUT
% no input
%
% OUTPUT
% no output
%
% SEE ALSO
% SIMPLIFYINTERVALS
%
% Last modified by Sirawich Pipatprathanporn, 07/11/2021

b_in = rand(20,1);
e_in = b_in + 0.15 * rand(20,1);

[b_sorted,index] = sort(b_in);
e_sorted = e_in(index);

[b_out,e_out] = simplifyintervals(b_in,e_in);

figure(1)
clf
set(gcf,'Unit','Inches','Position',[0 1 15 6]);
ax1 = subplot(2,1,1);
ylim([0 20]);
hold on
for ii = 1:size(b_sorted,1)
    plot([b_sorted(ii) e_sorted(ii)], [ii ii], 'k', 'LineWidth', 1);
end
vline(ax1, b_sorted', 'LineStyle', '--', 'LineWidth', 1, ...
    'Color', rgbcolor('orange'));
vline(ax1, e_sorted', 'LineStyle', '--', 'LineWidth', 1, ...
    'Color', rgbcolor('blue'));
hold off
grid on


ax2 = subplot(2,1,2);
ylim([1 size(b_out,1)])
hold on
for ii = 1:size(b_out,1)
    plot([b_out(ii) e_out(ii)], [ii ii], 'k', 'LineWidth', 1);
end
vline(ax2, b_out', 'LineStyle', '--', 'LineWidth', 1, ...
    'Color', rgbcolor('orange'));
vline(ax2, e_out', 'LineStyle', '--', 'LineWidth', 1, ...
    'Color', rgbcolor('blue'));
hold off
grid on
end