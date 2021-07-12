function [b_out,e_out] = simplifyintervals(b_in,e_in)
% [b_out,e_out] = SIMPLIFYINTERVALs(b_in,e_in)
%
% Simplifies possibly overlapping intervals.
%
% INPUT
% b_in      vector of intervals' beginnings
% e_in      vector of intervals' endings
%
% OUTPUT
% b_out     col vector of simplified intervals' beginnings
% e_out     col vector of simplified intervlas' endings
%
% Last modified by Sirawich Pipatprathanporn, 07/11/2021

% transform to col vectors
b_in = reshape(b_in,length(b_in),1);
e_in = reshape(e_in,length(e_in),1);

if size(b_in,1) ~= size(e_in,1)
    error('Error. Input must be equal in length.');
end

all_values = [b_in; e_in];

% keep track of beginnings and endings
b_tag = ones(length(b_in),1);
e_tag = -1 * ones(length(b_in),1);
all_tag = [b_tag; e_tag];

% sort beginning+ending and tags
[all_values, index] = sort(all_values);
all_tag = all_tag(index);

tag_status = cumsum(all_tag);

% remove above 1 trig status
valid_index = (tag_status <= 1);
all_values = all_values(valid_index);
tag_status = tag_status(valid_index);

% remove unchanged status
change_status = tag_status - circshift(tag_status, 1);
valid_index = or(change_status == -1, change_status == 1);
tag_status = tag_status(valid_index);
all_values = all_values(valid_index);

% output
b_out = all_values(1:2:end);
e_out = all_values(2:2:end);
end