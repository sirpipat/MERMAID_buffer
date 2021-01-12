function s = eventcatalog(fname, plt)
% s = EVENTCATALOG(fname)
% Reads the event catalog and plots distributions of earthquake magnitudes 
% and epicentral distances
%
% INPUT:
% fname     full filename containing events
% plt       whether to plot or not
%
% OUTPUT:
% s         struct with the following fields
%           1.  arrivals        actual arrival times
%           2.  tags            tags
%           3.  stlos           station longitudes
%           4.  stlas           station latitudes
%           5.  evlos           event longitudes
%           6.  evlas           event latitudes
%           7.  depths          event depths
%           8.  magtypes        preferred magnitude types
%           9.  mags            magnitudes
%           10. dists           distances
%           11. phases          phases
%           12. origins         event origin times
%           13. exparrivals     expected arrival times
%           14. traveltimes     travel times
%           15. diffs           difference
%           16. ids             PublicId
%
% SEE ALSO:
% MATCHEVENTS
% 
% Last modified by Sirawich Pipatprathanporn: 01/12/2021

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

arrivals = datetime(words(:,1), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
tags = words(:,2);
stlos = str2double(words(:,3));
stlas = str2double(words(:,4));
evlos = str2double(words(:,5));
evlas = str2double(words(:,6));
depths = str2double(words(:,7));
magtypes = words(:,8);
mags = str2double(words(:,9));
dists = str2double(words(:,10));
phases = words(:,11);
origins = datetime(words(:,12), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
exparrivals = datetime(words(:,13), 'InputFormat', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC', ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
traveltimes = duration(words(:,14));
diffs = duration(words(:,15));
ids = words(:,16);

s.tags = tags;
s.stlos = stlos;
s.stlas = stlas;
s.evlos = evlos;
s.evlas = evlas;
s.depths = depths;
s.magtypes = magtypes;
s.mags = mags;
s.dists = dists;
s.phases = phases;
s.origins = origins;
s.exparrivals = exparrivals;
s.traveltimes = traveltimes;
s.diffs = diffs;
s.ids = ids;

if plt
    tags = strcell(words(:,2));
    where = (sum(tags == 'DET', 2) == 3);
    
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
    xlabel('epicentral distance (degree)');
    ylabel('magnitude');
    ax1.XLim = [0 180];
    ax1.YLim = [4.5 8.7];
    ax1.Box = 'on';
    ax1.TickDir = 'both';
    grid on
    legend([p_detect p_not_detect], 'automatically reported by MERMAID', ...
        'found manually in the buffer');

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
    figdisp(strcat(mfilename, '.eps'), [], [], 2, [], 'epstopdf');
end
end