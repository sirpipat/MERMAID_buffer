function hoursection_maker(filename, savedir)
% Creates hour sections of the data and stored in binary files with names
% in this format:
%       <beginning time in yyyy-MM-ddTHH:mm:SS.ssssss>.hsc
%
% INPUT
% filename  = the name of raw MERMAID data file
% savedir   = the directory of the output file
%               savedir should be a fullfile path
%
% NO OUTPUT (besides hoursection files)

fprintf("hoursection_maker('%s')\n", filename);

% sampling frequency
fs = 40;

% read file
y=loadb(filename,'int32','l');
filename = remove_path(filename);
t_start = filename2time(filename);
t_length = length(y) / fs;

fprintf('size = %d, interval = %d, fs = %f\n', length(y), t_length, fs);

% no need to split into sections if the length is less than 1 hour
if t_length < 3600
    outfile = strcat(savedir, filename, '.hsc');
    fid = fopen(outfile,'w','l');
    fwrite(fid,y,'int32');
    fclose(fid);
% splits into sections for >1 hour file
else
    num_sections = ceil(t_length / 3600);
    for index = 1:num_sections
        y_sec = y((index-1)*3600*fs + 1: min(index*3600*fs, length(y)));
        
        t_curr = t_start + index / 24;
        t_curr.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
        outfile = strcat(savedir, time2filename(t_curr), '.hsc');
        fid = fopen(outfile,'w','l');
        fwrite(fid,y_sec,'int32');
        fclose(fid);
    end
end

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
function t = filename2time(filename)
    filename = remove_path(filename);
    datestr = replace(filename,'_',':');
    % append '.000000' if ss does not have any decimals.
    if ~contains(datestr,'.')
        str = [datestr,'.000000'];
        datestr = join(str);
    end
    t = datetime(datestr,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
end

% Requires: date_t is a datetime
% Modifies: nothing
% Effects:  create a string representing the date_t
%           Format: 'yyyy-MM-dd''T''HH:mm:ss'
function filename = time2filename(date_t)
    filename = string(date_t);
    filename = replace(filename, ' ', 'T');
    filename = replace(filename, ':', '_');
end