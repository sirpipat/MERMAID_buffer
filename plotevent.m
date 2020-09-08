function plotevent(arrival, event, fs)
% PLOTEVENT(arrival, event, fs)
% display phase arrivals on a seismogram of filtered buffer 0.05-0.1 Hz
% accompanied with spectrograms, source-reveiver map (with beachball 
% diagram if possible) and ray paths on a cross-section of Earth.
%
% INPUT
% arrival       arrival datetime
% event         an event struct returned from FINDEVENTS
% fs            sampling rate of the raw buffer [default: 40.01406 Hz]
%
% OUTPUT
% No output except an output file is saved as $EPS.
%
% SEE ALSO
% FINDEVENTS
%
% Last modified by Sirawich Pipatprathanporn: 09/08/2020
defval('fs', 40.01406)

%% read seismogram
last_minute = event.distance/180 * pi * 6371 / 2.8 / 60;
[sections, intervals] = getsections(getenv('ONEYEAR'), ...
                                    arrival - minutes(5), ...
                                    arrival + minutes(last_minute), ...
                                    fs);
[x, dt_B, dt_E] = readsection(sections{1}, intervals{1}{1}, ...
                                    intervals{1}{2}, fs);
dt_origin = datetime(event.PreferredTime,...
   'TimeZone','UTC','Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS');

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
ax1 = subplot('Position', [0.09 0.58 0.86 0.22]);

nfft = round(fs * 100);
lwin = nfft;
b = timspecplot_ns(x,nfft,fs,lwin,0.7,0,'s');
title('');
colormap(jet(256));

% insert colorbar
c = colorbar('NorthOutside');
c.Label.String = 'spectral density (energy/Hz)';
c.Position = [0.0897 0.8359 0.8600 0.0178];
c.TickDirection = 'both';

% fix the precision of the time on XAxis label
ax1.XAxis.Label.String = sprintf('time (s): %d s window', round(nfft/fs));

%% plot filtered seismogram 0.05-0.1 Hz
ax2 = subplot('Position', [0.09 0.39 0.86 0.1]);
ax2 = signalplot(xf2, fs/d_factor, dt_B, ax2, '', 'left');
ax2.XLim = dt_B + seconds(ax1.XLim);

% add label on the top and right
ax1.TickDir = 'both';
ax1.XTick = seconds(ax2.XTick - dt_B);
ax1.XTickLabel = ax2.XTickLabel;
ax1s = doubleaxes(ax1);
axes(ax2)

% add moving average
mov_mean = movmean(xf2, round(fs/d_factor * 150));
t_plot = dt_B + seconds((0:length(xf2)-1) / (fs/d_factor));
hold on
plot(t_plot, mov_mean, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold off

% add moving rms
xf2_sq = xf2 .^ 2;
mov_rms = movmean(xf2_sq, round(fs/d_factor * 150)) .^ 0.5;
hold on
plot(t_plot, mov_rms, 'Color', [0.8 0.25 0.25], 'LineWidth', 1);
hold off
title('Filtered: dc5 dt bp0.05-0.1 -- green = mov avg, red = mov rms, win = 150 s')
ax2.TitleFontSizeMultiplier = 1.0;
ax2.TickDir = 'both';

% set ylimit to exclude outliers
r = rms(xf2);
ylim([-5*r 5*r]);

% add expected arrival for each phase
vline(ax2, event.expArrivalTime, '--', 1, rgbcolor('deep sky blue'));
ynorm = 0.9;
dt_curr = dt_B;
for ii = 1:size(event.expArrivalTime,2)
    if ii == 1 || (event.expArrivalTime(ii) - dt_curr > 1/8 * ...
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
    text(event.expArrivalTime(ii)+seconds(3),y,event.phase{ii});
    dt_curr = event.expArrivalTime(ii);
end

% add surface wave arrival
R_speed = [5 4 3];
R_arrival = dt_origin + seconds(event.distance/180 * pi * 6371 ./ R_speed);
vline(ax2, R_arrival, '--', 1, rgbcolor('orange'));
for ii = 1:size(R_arrival,2)
    if (R_arrival(ii) - dt_curr > 1/8 * (ax2.XLim(2) - ax2.XLim(1)))
        ynorm = 0.9;
    else
        if ynorm == 0.9
            ynorm = 0.15;
        else
            ynorm = 0.9;
        end
    end
    [~,y] = norm2trueposition(ax2,0,ynorm);
    text(R_arrival(ii)+seconds(3),y,sprintf('%3.1f km/s', R_speed(ii)));
    dt_curr = R_arrival(ii);
end

%% plot map with event focal mechanism and MERMAIDS
ax3 = subplot('Position', [0.09 0.04 0.60 0.25]);
% plot tcoastlines
[axlim,handl,XYZ] = plotcont([0 90], [360 -90], 1, 0);
% plot plate boundaries
[handlp, XYp] = plotplates([0 90], [360 -90], 1);
handlp.Color = 'r';
% add stations
[allvitfiles,vndex] = allfile('/Users/sirawich/research/raw_data/metadata/');
mpos = NaN(0,2);
for ii = 1:vndex
    [mpos(ii,1),mpos(ii,2)] = mposition(dt_B, allvitfiles{ii});
end
scatter(ax3, mod(mpos(:,1),360), mpos(:,2), 20, 'Marker', 'v', ...
        'MarkerEdgeColor', rgbcolor('k'), ...
        'MarkerEdgeAlpha', 0.5, ...
        'MarkerFaceColor', rgbcolor('gray'), ...
        'MarkerFaceAlpha', 0.5);
    
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
    mblo, mbhi, depmin, depmax);
if size(Mw,1) > 1
    fprintf('size(Mw,1) > 1\n');
end
% plot moment tensor
if ~isempty(quake) && size(Mw,1) == 1
    M = quake(5:end);
    focalmech(ax3, M, mod(event.evlo,360), event.evla, 15, 'b');
else
    scatter(ax3, mod(event.evlo,360), event.evla, 100, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
end

grid on

% ticks label
ax3.XTick = [0 60 120 180 240 300 360];
ax3.XTickLabel = {'0', '60', '120', '180', '-120', '-60', '0'};
ax3.YTick = [-90 -60 -30 0 30 60 90];
ax3.YTickLabel = {'-90', '-60', '-30', '0', '30', '60', '90'};
ax3.TickDir = 'both';
ax3s = doubleaxes(ax3);
ax3s.TickDir = 'both';

%% plot ray paths on an Earth cross-section
ax4 = subplot('Position', [0.77 0.04 0.20 0.25]);
% plot map
taupPlotRayPath(ax4, 'ak135', max(0, event.PreferredDepth), ...
    'P,PP,PcP,PKP,PKiKP,PKIKP,Pdiff', 'evt', [event.evla event.evlo], ...
    'sta', [event.stla event.stlo]);
ax4.YLim = [-2.5 1] * 6371;

%% save figure
savename = sprintf('%s_%s_%s_M%4.2f.eps', mfilename, ...
                   replace(string(arrival), ':', '_'), event.id, ...
                   event.PreferredMagnitudeValue);
figdisp(savename, [], [], 2, [], 'epstopdf');
end