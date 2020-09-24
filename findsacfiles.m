function fnames = findsacfiles(sacdir, station, network)
% fnames = FINDSACFILES(sacdir, station, network)
% Finds all sacfiles of a station from a SAC directory.
%
% INPUT:
% sacdir        SAC directory
% station       station name
% network       network name
%
% OUTPUT:
% fnames        names of all sacfiles of a station from a SAC directory
%
% Last modified by Sirawich Pipatprathanporn: 09/22/2020

% read all sac filenames
[allsacfiles, ~] = allfile(sacdir);
allsacfiles = allsacfiles';
data = split(allsacfiles, '/');
names = data(:, 9);
split_names = split(names, '.');
stations = split_names(:,2);
networks = split_names(:,1);

% find the files
where = and(strcmp(stations, station), strcmp(networks, network));
fnames = allsacfiles(where);
end