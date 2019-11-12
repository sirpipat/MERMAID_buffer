function year_maker(ddir, i_begin, i_end)
% INPUT
% ddir                       = directory of the one year data files
% i_begin [min = 1]          = first index of files to included in the plot
% i_end   [max = # of files] = last index of files to included in the plot
%
% If i_begin or i_end does not follow the min/max bound, it will be 
% assumed to be the min/max value.
%
% Any calls of i_begin and i_end are valid as long as  i_begin >= i_end
%
% Last modified by Sirawich Pipatprathanporn, 11/11/2019

% Assume sampling frequency to be 40 Hz
fs = 40;
% second to day conversion
s2d = 86400;
hold on

% read all data files
[allfiles,fndex] = oneyeardata(ddir);

for index = max(1,i_begin):min(i_end,fndex)
    filename = allfiles{index};
    a = loadb(filename, 'int32', 'l');
    t_start = time(filename);
    t_length = length(a) / fs;
    t_end = t_start + t_length / s2d;
    
    % plot each day section
    t_curr = t_start;
    while t_end > find_next_month(t_curr)
        x_begin = t_curr - find_prev_month(t_curr) + 1;
        x_begin.Format = 'd';
        x_end = find_next_month(t_curr) - find_prev_month(t_curr) + 1;
        x_end.Format = 'd';
        xx = [x_begin x_end];
        y = find_prev_month(t_curr);
        yy = [y y];
        p = plot(xx, yy, 'k');
        p.LineWidth = 2;
        % update
        t_curr = find_next_month(t_curr);
    end
    
    % plot last day section
    x_begin = t_curr - find_prev_month(t_curr) + 1;
    x_begin.Format = 'd';
    x_end = t_end - find_prev_month(t_curr) + 1;
    x_end.Format = 'd';
    xx = [x_begin x_end];
    y = find_prev_month(t_curr);
    yy = [y y];
    p = plot(xx, yy,'k');
    p.LineWidth = 2;
end
grid on
title('Year plot');
set(gca, 'YDir','reverse')
end

% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'
function filename = remove_path(full_filename)
    % remove file path from the file name
    splited_name = split(full_filename, '/');
    filename = cell2mat(splited_name(end));
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

% return the beginning of the month 
function t = find_prev_month(dtime)
    dvec = datevec(dtime);
    dvec(3) = 1;
    dvec(4) = 0;
    dvec(5) = 0;
    dvec(6) = 0;
    t = datetime(dvec);
end

% return the beginning of the next month 
function t = find_next_month(dtime)
    dvec = datevec(dtime);
    dvec(2) = dvec(2) + 1;
    dvec(3) = 1;
    dvec(4) = 0;
    dvec(5) = 0;
    dvec(6) = 0;
    t = datetime(dvec);
end

% Requires: time1 must be before time2
% Modifies: nothing
% Effects:  find the interval between the two datetimes in days
function dt = interval(time1,time2)
    dur = time2 - time1;
    dvec = datevec(dur);
    dt = datevec_to_days(dvec);
end

% return time interval of dvec in seconds
function dt = datevec_to_days(dvec)
    dt = dvec(1) * 365.2425 + dvec(3);
    dt = ((dt * 24 + dvec(4)) * 60 + dvec(5)) * 60 + dvec(6);
    dt = dt / 86400;
end