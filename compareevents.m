function compareevents(fmin, fmax, d_factor, fs)
% COMPAREEVENTS(fmin, fmax, d_factor)
% Compares waveforms of triggered arrivals and strong untriggered arrivals
% filtered using Butterworth bandpass with corner frequencies [fmin fmax].
%
% INPUT
% fmin          minimum frequency           [default: 0.05 Hz]
% fmax          maximum frequency           [default: 0.10 Hz]
% d_factor      decimation factor           [default: 5]
% fs            sampling rate of the buffer [default: 40.01406 Hz]
%
% Last modified by Sirawich Pipatprathanporn, 01/18/2021

defval('fmin', 0.05)
defval('fmax', 0.10)
defval('d_factor', 5)
defval('fs', 40.01406)

% read the events
[s, a, evs] = eventcatalog();

% filter for DETermined arrivals and strong untrigger arrivals
t = struct2table(s);
t = sortrows(t, 'dist', 'ascend');
t_DET = t(strcmp(t.tag, 'DET'), :);
t_3stars = t(strcmp(t.tag, '***'), :);
t_3stars = t_3stars(1:2:19, :);

figure
clf
set(gcf, 'Unit', 'inches', 'Position', [11.0833 3.0833 6.5 5])
ax1 = subplot(1,2,1);
set(ax1, 'FontSize', 10, 'Position', [0.08 0.1 0.4 0.84], 'TickDir', 'both');
hold on
box on
for ii = 1:height(t_DET)
    origin = t_DET.origin(ii);
    dist = t_DET.dist(ii);
    % read the section
    [sections, intervals] = getsections(getenv('ONEYEAR'), ...
        origin - minutes(5), origin + hours(1), fs);
    [x, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
        intervals{1}{2}, fs);
    % bandpass 0.05-0.10 Hz
    xd = detrend(decimate(detrend(x,1), d_factor),1);
    xf2 = bandpass(xd, fs/d_factor, fmin, fmax, 2, 2, 'butter', 'linear');
    xf2 = xf2(round(1+fs/d_factor*60):end);
    xf2 = xf2 / max(abs(xf2));
    
    starttime = dt_begin-origin+seconds(round(fs/d_factor*60)/(fs/d_factor));
    starttime.Format = 'hh:mm';    
    signalplot(xf2 + dist, fs/d_factor, starttime, ax1, ' ', [], 'k');
    xlim(hours([0 1]))
end
p = plot(t_DET.traveltime, t_DET.dist, 'LineWidth', 1); 
ylim([t_DET.dist(1)-1 t_DET.dist(end)+1])
legend(p, 'P-wave arrival', 'Location', 'best');
xlabel('time since origin (hh:mm)')
ylabel('epicentral distance (degree)')
title('determined')

% plot 3 stars traces
ax2 = subplot(1,2,2);
set(ax2, 'FontSize', 10, 'Position', [0.57 0.1 0.4 0.84], 'TickDir', 'both');
hold on
box on
for ii = 1:height(t_3stars)
    origin = t_3stars.origin(ii);
    dist = t_3stars.dist(ii);
    % read the section
    [sections, intervals] = getsections(getenv('ONEYEAR'), ...
       origin - minutes(5), origin + hours(1), fs);
    [x, dt_begin, dt_end] = readsection(sections{1}, intervals{1}{1}, ...
        intervals{1}{2}, fs);
    % bandpass 0.05-0.10 Hz
    xd = detrend(decimate(detrend(x,1), d_factor),1);
    xf2 = bandpass(xd, fs/d_factor, fmin, fmax, 2, 2, 'butter', 'linear');
    xf2 = xf2(round(1+fs/d_factor*60):end);
    xf2 = xf2 / max(abs(xf2));

    starttime = dt_begin-origin+seconds(round(fs/d_factor*60)/(fs/d_factor));
    starttime.Format = 'hh:mm';
    signalplot(xf2 + dist, fs/d_factor, starttime, ax2, ' ', [], 'k');
    xlim(hours([0 1]))
end
p = plot(t_3stars.traveltime, t_3stars.dist, 'LineWidth', 1);
ylim([t_3stars.dist(1)-1 t_3stars.dist(end)+1])
legend(p, 'P-wave arrival', 'Location', 'best');
xlabel('time since origin (hh:mm)')
ylabel('epicentral distance (degree)')
title('3 stars')

% save the figure
savename = sprintf('%s_fmin=%.3f_fmax=%.3f_dfactor=%d_fs=%.3f.eps', ...
    mfilename, fmin, fmax, d_factor, fs);
figdisp(savename, [], [], 2, [], 'epstopdf')
end