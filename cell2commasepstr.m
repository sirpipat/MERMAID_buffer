function str = cell2commasepstr(cll)
% str = cell2commasepstr(cll)
%
% Converts the elements of the cell to a string inside "..." and then joins
% them with comma seperators.
%
% INPUT:
% cll       cell array
%
% OUTPUT:
% str       string with comma separators
%
% EXAMPLE:
% >> fprintf('%s\n', cell2commasepstr({2, 'cats'});
% "2", "cats"
%
% SEE ALSO:
% STRJOIN
%
% Last modified by sirawich@princeton.edu, 06/22/2026

str = strjoin(cll, '", "');
str = ['"' str '"'];
end