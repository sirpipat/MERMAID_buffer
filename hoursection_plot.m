function hoursection_plot(filename, nfft, fs, lwin, olap, sfax, beg, unit)
% HOURSECTION_MAKER(filename, nfft, fs, lwin, olap, sfax, beg, unit)
%
% INPUT
% filename      The name of raw MERMAID data file
% dt_begin      Beginning datetime
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
% Last modified by Sirawich Pipatprathanporn: 04/20/2020

% default parameter list
defval('nfft', 1024);
defval('fs', 40.01406);
defval('lwin', 1024);
defval('olap', 70);
defval('sfax', 10);
defval('unit', 's');

fprintf("hoursection_plot('%s')\n", filename);

% read file
[y, dt_start, dt_end] = readOneYearData(filename, fs);

fprintf('size = %d, interval = %d, fs = %f\n', length(y), length(y)/fs, fs);

% keep track of the current time
dt_curr = dt_start;

% slice first section then plot
[x, dt_B, dt_E] = slicesection(y, dt_start, dt_curr, dt_curr + hours(1), fs);
dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
% relative position of the sliced section in the file
p = [(dt_B - dt_start) (dt_E - dt_start)] / (dt_end - dt_start) * 100;
plot_all(x, dt_B, nfft, fs, lwin, olap, sfax, beg, unit, p);
dt_curr = dt_curr + minutes(30);

% slice later sections then plot
% the next section overlaps the previous section by 30 minutes
while dt_end - dt_curr > hours(1)
    [x, dt_B, dt_E] = slicesection(y, dt_start, dt_curr, ...
        dt_curr + hours(1), fs);
    dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
    % relative position of the sliced section in the file
    p = [(dt_B - dt_start) (dt_E - dt_start)] / (dt_end - dt_start) * 100;
    plot_all(x, dt_B, nfft, fs, lwin, olap, sfax, beg, unit, p);
    dt_curr = dt_curr + minutes(30);
end

end