function rgbcolordemo(arg)
% RGBCOLORDEMO
%
% RGBCOLORDEMO displays all RGB color combinations where each 
% red/green/blue value is either 0, 0.5, or 1.
%
% RGBCOLORDEMO('more') displays all RGB color combinations where each 
% red/green/blue value is either 0, 0.2, 0.4, 0.6, 0.8, or 1.
%
% SEE ALSO:
% RGBCOLOR
%
% Last modified by sirawich-at-princeton.edu: 04/11/2023

defval('arg', 'less')
orders = [1 2 3; 2 3 1; 3 1 2];
colors = {'red', 'green', 'blue'};
cmap = [0.9 0.15 0.15; 0.15 0.6 0.15; 0 0 0.7];
for cc = 1:3
    figure(cc)
    if strcmpi(arg, 'less')
        set(gcf, 'Units', 'inches', 'Position', [1 1 12 5])
        clf
        ax = subplot('Position', [0.08 0.12 0.84 0.8]);
        hold on
        for rr = 0:0.5:1
            for gg = 0:0.5:1
                for bb = 0:0.5:1
                    rgb = [rr gg bb];
                    ii = rgb(orders(cc, 1));
                    jj = rgb(orders(cc, 2));
                    kk = rgb(orders(cc, 3));
                    pgon = polyshape([-1 1 1 -1] / 4 + ii + 4 * kk, ...
                        [-1 -1 1 1] / 4 + jj);
                    plot(pgon, 'FaceColor', rgb, 'FaceAlpha', 1);
                end
            end
        end
        grid on
        xticks(reshape([0 0.5 1]' + [0 2 4], [1 9]))
        xticklabels(repmat(0:0.5:1, [1 3]))
        xlabel(colors{orders(cc, 1)})
        yticks([0 0.5 1])
        ylabel(colors{orders(cc, 2)})
        xlim([-0.5 5.5])

        text(-0.1, 1.35, [colors{orders(cc, 3)} ' = 0'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(1.9, 1.35, [colors{orders(cc, 3)} ' = 0.5'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(3.9, 1.35, [colors{orders(cc, 3)} ' = 1'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
    else
        set(gcf, 'Units', 'inches', 'Position', [1 1 12 10])
        clf
        ax = subplot('Position', [0.08 0.12 0.84 0.8]);
        hold on
        for rr = 0:0.2:1
            for gg = 0:0.2:1
                for bb = 0:0.2:1
                    rgb = [rr gg bb];
                    ii = rgb(orders(cc, 1));
                    jj = rgb(orders(cc, 2));
                    kk = rgb(orders(cc, 3));
                    
                    index = kk * 5;
                    xx = floor(index / 3);
                    yy = mod(index, 3);
                    pgon = polyshape([-1 1 1 -1] / 10 + ii + 1.5 * yy, ...
                        [-1 -1 1 1] / 10 + jj - 1.5 * xx);
                    plot(pgon, 'FaceColor', rgb, 'FaceAlpha', 1);
                end
            end
        end
        grid on
        xticks(reshape((0:0.2:1)' + [0 1.5 3], [1 18]))
        xticklabels(repmat(0:0.2:1, [1 3]))
        xlabel(colors{orders(cc, 1)})
        yticks(reshape((0:0.2:1)' + [-1.5 0], [1 12]))
        yticklabels(repmat(0:0.2:1, [1 2]))
        ylabel(colors{orders(cc, 2)})
        xlim([-0.25 4.25])
        ylim([-1.75 1.25])

        text(-0.05, 1.15, [colors{orders(cc, 3)} ' = 0'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(1.45, 1.15, [colors{orders(cc, 3)} ' = 0.2'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(2.95, 1.15, [colors{orders(cc, 3)} ' = 0.4'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(-0.05, -0.35, [colors{orders(cc, 3)} ' = 0.6'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(1.45, -0.35, [colors{orders(cc, 3)} ' = 0.8'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
        text(2.95, -0.35, [colors{orders(cc, 3)} ' = 1'], ...
            'FontSize', 14, 'Color', cmap(orders(cc, 3), :))
    end
    set(gca, 'FontSize', 14, 'Box', 'on', 'TickDir', 'out', ...
        'DataAspectRatio', [1 1 1])

    ax.XAxis.Color = cmap(orders(cc, 1), :);
    ax.YAxis.Color = cmap(orders(cc, 2), :);

    ax2 = doubleaxes(ax);
    ax2.XAxis.Color = ax.XAxis.Color;
    ax2.YAxis.Color = ax.YAxis.Color;
    ax2.XLabel.String = ax.XLabel.String;
    ax2.YLabel.String = ax.YLabel.String;
    set(ax2, 'FontSize', 14, 'Box', 'on', 'TickDir', 'out', ...
        'DataAspectRatio', [1 1 1])

    set(gcf, 'Renderer', 'painters')

    savename = sprintf('%s%d.eps', mfilename, cc);
    figdisp(savename, [], [], 2, [], 'epstopdf');
end
end