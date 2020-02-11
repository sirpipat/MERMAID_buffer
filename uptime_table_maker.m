function uptime_table_maker(dir, fs, direction, savefile)

% gets all filenames
[allfiles, fndex] = oneyeardata(dir);

% writes header
fileID = fopen(savefile, 'w');
header = ["filename" "begin_time" "end_time" "duration"];
fprintf(fileID, '%-26s\t%-20s\t%-20s\t%+9s\n', header(1), header(2), ...
    header(3), header(4));
% wrties begin and end time
for ii = 1:fndex
    [~, dt_begin, dt_end] = readOneYearData(allfiles{ii}, fs, direction);
    dur = dt_end - dt_begin;
    fprintf(fileID, '%-26s\t%-20s\t%-20s\t%+9s\n', ...
        removepath(allfiles{ii}), string(dt_begin), string(dt_end), ...
        string(dur));
end
fclose(fileID);
end