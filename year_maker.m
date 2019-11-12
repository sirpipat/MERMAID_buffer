function year_maker(ddir, i_begin, i_end)

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
    while t_end > find_next_midnight(t_curr)
        x_begin = t_curr - find_prev_midnight(t_curr);
        x_end = find_next_midnight(t_curr) - find_prev_midnight(t_curr);
        xx = [x_begin x_end];
        y = find_prev_midnight(t_curr);
        yy = [y y];
        plot(xx, yy, 'k');
        % update
        t_curr = find_next_midnight(t_curr);
    end
    
    % plot last day section
    x_begin = t_curr - find_prev_midnight(t_curr);
    x_end = t_end - find_prev_midnight(t_curr);
    xx = [x_begin x_end];
    y = find_prev_midnight(t_curr);
    yy = [y y];
    plot(xx, yy,'k');
end
grid on
xlabel('time (mm:ss)')
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

% return the beginning of the midnight 
function t = find_prev_midnight(dtime)
    dvec = datevec(dtime);
    dvec(4) = 0;
    dvec(5) = 0;
    dvec(6) = 0;
    t = datetime(dvec);
end

% return the beginning of the next midnight 
function t = find_next_midnight(dtime)
    dvec = datevec(dtime);
    dvec(3) = dvec(3) + 1;
    dvec(4) = 0;
    dvec(5) = 0;
    dvec(6) = 0;
    t = datetime(dvec);
end