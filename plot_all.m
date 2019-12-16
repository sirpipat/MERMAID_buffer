function plot_all(filename)
% plot seismogram, power spectral density, spectograms, and filtered
% seismogram

% parameter list
fs = 40;
s2d = 86400;
nfft = 1024;

% for specsdensplot
wlen = 1024;
wolap = 0.70;
beg = 0;

% for timspecplot_ns
lwin = 1024;
olap = 70;
sfax = 10;

% reads data
y = loadb(filename, 'int32', 'l');

% filters with f_c = [0.75 2] Hz
yf = bandpass(y, fs, 0.75, 2, 2, 2, 'butter', 'linear');

% calculates time for plotting variables in time-domain 
filename = erase(filename,'.hsc');
t_start = time(filename);
t = t_start + 1/fs/s2d * (1:length(y));

%%% plot raw signal
subplot(2, 2, 1);
plot(t, y);
grid on
xlim([min(t) max(t)]);
% add subplot label
text(datetime(2019, 1, 20, 1, 13, 0), 5000000, 'a', 'FontSize', 14);

%%% plot power spectral density profile
subplot(2, 2, 2);
[p,xl,yl,F,SD,Ulog,Llog]=specdensplot(y,nfft,fs,lwin,olap,sfax,'s');
grid on
ylim([40 140]);
% change color line
p(1).Color = [0.8 0.25 0.25];
p(2).Color = [0.5 0.5 0.5];
p(3).Color = [0.5 0.5 0.5];
% add subplot label
text(0.05, 130, 'b', 'FontSize', 14);

%%% plot spectogram
subplot(2, 2, 3);
timspecplot_ns(y,nfft,fs,wlen,wolap,beg,'s');
title('');
% insert colorbar
c = colorbar;
c.Label.String = 'spectral density (energy/Hz)';
% add subplot label
text(150, 18, 'c', 'FontSize', 14);

%%% plot filtered signal
subplot(2, 2, 4);
plot(t, yf);
grid on
xlim([min(t) max(t)]);
% add subplot label
text(datetime(2019, 1, 20, 1, 13, 0), 500000, 'd', 'FontSize', 14);
end

% Requires: filename must be in this format: 
%           "yyyy-MM-dd 'T' HH:mm:SS(.ssssss)"
% Modifies: nothing
% Effects:  calculate datetime of the file
function t = time(filename)
    filename = remove_path(filename);
    datestr = replace(filename,'_',':');
    % append '.000000' if ss does not have any decimals.
    if ~contains(datestr,'.')
        str = [datestr,'.000000'];
        datestr = join(str);
    end
    t = datetime(datestr,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
end

% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'
function filename = remove_path(full_filename)
    % remove file path from the file name
    splited_name = split(full_filename, '/');
    filename = cell2mat(splited_name(end));
end