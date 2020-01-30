function fndex = getfndex(cell, value)
% index = GETFNDEX(cell, value)
%
% INPUT:
% array     sorted cell
% value     value of interest, must be the same datatype as array's members
%
% OUTPUT:
% fndex     index of the cell{index} closest to the value
%
% Last modified by Sirawich Pipatprathanporn: 01/23/2020

a = size(cell);
a_size = a(2);
high_bound = a_size;
low_bound = 1;
curr_index = middle(high_bound, low_bound);

while value ~= cell{curr_index}
    % check the high_bound and low_bound if there is nothing between
    if high_bound - low_bound <= 1
        fndex = low_bound;
        return
    end
    % try to shrink the range between high_bound and low_bound
    if value > cell{curr_index}
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