function apparent_sampling_rate_histogram(direction)
% APPARENT_SAMPLING_RATE_HISTOGRAM(direction)
% plot histograms of apparent sampling rates
% assuming no gaps between the files
%
% INPUT:
% direction   0 - Using the filename as the start time  [Default]
%             1 - Using the filename as the end time
% OUTPUT:
% no output
%
% SEE ALSO:
% ONEYEARDATA, FILE2DATETIME, READ_FILESIZE
%
% Last modified by Sirawich Pipatprathanporn: 03/01/2020

defval('direction',0);

DUMMY_DATETIME = datetime(0,0,0,0,0,0,'TimeZone','UTC');

% read the begin datetimes
ddir = getenv('ONEYEAR');
[allfiles, fndex] = oneyeardata(ddir);
allbegins = [DUMMY_DATETIME];
for ii = 1:fndex
    allbegins(ii) = file2datetime(allfiles{ii});
end

% calcuate the duration of the file assuming no time gaps
alldurations = circshift(allbegins, -1, 2) - allbegins;
alldurations = seconds(alldurations(1:fndex-1));

% get file lengths in samples
[allfilelengths, fndex] = read_filesize();

% compute apparent sampling rate
if direction == 0
    apparent_rates = allfilelengths(1:fndex-1) ./ alldurations;
else
    apparent_rates = allfilelengths(2:fndex) ./ alldurations;
end

if direction == 0
    % plot histogram
    figure(11)
    ax = subplot(3,1,1);
    h = histogram(apparent_rates);
    h.BinWidth = 1;
    xlim([0,45]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 1 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    ax.Title.String = 'Histogram of apparent sampling rate [filename = begin time]';

    ax = subplot(3,1,2);
    h = histogram(apparent_rates);
    h.BinWidth = 0.5;
    xlim([30,42]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 0.5 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    %ax.Title.String = 'Histogram of apparent sampling rate [filename = begin time]';

    ax = subplot(3,1,3);
    h = histogram(apparent_rates);
    h.BinWidth = 0.001;
    xlim([40,40.01]);
    ylim([0,5]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 0.001 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    %ax.Title.String = 'Histogram of apparent sampling rate [filename = begin time]';
else
    % plot histogram
    figure(11)
    ax = subplot(3,1,1);
    h = histogram(apparent_rates);
    h.BinWidth = 1000;
    xlim([-1000,80000]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 1000 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    ax.Title.String = 'Histogram of apparent sampling rate [filename = end time]';

    ax = subplot(3,1,2);
    h = histogram(apparent_rates);
    h.BinWidth = 1000;
    xlim([0,80000]);
    ylim([0, 10]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 1000 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    %ax.Title.String = 'Histogram of apparent sampling rate [filename = begin time]';

    ax = subplot(3,1,3);
    h = histogram(apparent_rates);
    h.BinWidth = 10;
    xlim([0, 200]);
    grid on
    xlabel('Apparent sampling rate (Hz) [bin width = 10 Hz]');
    ylabel('Counts');
    ax.TickDir = 'both';
    %ax.Title.String = 'Histogram of apparent sampling rate [filename = begin time]';
end
end