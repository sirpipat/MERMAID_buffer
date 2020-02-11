function downtime_table_maker(dir, fs, direction, savefile)

% gets all filenames
[allfiles, fndex] = oneyeardata(dir);

% header
header = ["first_file" "second_file" "first_end_time" ...
    "second_begin_time" "gap_time"];

% writes header
fileID = fopen(savefile, 'w');
fprintf(fileID, '%-26s\t%-26s\t%-20s\t%-20s\t%-20s\n', header(1), header(2), ...
    header(3), header(4), header(5));

% wrties time gaps
for ii = 1:fndex-1
    [~, ~, dt_end1] = readOneYearData(allfiles{ii}, fs, direction);
    [~, dt_begin2, ~] = readOneYearData(allfiles{ii+1}, fs, direction);
    gaptime = dt_begin2 - dt_end1;
    fprintf(fileID, '%-26s\t%-26s\t%-20s\t%-20s\t%+9s\n', ...
        removepath(allfiles{ii}), removepath(allfiles{ii+1}), ...
        string(dt_end1), string(dt_begin2), string(gaptime));
end
fclose(fileID);
end