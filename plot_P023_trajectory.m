function plot_P023_trajectory
% NO INPUT
%
% plot P023 trajectory during 13 Sep 2018 to 15 Aug 2019
%
% Last edited by Sirawich Pipatprathanporn, 11/10/2020
    T = readvit('/Users/sirawich/research/raw_data/metadata/vit/P023_all.txt');
    
    [C, ia] = unique(T.Date);
    TC = T(ia,:);

    C.Format = 'dd-MMM-uuuu';
    c_str = string(C);

    figure
    clf
    % plot a small map, showing the trajectory
    ax1 = subplot('Position',[0.14 0.77 0.76 0.18]);
    ax1.DataAspectRatio = [1 1 1];
    plot(TC.stlo(1:46),TC.stla(1:46),'.-k');
    text(TC.stlo(1)-0.2,TC.stla(1)-0.06,c_str(1,:), 'FontSize', 13);
    % text(TC.stlo(27)-0.2,TC.stla(27)-0.03,c_str(27,:), 'FontSize', 13);
    text(TC.stlo(46)+0.05,TC.stla(46)-0.01,c_str(46,:), 'FontSize', 13);
    ylabel('latitude (degrees)');
    % title('Trajectory');
    xlabel('longitude (degrees)');
    grid on;
    ylim([-24.45 -23.75]); 
    % add box
    set(gca, 'TickDir', 'both', 'Box', 'on', 'FontSize', 13);
    
    % add second axes
    doubleaxes(ax1);
    
    % plot the big map, showing the surrounding continents
    ax2 = subplot('Position',[0.14 0.11 0.76 0.50]);
    % plot tcoastlines
    [axlim,handl,XYZ] = plotcont([140 30], [280 -55], 1, 0);
    % plot plate boundaries
    [handlp, XYp] = plotplates([140 30], [280 -55], 1);
    handlp.Color = 'r';
    % plot frame of the trajectory map
    plot([-144 -140.5 -140.5 -144 -144] + 360, ...
        [-23.8 -23.8 -24.4 -24.4 -23.8], 'b');
    % label of places
    text(142, -28, 'Australia', 'FontSize', 13);
    text(178, -40, 'New Zealand', 'FontSize', 13);
    text(198, 17, 'Hawaii', 'FontSize', 13);
    text(240, 10, 'North America', 'FontSize', 13);
    text(210, -15, 'Tahiti', 'FontSize', 13);

    grid on;
    xlim([140 280]);
    xticklabels({'140', '160', '180', '-160', '-140', '-120', '-100', ...
                '-80'});
    ylabel('latitude (degrees)');
    xlabel('longitude (degrees)');
    
    % add box
    set(gca, 'TickDir', 'both', 'Box', 'on', 'FontSize', 13);
    
    % add second axes
    doubleaxes(ax2);
    
    % save the figure
    figdisp('P023_trajectory.eps', [], [], 2, [], 'epstopdf');
end