function compare_sac_mermaid(sfile, sacdir, dt, dim)
% COMPARE_SAC_MERMAID(sfile, sacdir, dt, dim)
% Plots seismograms (from SAC files) at the nearest station with MERMAID
% P023 pressure record filterd at 0.05-0.10 Hz.
%
% INPUT
% sfile         STATION file
% sacdir        directory of SAC files
% dt            origin time
% dim           either 1D or 3D
% 
% Last modified by Sirawich Pipatprathanporn: 09/29/2020

% determine MERMAID location
[mlon, mlat] = mposition(dt);

% find the nearest station
[stations, networks, dists] = neareststations(sfile, mlon, mlat, 1);
fnames = findsacfiles(sacdir, stations{1}, networks{1});

t0 = seconds(0);
t0.Format = 'hh:mm:ss';

% read seismograms
[xsacE, HdrE, ~, ~, timsE] = readsac(fnames{1});
[xsacN, HdrN, ~, ~, timsN] = readsac(fnames{2});
[xsacZ, HdrZ, ~, ~, timsZ] = readsac(fnames{3});
dt_ref = datetime(HdrE.NZYEAR, 1, 0, HdrE.NZHOUR, HdrE.NZMIN, ...
                  HdrE.NZSEC, HdrE.NZMSEC, 'TimeZone', 'UTC','Format',...
                  'uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + days(HdrE.NZJDAY);
dt_B = dt_ref + seconds(HdrE.B);
dt_E = dt_ref + seconds(HdrE.E);
fs = (HdrE.NPTS - 1) / seconds(dt_E - dt_B);

% rotate
xsacR = cos(pi/180 * HdrN.BAZ) * xsacN + sin(pi/180 * HdrN.BAZ) * xsacE;
xsacT = -sin(pi/180 * HdrN.BAZ) * xsacN + cos(pi/180 * HdrN.BAZ) * xsacE;

% plot
figure

% Z component
ax1 = subplot(4,1,1);
title_name = sprintf('%s.%s.%s (%s)', networks{1}, stations{1}, ...
                     'Z', dim);
title_name = sprintf('%s (%7.4f, %7.4f, distance from P023 = %7.4f)', ...
                     title_name, HdrE.STLA, HdrE.STLO, dists(1));
signalplot(xsacZ, fs, t0, ax1, title_name, [], 'r');
grid on
nolabels(ax1, 1);
ax1.XAxis.Label.Visible = 'off';
ax1.TickDir = 'both';

% R component
ax2 = subplot(4,1,2);
title_name = sprintf('%s.%s.%s (%s)', networks{1}, stations{1}, ...
                     'R', dim);
title_name = sprintf('%s (%7.4f, %7.4f, distance from P023 = %7.4f)', ...
                     title_name, HdrE.STLA, HdrE.STLO, dists(1));
signalplot(xsacR, fs, t0, ax2, title_name, [], rgbcolor('green'));
grid on
nolabels(ax2, 1);
ax2.XAxis.Label.Visible = 'off';
ax2.TickDir = 'both';

% T component
ax3 = subplot(4,1,3);
title_name = sprintf('%s.%s.%s (%s)', networks{1}, stations{1}, ...
                     'T', dim);
title_name = sprintf('%s (%7.4f, %7.4f, distance from P023 = %7.4f)', ...
                     title_name, HdrE.STLA, HdrE.STLO, dists(1));
signalplot(xsacT, fs, t0, ax3, title_name, [], 'b');
grid on
nolabels(ax3, 1);
ax3.XAxis.Label.Visible = 'off';
ax3.TickDir = 'both';

% plot mermaid
ax = subplot(4,1,4);
fs = 40.01406;
d_factor = 5;
[sections, intervals] = getsections(getenv('ONEYEAR'), dt_B, dt_E, fs);
[x, dt_begin, ~] = readsection(sections{1}, intervals{1}{1}, ...
                               intervals{1}{2}, fs);
xd = detrend(decimate(detrend(x, 1), d_factor), 1);
xf = bandpass(xd, fs/d_factor, 0.05, 0.1, 2, 2, 'butter', 'linear');
signalplot(xf, fs/d_factor, t0, ax, ...
           'P023.Pressure (Filtered: dc5 dt bp0.05-0.1)', [], 'k');
ax.TickDir = 'both';

% add title
ax0 = subplot('Position', [0.10 0.93 0.80 0.02]);
title(sprintf('%s', string(dt_ref)));
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';
end