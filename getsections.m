function [sections, intervals] = getsections(dir, dt_begin, dt_end, fs)
% [sections, intervals] = getsections(dir, dt_begin, dt_end, fs)
% Find the uptime sections of MERMAID P0023
%
% INPUT:
% dir           Directory of the one year data [Default: $ONEYEAR]
% dt_begin      Beginning datetime
% dt_end        End datetime
% fs            Sampling rate [Default: 40]
%
% OUTPUT:
% sections      Cell containing full-filenames of the sections overlapping
%               dt_begin to dt_end interval
% intervals     Cell containing the beginning and end of each section
%
% SEE ALSO:
% ONEYEARDATA, FILE2DATETIME, GETFNDEX, READONEYEARDATA
%
% Last modified by Sirawich Pipatprathanporn: 07/06/2020

defval('dir', getenv('ONEYEAR'));
defval('fs', 40);

[allfiles, fndex] = oneyeardata(dir);

% Gets all the start datetime of each file
allbegins = cell(1,fndex);
for ii = 1:fndex
    allbegins{ii} = file2datetime(allfiles{ii});
end

% returns nothing if the input argument is invalid
if ~is_dt_argument_valid(dt_begin, dt_end, allbegins{1})
    sections = {};
    intervals = {};
    return
end

% finds the beginning section and the end section
fndex_begin = getfndex(allbegins, dt_begin);
fndex_end = getfndex(allbegins, dt_end);

sections = {};
intervals = {};
% indexing only for the loop below
jj = 1;

for ii = fndex_begin:fndex_end
    % finds the end time of the file
    [~, ~, section_end] = readOneYearData(allfiles{ii}, fs);
    interval_begin = max(dt_begin, allbegins{ii});
    interval_end = min(dt_end, section_end);
    % only add valid sections
    if interval_begin < interval_end
        sections{jj} = allfiles{ii};
        intervals{jj} = {interval_begin, interval_end};
        jj = jj + 1;
    end
end

end

function is_valid = is_dt_argument_valid(dt_begin, dt_end, first_dt)
    % if the one of following conditions is true, return false
    is_valid = 0;
    if dt_begin >= dt_end
        return
    end
    if dt_end <= first_dt
        return
    end
    % otherwise, return true
    is_valid = 1;
end