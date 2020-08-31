function hoursection_plot(filename, nfft, fs, lwin, olap, sfax, beg, unit)
% HOURSECTION_PLOT(filename, nfft, fs, lwin, olap, sfax, beg, unit)
%
% INPUT
% filename      The name of raw MERMAID data file
% nfft          Number of FFT points [default: lwin]
% fs            Sampling frequency [Default: 40.01406]
% lwin          Window length, in samples [default: 256]
% olap          Window overlap, in percent [default: 70]
% sfax          Y-axis scaling factor [default: 10]
% beg           Signal beginning [Default: 0]
% unit          String with the unit name [Default: 's']
%
% NO OUTPUT (the plot saved at $EPS)
%
% Last modified by Sirawich Pipatprathanporn: 08/31/2020

% default parameter list
defval('nfft', 1024);
defval('fs', 40.01406);
defval('lwin', 1024);
defval('olap', 70);
defval('sfax', 10);
defval('beg', 0);
defval('unit', 's');

fprintf("hoursection_plot('%s')\n", filename);

% read file
[y, dt_start, dt_end] = readOneYearData(filename, fs);

fprintf('size = %d, interval = %d, fs = %f\n', length(y), length(y)/fs, fs);

% read the tphase files
readdir = '/Users/sirawich/research/processed_data/tphases/';
filename = strcat(readdir, 'rmsplot_', ...
    replace(string(dt_start), ':', '_'), '.txt');
fid = fopen(filename, 'r');
str = fscanf(fid, '%c');
fclose(fid);

% convert the content to datetime
datestr = split(str);
dt_all = datetime(datestr, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', ...
    'TimeZone', 'UTC', 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt_all = dt_all(~isnat(dt_all));
dt_trigs = dt_all(1:2:end);
dt_dtrigs = dt_all(2:2:end);

% filter the signal
yf1 = bandpass(y, fs, 2, 10, 2, 2, 'butter', 'linear');
dc_factor = 5;
yd = decimate(detrend(y(1:end-mod(length(y)-1, dc_factor)), 1), dc_factor);
yf2 = bandpass(detrend(yd, 1), fs/dc_factor, 0.05, 0.10, 2, 2, 'butter', 'linear');

% keep track of the current time
dt_curr = dt_start;

% slice first section then plot
[x, dt_B, dt_E] = slicesection(y, dt_start, dt_curr, dt_curr + hours(1), fs);
[xf1, ~, ~] = slicesection(yf1, dt_start, dt_curr, dt_curr + hours(1), fs);
[xf2, ~, ~] = slicesection(yf2, dt_start, dt_curr, dt_curr + hours(1), fs/dc_factor);

dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
% relative position of the sliced section in the file
p = [(dt_B - dt_start) (dt_E - dt_start)] / (dt_end - dt_start) * 100;
timfreqplot(x, xf1, xf2, dt_trigs, dt_dtrigs, dt_B, nfft, fs, lwin, ...
    olap, sfax, beg, unit, p, true, true);
dt_curr = dt_curr + minutes(30);

% slice later sections then plot
% the next section overlaps the previous section by 30 minutes
while dt_end - dt_curr > minutes(30)
    [x, dt_B, dt_E] = slicesection(y, dt_start, dt_curr, ...
        dt_curr + hours(1), fs);
    [xf1, ~, ~] = slicesection(yf1, dt_start, dt_curr, ...
        dt_curr + hours(1), fs);
    [xf2, ~, ~] = slicesection(yf2, dt_start, dt_curr, ...
        dt_curr + hours(1), fs/dc_factor);
    dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
    % relative position of the sliced section in the file
    p = [(dt_B - dt_start) (dt_E - dt_start)] / (dt_end - dt_start) * 100;
    timfreqplot(x, xf1, xf2, dt_trigs, dt_dtrigs, dt_B, nfft, fs, lwin, ...
        olap, sfax, beg, unit, p, true, true);
    dt_curr = dt_curr + minutes(30);
end

end