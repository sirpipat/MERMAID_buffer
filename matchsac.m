function matchsac(sacfile, merdir)
% Finds a section in OneYearData that SAC file belongs to
%
% INPUT:
% sacfile       Full filename of the sacfile
% merdir        Directory of the MERMAID files [Default: $ONEYEAR]
%
% OUTPUT:
% TBD
%
% SEE ALSO:
% READSAC, GETSECTIONS, READSECTION, 
%
% Last modified by Sirawich Pipatprathanporn, 02/05/2020


defval('merdir', getenv('ONEYEAR'));

% maximum t_shift in seconds
max_t_shift = 1200;

% the number of seconds in a day
d2s = 86400;

% reads data from SAC file
[x_sac, Hdr, ~, ~, ~] = readsac(sacfile);
dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
    Hdr.NZMSEC) + Hdr.NZJDAY;
dt_B = dt_ref + Hdr.B / d2s;
dt_E = dt_ref + Hdr.E / d2s;

% finds MERMAID file(s) containing dt_B and dt_E
[sections, intervals] = getsections(merdir, dt_B - max_t_shift / d2s, ...
    dt_E + max_t_shift / d2s);

% reads the section from MERMAID file(s)
% Assuming there is only 1 secion
[x_mer, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
    intervals{1}{2});

% decimates to obtain sampling rate about 10 Hz
fs = 10;
x_sac = decimate(x_sac, 2);
x_mer = decimate(x_mer, 4);

% applies Butterworth bandpass 0.05-0.10 Hz
x_sacf = bandpass(x_sac, fs, 0.05, 0.10, 2, 1, 'butter', 'linear');
x_merf = bandpass(x_mer, fs, 0.05, 0.10, 2, 1, 'butter', 'linear');

% finds timeshift
C = xcorr(x_merf, x_sacf);
[Cmax, Imax] = max(C);
figure(1)
plot(C);
t_shift = ((Imax - length(x_merf)) / 10) - max_t_shift;
fprintf('shifted time = %f s\n', t_shift);

figure(2);
signalplot(x_sacf, fs, dt_B + t_shift / d2s);
grid on
title('xcorr')
hold on
signalplot(x_merf, fs, dt_begin);
grid on
hold off
title('Filtered signals');
fig = gcf();
ax = fig.Children;
ax.Children(2).YData = ax.Children(2).YData - 2 * max(ax.Children(1).YData);
ax.YLim = max(ax.Children(1).YData) * [-3 1];
ax.XLim = [dt_begin dt_end];

figure(3);
signalplot(x_sac, fs, dt_B + t_shift / d2s);
grid on
title('xcorr')
hold on
signalplot(x_mer, fs, dt_begin);
grid on
hold off
title('Unfiltered signals');
fig = gcf();
ax = fig.Children;
ax.Children(2).YData = ax.Children(2).YData - 2 * max(ax.Children(1).YData);
ax.YLim = max(ax.Children(1).YData) * [-3 1];
ax.XLim = [dt_begin dt_end];
end