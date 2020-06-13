function t = file2datetime(filename)
% function t = file2datetime(filename)
%
% Convert MERMAID filename to datetime
% e.g. file2datetime('$FILEDIR/2018-10-21T10_40_42.175000') 
%              == datetime(2018, 10, 21, 10, 40, 42.175000)
% 
% INPUT:
%
% filename  Name of MERMAID file
%
% OUTPUT:
%
% t         Datetime at the beginning
%
% SEE ALSO:
% REMOVEPATH
%
% Last modified by Sirawich Pipatprathanporn: 06/13/2020

filename = removepath(filename);
datestr = replace(filename,'_',':');
% append '.000000' if ss does not have any decimals.
if ~contains(datestr,'.')
    str = [datestr,'.000000'];
    datestr = join(str);
end
t = datetime(datestr,'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
             'TimeZone', 'UTC');
t.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
end