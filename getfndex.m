function fndex = getfndex(cells, value)
% index = GETFNDEX(cells, value)
%
% INPUT:
% cells     sorted cell
% value     value of interest, must be the same datatype as array's members
%
% OUTPUT:
% fndex     index of the cells{index} closest to the value
%
% Last modified by Sirawich Pipatprathanporn: 02/09/2021

a = size(cells);
a_size = a(2);
high_bound = a_size;
low_bound = 1;
curr_index = middle(high_bound, low_bound);

% check if the value is beyond the limit of the array
if value < cells{1}
    fndex = 1;
    return
elseif value > cells{end}
    fndex = length(cells);
    return
end

while value ~= cells{curr_index}
    % check the high_bound and low_bound if there is nothing between
    if high_bound - low_bound <= 1
        fndex = low_bound;
        return
    end
    % try to shrink the range between high_bound and low_bound
    if value > cells{curr_index}
        low_bound = curr_index;
        curr_index = middle(high_bound, low_bound);
    else
        high_bound = curr_index;
        curr_index = middle(high_bound, low_bound);
    end
end

fndex = curr_index;
end

function x = middle(a, b)
x = ceil((a + b) / 2);
end