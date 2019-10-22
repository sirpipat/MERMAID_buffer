function hourly_maker(file, next)
% INPUT:
% 
% file      input file for making hourly plots
% next      the next file for determining sample rate
%           [TODO] if left blank, then the sample rate will be assumed to 
%           be 40
%
% Last modified by Sirawich Pipatprathanporn, 10/17/2019

% define variables
filename = file;
nextname = next;
fprintf("hourly_maker('%s', '%s')\n", file, next);
format = 'int32';
fc = [3,10];

% read file
y=loadb(filename,format,'l');

% determine sample rate, fs
t_start = time(filename);
t_end = time(nextname);
t_length = interval(t_start,t_end);
fs = length(y)/t_length;
fprintf('size = %d, interval = %d, fs = %f\n', length(y), t_length, fs);

% normalize the response
y = y/max([max(y),abs(min(y))]);

% filter the signal
yf= bandpass(y,fs,fc(1,1),fc(1,2),2,2,'butter','linear');

% split to hourly plots
% plot first hour
t = 1;
offset = 0;

% min(interval to next hour, total length): detect < 1hr length data
dm = min(interval(t_start, find_nexthour(t_start)),t_length);
hold on
if dm ~= 0
    hour_y = y(round(t*fs):round((t+dm-1)*fs));
    hour_yf = yf(round(t*fs):round((t+dm-1)*fs));
    plot_section(hour_y, hour_yf, fs, t_start, 3600 - dm, offset);
    t = t + dm;
    offset = offset + 2;
end

% plot following hours
while t < t_length
    % slice y into 1-hour chunk
    dt = min(3600, t_length - t);
    hour_y = y(round(t*fs):round((t+dt)*fs));
    hour_yf = yf(round(t*fs):round((t+dt)*fs));
    plot_section(hour_y, hour_yf, fs, t_start, 0, offset);
    t = t + 3600;
    offset = offset + 2;
end

grid on
xlabel('time')
hold off
set(gca, 'YDir','reverse')
title(sprintf('%s',replace(filename,'_','\_')))
end

% Requires: time1 must be before time2
% Modifies: nothing
% Effects:  find the interval between the two datetimes in seconds
function dt = interval(time1,time2)
    dur = time2 - time1;
    dvec = datevec(dur);
    dt = datevec_to_seconds(dvec);
end

% Requires: filename must be in this format: 
%           "yyyy-MM-dd 'T' HH:mm:SS(.ssssss)"
% Modifies: nothing
% Effects:  calculate datetime of the file
function t = time(filename)
    datestr = replace(filename,'_',':');
    % append '.000000' if ss does not have any decimals.
    if ~contains(datestr,'.')
        str = [datestr,'.000000'];
        datestr = join(str);
    end
    t = datetime(datestr,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
end

% return time interval of dvec in seconds
function dt = datevec_to_seconds(dvec)
    dt = dvec(1) * 365.2425 + dvec(3);
    dt = ((dt * 24 + dvec(4)) * 60 + dvec(5)) * 60 + dvec(6);
end

% return the next new hour e.g. returns 16:00:00 if the input is 15:23:37 
function t = find_nexthour(dtime)
    dvec = datevec(dtime);
    if dvec(5) == 0 && dvec(6) == 0
        t = dtime;
    else
        dvec(5) = 0;
        dvec(6) = 0;
        dvec(4) = dvec(4) + 1;
        t = datetime(dvec);
    end
end

% return the next new hour e.g. returns 15:00:00 if the input is 15:23:37 
function t = find_previoushour(dtime)
    dvec = datevec(dtime);
    dvec(5) = 0;
    dvec(6) = 0;
    t = datetime(dvec);
end


function plot_section(y,yf,fs,t_start,t_begin,offset)
    t_start = find_previoushour(t_start);
    x = linspace(t_begin, t_begin + length(y)/fs , length(y));
    x = duration(0,0,x,'Format','mm:ss');
    plot(x, t_start + duration(0, 30 * (-y + offset), 0),'k');
    plot(x, t_start + duration(0, 30 * (-yf + offset), 0),'r');
end