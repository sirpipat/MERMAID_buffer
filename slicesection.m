function [x_out, dt_B, dt_E] = slicesection(x_in, dt_x1, dt_B, dt_E, fs)
% [x_out, dt_B, dt_E] = SLICESECTION(x_in, dt_x1, dt_B, dt_E, fs)
%
% Slices the section between dt_begin and dt_end.
% If you want to slice a section from a file, please use READSECTION.
%
% INPUT:
% x_in      The data of the input section
% dt_x1     Datetime of the first sample of the data
% dt_B      Datetime of the beginning
% dt_E      Datetime of the end
% fs        Sampling rate in Hz [Default: 40.01406]
%
% OUTPUT:
% x_out     The data from the section
% dt_B      Datetime of the beginning of the section
% dt_E      Datetime of the end of the section
%
% SEE ALSO:
% READSECTION
%
% Last modified by Sirawich Pipatprathanporn: 06/29/2020

defval('fs', 40.01406);

% datetime of the last sample
dt_xend = dt_x1 + seconds((length(x_in) - 1) / fs);

% check if dt_begin and dt_end is valid
if dt_B >= dt_E || dt_B > dt_xend || dt_E < dt_x1
    fprintf('ERROR: invalid dt_begin or dt_end\n');
    x_out = [];
    dt_B = NaT;
    dt_E = NaT;
    return
end

dt_B = max(dt_B, dt_x1);
dt_E = min(dt_E, dt_xend);

% slices the data
first_index = round(fs * seconds(dt_B - dt_x1) + 1, 0);
last_index = round(fs * seconds(dt_E - dt_x1) + 1, 0);
x_out = x_in(first_index:last_index);

% fixed dt_begin and dt_end to match the datetimes of first and last 
% sample from the section respectively
dt_B = dt_x1 + seconds((first_index - 1) / fs);
dt_E = dt_x1 + seconds((last_index - 1) / fs);
end