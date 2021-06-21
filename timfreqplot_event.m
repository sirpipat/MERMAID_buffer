function fig = timfreqplot_event(ev, dt_begin)
% fig = TIMFREQPLOT_EVENT(ev, dt_begin)
%
% plot seismogram, power spectral density, spectograms, and filtered
% seismogram but the time is from the origin time of an event
%
% INPUT
% ev            event
% dt_begin      begining datetime of a section to plot
%
% OUTPUT
% fig           figure handling the plots
% 
% SEE ALSO
% TIMFREQPLOT
%
% Last modified by Sirawich Pipatprathanporn, 06/22/2021

% reference spectral density files
SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles_before_conversion/';
[allSDs,dndex] = allfile(SDdir);

% input parameters for timfreqplot
fs = 40.01406;
nfft = round(100 * fs);
lwin = nfft;
olap = 70;
sfax = 10;
beg = 0;
unit = 's';
p = [];

% read the neccessary part of the buffer
% Note 2/fs is subtracted to guarantee 00:00:00 label
[sections, intervals] = getsections(getenv('ONEYEAR'), dt_begin - seconds(2/fs), dt_begin + hours(1), fs);
[y, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, intervals{1}{2}, fs);

% plot the spectrogram, power spectral density plot, and seismograms
fig = timfreqplot(y, [], [], [], [], dt_begin, nfft, fs, lwin, olap, ...
    sfax, beg, unit, p, false, false);

% make time axis relative to the origin time
dt_origin = datetime(ev.PreferredTime, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
time_labels = string(duration((0:5) * minutes(15), 'Format', 'hh:mm'));
% make time axis relative to the origin time for seismograms
fig.Children(2).XTick = dt_origin + (0:5) * minutes(15);
fig.Children(4).XTick = dt_origin + (0:5) * minutes(15);
fig.Children(6).XTick = dt_origin + (0:5) * minutes(15);
fig.Children(2).XTickLabel = time_labels;
fig.Children(2).XLabel.String = 'time since origin (hh:mm)';
% make time axis relative to the origin time for spectrogram
seconds_since_origin = seconds(dt_origin + (0:5) * minutes(15) - dt_begin);
fig.Children(12).XLim = seconds(fig.Children(2).XLim - dt_origin);
fig.Children(12).XTick = seconds_since_origin;
fig.Children(12).XTickLabel = time_labels;
fig.Children(12).XLabel.String = 'time since origin (hh:mm): 100 s window';
fig.Children(13).XLim = seconds(fig.Children(2).XLim - dt_origin);
fig.Children(13).XTick = seconds_since_origin;
fig.Children(13).XTickLabel = time_labels;
% remove unneccessary titles
%fig.Children(1).Title.String = '';
%fig.Children(2).Title.String = '';
%fig.Children(3).Title.String = '';
% add the expected arrival time
% TODO?

% read spectral density refernce data
% September 2018 --> 1, August 2019 --> 12
index = (dt_begin.Year - 2018) * 12 + dt_begin.Month - 8;
fid = fopen(allSDs{index},'r');
data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
fclose(fid);
% add reference spectral density of the month
ax = fig.Children(8);
axes(ax)
hold on
semilogx(data(1,:),data(2,:),'Color',rgbcolor('deep sky blue'));
semilogx(data(1,:),data(4,:),'Color',rgbcolor('gray'));
semilogx(data(1,:),data(5,:),'Color',rgbcolor('gray'));
hold off

% save figure
filename = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
figdisp(filename,[],[],2,[],'epstopdf');
end