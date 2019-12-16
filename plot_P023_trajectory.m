function plot_P023_trajectory
% NO INPUT
%
% plot P023 trajectory during 13 Sep 2018 to 15 Aug 2019
%
% Last edited by Sirawich Pipatprathanporn, 11/25/2019

    T = readtable('/home/sirawich/research/raw_data/metadata/P023_all.txt');
    T.Properties.VariableNames = {'Station', ...
                                  'Date', ...
                                  'Time', ...
                                  'stla', ...
                                  'stlo', ...
                                  'HDil', ...
                                  'VDil', ...
                                  'VBat', ...
                                  'Vmin', ...
                                  'PInt', ...
                                  'PExt', ...
                                  'PRange', ...
                                  'NumCommand', ...
                                  'NumQueued', ...
                                  'NumUploaded'};
    
    [C, ia] = unique(T.Date);
    TC = T(ia,:);

    c_str = string(C);

    % plot a small map, showing the trajectory
    ax1 = subplot(3, 1, 1);
    ax1.DataAspectRatio = [1 1 1];
    plot(TC.stlo(4:49),TC.stla(4:49),'.-k');
    text(TC.stlo(4)-0.2,TC.stla(4)-0.06,c_str(4,:));
    % text(TC.stlo(27)-0.2,TC.stla(27)-0.03,c_str(27,:));
    text(TC.stlo(49)+0.05,TC.stla(49)-0.01,c_str(49,:));
    ylabel('latitude (degrees)');
    title('Trajectory');
    xlabel('longitude (degrees)');
    grid on;
    
    % plot the big map, showing the surrounding continents
    ax2 = subplot(3, 1, [2, 3]);
    % plot tcoastlines
    [axlim,handl,XYZ] = plotcont([140 30], [280 -55], 1, 0);
    % plot plate boundaries
    [handlp, XYp] = plotplates([140 30], [280 -55], 1);
    handlp.Color = 'r';
    % plot frame of the trajectory map
    plot([-144 -140.5 -140.5 -144 -144] + 360, ...
        [-23.8 -23.8 -24.4 -24.4 -23.8], 'b');
    % label of places
    text(142, -28, 'Australia');
    text(178, -40, 'New Zealand');
    text(198, 17, 'Hawaii');
    text(240, 10, 'North America');

    grid on;
    xlim([140 280]);
    xticklabels({'140', '160', '180', '-160', '-140', '-120', '-100', ...
                '-80'});
    ylabel('latitude (degrees)');
    xlabel('longitude (degrees)');
end