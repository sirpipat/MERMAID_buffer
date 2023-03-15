function [s, a, evs] = eventcatalog(fname, plt)
% [s, a, evs] = EVENTCATALOG(fname, plt)
% Reads the event catalog and plots distributions of earthquake magnitudes 
% and epicentral distances
%
% INPUT:
% fname     full filename containing events
% plt       whether to plot or not
%
% OUTPUT:
% s         struct with the following fields
%           1.  arrival         actual arrival time
%           2.  tag             tag
%           3.  stlo            station longitude
%           4.  stla            station latitude
%           5.  evlo            event longitude
%           6.  evla            event latitude
%           7.  depth           event depth
%           8.  magtype         preferred magnitude type
%           9.  mag             magnitude
%           10. dist            distance
%           11. phase           phase
%           12. origin          event origin time
%           13. exparrival      expected arrival time
%           14. traveltime      travel time
%           15. diff            difference
%           16. id              PublicId
% a         arriaval times
% evs       event lists: a struct with the following fields
%               PreferredTime
%               PreferredLatitude
%               PreferredLongitude
%               PreferredDepth
%               PreferredMagnitudeType
%               PreferredMagnitudeValue
%               Phase
%               travelTime
%               expArrivalTime
%               diff
%               stlo
%               stla
%               evlo
%               evla
%               distance
%               id
%           which is compatible for PLOTEVENT
%
% SEE ALSO:
% MATCHEVENTS, FINDEVENT, PLOTEVENT
% 
% Last modified by Sirawich Pipatprathanporn: 04/11/2022

defval('fname', ...
    '/Users/sirawich/research/processed_data/events/catalog_events.txt');
defval('plt', false)

% read the catalog file
fid = fopen(fname);
txt = fscanf(fid, '%c');
fclose(fid);

words = split(txt);
words = words(1:end-1);
words = reshape(words, 16, size(words, 1) / 16)';

a = datetime(words(:,1), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');

arrivals = num2cell(a);
tags = words(:,2);
stlos = num2cell(str2double(words(:,3)));
stlas = num2cell(str2double(words(:,4)));
evlos = num2cell(str2double(words(:,5)));
evlas = num2cell(str2double(words(:,6)));
depths = num2cell(str2double(words(:,7)));
magtypes = words(:,8);
mags = num2cell(str2double(words(:,9)));
dists = num2cell(str2double(words(:,10)));
phases = words(:,11);
origins = num2cell(datetime(words(:,12), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS'));
exparrivals = num2cell(datetime(words(:,13), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS'));
traveltimes = num2cell(duration(words(:,14)));
diffs = num2cell(duration(words(:,15)));
ids = words(:,16);

% convert to struct (s)
s = struct('arrival', arrivals, 'tag', tags, 'stlo', stlos, ...
           'stla', stlas, 'evlo', evlos, 'evla', evlas, ...
           'depth', depths, 'magtype', magtypes, 'mag', mags, ...
           'dist', dists, 'phase', phases, 'origin', origins, ...
           'exparrival', exparrivals, 'traveltime', traveltimes, ...
           'diff', diffs, 'id', ids);
% convert to struct (evs)
evs = struct('PreferredTime', cellstr(string(origins)), ...
             'PreferredLatitude', evlas, ...
             'PreferredLongitude', evlos, ...
             'PreferredDepth', depths, ...
             'PreferredMagnitudeType', magtypes, ...
             'PreferredMagnitudeValue', mags, ...
             'phase', num2cell(phases), ...
             'travelTime', num2cell(seconds(duration(words(:,14)))), ...
             'expArrivalTime', exparrivals, ...
             'diff', diffs, ...
             'stlo', stlos, 'stla', stlas, ...
             'evlo', evlos, 'evla', evlas, ...
             'distance', dists, ...
             'id', ids);

if plt
    tags = strcell(words(:,2));
    mags = str2double(words(:,9));
    dists = str2double(words(:,10));
    where = (sum(tags == 'DET', 2) == 3);
    where3 = (sum(tags == '***', 2) == 3);
    
    % plot
    figure(2)
    clf
    set(gcf, 'Unit', 'inches', 'Position', [2 2 6.5 6]);

    % title
    ax0 = subplot('Position', [0.1 0.95 0.8 0.01]);
    title(sprintf('Catalog MERMAID P023: %d events', size(words,1)));
    set(ax0, 'FontSize', 12, 'Color', 'none');
    ax0.XAxis.Visible = 'off';
    ax0.YAxis.Visible = 'off';

    ax1 = subplot('Position', [0.1 0.1 0.6 0.6]);
    p_not_detect = scatter(dists(~where), mags(~where), 20, 'Marker', 'o', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', rgbcolor('deep sky blue'));
    hold on
    p_detect = scatter(dists(where), mags(where), 80, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.95 .95 0.1]);
    p_3 = scatter(dists(where3), mags(where3), 50, 'Marker', '^', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', [.95 .1 0.1]);
    xlabel('epicentral distance (degree)');
    ylabel('magnitude');
    ax1.XLim = [0 180];
    ax1.YLim = [4.5 8.7];
    ax1.Box = 'on';
    ax1.TickDir = 'both';
    grid on
    legend([p_detect p_not_detect, p_3], 'automatically reported by MERMAID', ...
        'found manually in the buffer', '3 stars');

    ax2 = subplot('Position', [0.75 0.1 0.2 0.6]);
    histogram(mags, 'BinEdges', 4.45:0.1:8.05, 'Orientation', 'horizontal', ...
        'FaceColor', 'k');
    xlabel('counts');
    ax2.YLim = ax1.YLim;
    ax2.TickDir = 'both';
    nolabels(ax2, 2);
    grid on

    ax3 = subplot('Position', [0.1 0.75 0.6 0.2]);
    histogram(dists, 'BinWidth', 5, 'FaceColor', 'k');
    ylabel('counts');
    ax3.XLim = ax1.XLim;
    ax3.TickDir = 'both';
    nolabels(ax3, 1);
    grid on

    % save figure
    set(gcf, 'Renderer', 'painters')
    figdisp(strcat(mfilename, '.eps'), [], [], 2, [], 'epstopdf');
end
end