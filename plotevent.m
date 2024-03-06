function plotevent(arrival, arrival_type, event, endtime, fs)
% PLOTEVENT(arrival, arrival_type, event, endtime, fs)
% display phase arrivals on a seismogram of filtered buffer 0.05-0.1 Hz
% accompanied with spectrograms, source-reveiver map (with beachball 
% diagram if possible) and ray paths on a cross-section of Earth.
%
% INPUT
% arrival       arrival datetime
% arrival_type  either 'body' or 'surface' [default: 'body']
% event         an event struct returned from FINDEVENTS
% endtime       ending datetime for the plot
% fs            sampling rate of the raw buffer [default: 40.01406 Hz]
%
% OUTPUT
% No output except an output file is saved as $EPS.
%
% SEE ALSO
% FINDEVENTS
%
% Last modified by Sirawich Pipatprathanporn: 03/06/2024

defval('endtime', [])
defval('fs', 40.01406)

% deduce the arrival type from event
surface_travel_time = seconds(arrival - datetime(event.PreferredTime, ...
    'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC'));
if isempty(arrival_type) && and(event.distance/180 * pi * 6371 / 5 < ...
        surface_travel_time, ...
        event.distance/180 * pi * 6371 / 3 > surface_travel_time)
    arrival_type = 'surface';
else
    arrival_type = 'body';
end

%% read seismogram
if strcmp(arrival_type, 'surface')
    arrival = event.expArrivalTime(1);
end
if isempty(endtime)
    last_minute = event.distance/180 * pi * 6371 / 1.0 / 60;
else
    last_minute = minutes(endtime - arrival) + 60;
end

dt_origin = datetime(event.PreferredTime,...
   'TimeZone','UTC','Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS');

% get the proper begin time
% pick a section containing both origin time and arrival time if possible
% if not, pick a section containing the arrival time
% Note 2/fs is subtracted to guarantee 00:00:00 label
[sections, intervals] = getsections(getenv('ONEYEAR'), ...
                                    dt_origin - seconds(2/fs) , ...
                                    arrival + minutes(last_minute), ...
                                    fs);
% determine the proper section
proper_section_no = 1;
while and(arrival > intervals{proper_section_no}{2}, ...
          proper_section_no < length(sections))
    proper_section_no = proper_section_no + 1;
end
% read the section
% adjust the beginning datetime if the section is too short
offset = (arrival + minutes(last_minute)) - intervals{proper_section_no}{2};
[x, dt_B, dt_E] = readsection(sections{proper_section_no}, ...
                              intervals{proper_section_no}{1} - offset, ...
                              intervals{proper_section_no}{2}, ...
                              fs);

% bandpass 0.05-0.10 Hz
d_factor = 5;
xd = detrend(decimate(detrend(x,1), d_factor),1);
xf2 = bandpass(xd, fs/d_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');

%% plot title
figure(2)
set(gcf, 'Unit', 'inches', 'Position', [0 8 6.5 7.5]);
clf

% plot title
ax0 = subplot('Position',[0.05 0.9 0.9 0.05]);
ax0.Title.String = sprintf('Arrival: %s, ID: %s', string(arrival), event.id);
ax0.Title.FontWeight = 'normal';
text(0.2,0.9,sprintf('%3s = %4.2f, distance = %6.2f degrees, depth = %6.2f km',...
     event.PreferredMagnitudeType, event.PreferredMagnitudeValue, ...
     event.distance, event.PreferredDepth));
[~,dt_start,dt_end] = readOneYearData(sections{1}, fs);
p = [(dt_B - dt_start) (dt_E - dt_start)] / (dt_end - dt_start) * 100;
text(0.4, 0.5, sprintf('%2.2f - %3.2f percent', p(1), p(2)));
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';
 
%% plot spectrogram
ax1 = subplot('Position', [0.08 0.60 0.87 0.22]);

nfft = round(fs * 100);
lwin = nfft;
b = timspecplot_ns(x,nfft,fs,lwin,0.7,0,'s');
title('');
colormap(jet(256));

% insert colorbar
c = colorbar('NorthOutside');
c.Label.String = 'spectral density (energy/Hz)';
c.Position = [0.0800 0.8359 0.8700 0.0178];
c.TickDirection = 'both';

% fix the precision of the time on XAxis label
ax1.XAxis.Label.String = sprintf('time since origin (hh:mm): %d s window', round(nfft/fs));
ax1.XAxis.Label.String = '';

% add subplot label
ax1b = addbox(ax1, [0 0.85 0.04 0.15]);
[x_pos, y_pos] = norm2trueposition(ax1b, 0.28, 3/5);
text(x_pos, y_pos, 'a', 'FontSize', 12);

%% plot filtered seismogram 0.05-0.1 Hz
ax2 = subplot('Position', [0.08 0.37 0.87 0.14], 'Box', 'on');
% time since origin
dur_B = dt_B - dt_origin;
ax2 = signalplot(xf2, fs/d_factor, dur_B, ax2, '', 'left');
% Don't use datetick for duration variable. Use string instead.
%datetick('x', 15, 'keeplimits', 'keepticks');
ax2.XTickLabel = string(ax2.XTick, 'hh:mm');
ax2.XAxis.Label.String = 'time since origin (hh:mm)';

% add label on the top and right
ax1.TickDir = 'both';
ax1.XLim = seconds(ax2.XLim - dur_B);
ax1.XTick = seconds(ax2.XTick - dur_B);
ax1.XTick = ax1.XTick(ax1.XTick > seconds(0));
ax1.XTickLabel = ax2.XTickLabel;
ax1s = doubleaxes(ax1);
ax1s.XTickLabel = [];
axes(ax1b)

axes(ax2)

% add moving average
mov_mean = movmean(xf2, round(fs/d_factor * 150));
t_plot = dur_B + seconds((0:length(xf2)-1) / (fs/d_factor));
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off

% add moving rms
xf2_sq = xf2 .^ 2;
mov_rms = movmean(xf2_sq, round(fs/d_factor * 150)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off

% set ylimit to exclude outliers
r = rms(xf2);
ylim([-6*r 6*r]);

% add title
tt = title('Filtered: dc5 dt bp0.05-0.1 -- green = mov avg, red = mov rms, window = 150 s', ...
    'FontWeight', 'normal');
tt.Position(2) = ax2.YLim(2) * 1.15;
%title('')
ylabel('counts')
ax2.TitleFontSizeMultiplier = 1.0;
ax2.Title.FontWeight = 'normal';
ax2.TickDir = 'both';

% add expected arrival for each phase
vline(ax2, event.expArrivalTime - dt_origin, 'LineStyle', '-', ...
    'LineWidth', 1, 'Color', rgbcolor('deep sky blue'));
ynorm = 0.9;
t_curr = dur_B;
for ii = 1:size(event.expArrivalTime,2)
    if ii == 1 || (event.expArrivalTime(ii) - dt_origin - t_curr > 1/8 * ...
            (ax2.XLim(2) - ax2.XLim(1)))
        ynorm = 0.9;
    else
        if ynorm == 0.9
            ynorm = 0.15;
        else
            ynorm = 0.9;
        end
    end
    [~,y] = norm2trueposition(ax2,0,ynorm);
    t_curr = event.expArrivalTime(ii) - dt_origin;
    text(t_curr+seconds(60), y, event.phase{ii}, ...
        'Color', rgbcolor('deep sky blue'));
end

% add surface wave arrival
R_speed = [5 4 3 1.5];
R_arrival = seconds(event.distance/180 * pi * 6371 ./ R_speed);
vline(ax2, R_arrival(1:3), 'LineStyle', '-', 'LineWidth', 1, ...
    'Color', rgbcolor('orange'));
vline(ax2, R_arrival(4), 'LineStyle', '-', 'LineWidth', 1, ...
    'Color', rgbcolor('hot pink'));
for ii = 1:size(R_arrival,2)
    if (R_arrival(ii) - t_curr > 1/8 * (ax2.XLim(2) - ax2.XLim(1)))
        ynorm = 0.9;
    else
        if ynorm == 0.9
            ynorm = 0.15;
        else
            ynorm = 0.9;
        end
    end
    [~,y] = norm2trueposition(ax2,0,ynorm);
    if ii <= 3
        text(R_arrival(ii) + seconds(60), y, sprintf('%3.1f km/s', ...
            R_speed(ii)), 'Color', rgbcolor('orange'));
    else
        text(R_arrival(ii) + seconds(60), y, sprintf('%3.1f km/s', ...
            R_speed(ii)), 'Color', rgbcolor('hot pink'));
    end
    t_curr = R_arrival(ii);
end

% move the vertical lines to the back
ax2.Children = ax2.Children([1 2 3 4 9 11 12 13 5 6 7 8 10]);

% add subplot label
ax2b = addbox(ax2, [0 0.75 0.04 0.25]);
[x_pos, y_pos] = norm2trueposition(ax2b, 0.28, 3/5);
text(x_pos, y_pos, 'b', 'FontSize', 12);

%% plot map with event focal mechanism and MERMAIDS
ax3 = subplot('Position', [0.08 0.04 0.61 0.25]);
% plot tcoastlines
[axlim,handl,XYZ] = plotcont([0 90], [360 -90], 1, 0);
% plot plate boundaries
[handlp, XYp] = plotplates([0 90], [360 -90], 1);
handlp.Color = 'r';

% zoom in the map
lonmin = min(mod([150, event.evlo-10, event.stlo-10], 360));
lonmax = max(mod([240, event.evlo+10, event.stlo+10], 360));
latmin = min([-40, event.evla-5, event.stla-5]);
latmax = max([10, event.evla+5, event.stla+5]);
original_x2y_ratio = (ax3.XLim(2)-ax3.XLim(1))/(ax3.YLim(2)-ax3.YLim(1));
new_x2y_ratio = (lonmax-lonmin)/(latmax-latmin);
if new_x2y_ratio > original_x2y_ratio
    latmid = (latmin + latmax) / 2;
    latmin = latmid - (lonmax - lonmin) / original_x2y_ratio / 2;
    latmax = latmid + (lonmax - lonmin) / original_x2y_ratio / 2;
else
    lonmid = (lonmin + lonmax) / 2;
    lonmin = lonmid - (latmax - latmin) * original_x2y_ratio / 2;
    lonmax = lonmid + (latmax - latmin) * original_x2y_ratio / 2;
end
ax3.XLim = [lonmin lonmax];
ax3.YLim = [latmin latmax];

% add stations
[allvitfiles,vndex] = allfile('/Users/sirawich/research/raw_data/metadata/vit/');
mpos = NaN(0,2);
station_numbers = cell(0,1);
for ii = 1:vndex
    station_name = removepath(allvitfiles{ii});
    station_numbers{ii,1} = station_name(3:4);
    [mpos(ii,1),mpos(ii,2)] = mposition(dt_B, allvitfiles{ii});
end
% remove NaN data points
station_numbers = station_numbers(~isnan(mpos(:,1)));
mpos = mpos(~isnan(mpos(:,1)),:);

% draw paths from event to stations
plottrack(ax3, [event.evlo event.evla], [event.stlo event.stla], 0, ...
          100, 'LineWidth', 0.5, 'Color', [0 0.5 0.9]);
% color stations to green if they report the event
all_filename = '/Users/sirawich/research/processed_data/events/all.txt';
opts = detectImportOptions(all_filename);
T = readtable(all_filename, opts);
sacfiles = T.Var1;
PublicID = T.Var11;
sacfiles = sacfiles(PublicID == str2num(event.id));
if isempty(sacfiles)
    active_index = [];
else
    splitted_filenames = split(sacfiles, '.');
    if size(sacfiles,1) == 1
        splitted_filenames = splitted_filenames';
    end
    tags = splitted_filenames(:,4);
    tags = strcell(tags);
    where = (sum(tags == 'DET', 2) == 3);
    station_no = split(splitted_filenames(:,2), '_');
    station_no = station_no(:,1);
    station_no = station_no(where);
    [~, active_index, ~] = intersect(station_numbers, station_no);
end

for ii = 1:size(mpos,1)
    if any(active_index == ii)
        color = [0.5 0.9 0.2];
    else
        color = rgbcolor('gray');
    end
    scatter(ax3, mod(mpos(ii,1),360), mpos(ii,2), 20, 'Marker', 'v', ...
            'MarkerEdgeColor', rgbcolor('k'), ...
            'MarkerEdgeAlpha', 0.5, ...
            'MarkerFaceColor', color, ...
            'MarkerFaceAlpha', 0.5);
end

scatter(ax3, mod(event.stlo,360), event.stla, 60, 'Marker', 'v', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');

% add event (beach ball)
filelist = {'sep18.ndk', 'oct18.ndk', 'nov18.ndk', 'dec18.ndk', ...
            'jan19.ndk', 'feb19.ndk', 'mar19.ndk', 'apr19.ndk', ...
            'may19.ndk', 'jun19.ndk', 'jul19.ndk', 'aug19.ndk'};
fname = filelist{(dt_origin.Month - 8) + (dt_origin.Year - 2018) * 12};
tbeg = datenum(dt_origin - minutes(1));
tend = datenum(dt_origin + minutes(1));
mblo = event.PreferredMagnitudeValue - 0.5;
mbhi = event.PreferredMagnitudeValue + 0.5;
depmin = event.PreferredDepth - 50;
depmax = event.PreferredDepth + 50;

% get the moment tensor
[quake,Mw] = readCMT(fname, strcat(getenv('IFILES'),'CMT'), tbeg, tend, ...
    mblo, mbhi, depmin, depmax, 'centroid');
if size(Mw,1) > 1
    fprintf('size(Mw,1) > 1\n');
end
% check hypocetner moment tensor if readCMT did not return anything
if isempty(Mw)
    [quake, Mw] = readCMT(fname, strcat(getenv('IFILES'),'CMT'), tbeg, ...
        tend, mblo, mbhi, depmin, depmax, 'hypocenter');
end

% draw moment tensor (beachball)
if ~isempty(quake) && size(Mw,1) == 1
    M = quake(5:end);
    r = (ax3.XLim(2) - ax3.XLim(1)) / 18;   % radius of the beachball
    focalmech(ax3, M, mod(event.evlo,360), event.evla, r, 'b');
else
    scatter(ax3, mod(event.evlo,360), event.evla, 100, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
end

grid on

% ticks label
ax3.XTick = 0:30:360;
ax3.XTickLabel = {'0', '30', '60', '90', '120', '150', '180', '-150', ...
                  '-120', '-90', '-60', '-30', '0'};
ax3.YTick = -90:15:90;
ax3.YTickLabel = {'-90', '-75', '-60', '-45', '-30', '-15', '0', '15', ...
                  '30', '45', '60', '75', '90'};
ax3.TickDir = 'both';
ax3s = doubleaxes(ax3);
ax3s.TickDir = 'both';
ax3s.XTickLabel = [];

% add box
ax3.Box = 'on';

% add subplot label
ax3b = addbox(ax3, [0 0.85 0.06 0.15]);
[x_pos, y_pos] = norm2trueposition(ax3b, 0.28, 3/5);
text(x_pos, y_pos, 'c', 'FontSize', 12);

%% plot ray paths on an Earth cross-section
ax4 = subplot('Position', [0.77 0.04 0.20 0.25]);
% plot map
taupPlotRayPath(ax4, 'ak135', max(0, event.PreferredDepth), ...
    'P,Pdiff,PKIKP', 'evt', [event.evla event.evlo], ...
    'sta', [event.stla event.stlo]);
ax4.YLim = [-2 1.5] * 6371;

% add subplot label
ax4b = addbox(ax4, [0 0.86 0.18 0.14]);
[x_pos, y_pos] = norm2trueposition(ax4b, 0.28, 3/5);
text(x_pos, y_pos, 'd', 'FontSize', 12);

%% save figure
set(gcf, 'Renderer', 'painters')
savename = sprintf('%s_%s_%s_M%4.2f.eps', mfilename, ...
                   replace(string(arrival), ':', '_'), event.id, ...
                   event.PreferredMagnitudeValue);
figdisp(savename, [], [], 2, [], 'epstopdf');
end