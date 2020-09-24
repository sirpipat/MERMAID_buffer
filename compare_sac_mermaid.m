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
% Last modified by Sirawich Pipatprathanporn: 09/23/2020

% determine MERMAID location
[mlon, mlat] = mposition(dt);

% find the nearest station
[stations, networks, dists] = neareststations(sfile, mlon, mlat, 1);
fnames = findsacfiles(sacdir, stations{1}, networks{1});

% plot figure
t0 = seconds(0);
t0.Format = 'hh:mm:ss';
figure
for ii = 1:3
    names = split(removepath(fnames{ii}), '.');
    channel = names{3};
    title_name = sprintf('%s.%s.%s (%s)', networks{1}, stations{1}, ...
                         channel, dim);
    ax = subplot(4,1,ii);
    [xsac, Hdr, ~, ~, tims] = readsac(fnames{ii});
    dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
                      Hdr.NZMSEC, 'TimeZone', 'UTC','Format',...
                      'uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + days(Hdr.NZJDAY);
    dt_B = dt_ref + seconds(Hdr.B);
    dt_E = dt_ref + seconds(Hdr.E);
    fs = (Hdr.NPTS - 1) / seconds(dt_E - dt_B);
    title_name = sprintf('%s (%7.4f, %7.4f, distance from P023 = %7.4f)', ...
        title_name, Hdr.STLA, Hdr.STLO, dists(1));
    signalplot(xsac, fs, t0, ax, title_name,[],'k');
    grid on
    nolabels(ax, 1);
    ax.XAxis.Label.Visible = 'off';
    ax.TickDir = 'both';
end
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