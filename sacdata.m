function [allsacfiles, sndex] = sacdata(sacdir)
% [allsacfiles, sndex] = SACDATA(sacdir)
% 
% INPUT:
% sacdir            Where you keep the sac files
%
% OUTPUT:
% allsacfiles       Bottom-file list with complete file names
% fndex             The total number of elements in the list
%
% SEE ALSO:
% ALLFILE, ONEYEARDATA, FILE2DATETIME, READONEYEARDATA
%
% Last modified by Sirawich Pipatprathanporn: 03/01/2020

defval('sacdir','/home/sirawich/research/processed_data/MERMAID_reports/');

% get sac folders
[allsacdirs,dndex] = allfile(sacdir);
% add trailing slash to allsacdirs
for ii = 1:dndex
    allsacdirs{ii} = strcat(allsacdirs{ii},'/');
end
% get all sacfilenames
allsacfiles = {};
sndex = 0;
for ii = 1:dndex
    [files, fndex] = allfile(allsacdirs{ii});
    allsacfiles = cat(2,allsacfiles,files);
    sndex = sndex + fndex;
end

% calculate the datetime of allsacfiles to check whether they are between
% oneyeardata section
alltimes = [];
for ii = 1:sndex
    splited_name = split(allsacfiles{ii},'.');
    splited_name = split(splited_name(1),'/');
    dt = datetime(splited_name(end),'InputFormat','uuuuMMdd''T''HHmmss');
    dt.TimeZone = 'UTC';
    alltimes = cat(2,alltimes,dt);
end

% compute the begin datetime and end datetime of oneyeardata section
[allfiles, ~] = oneyeardata(getenv('ONEYEAR'));
dt_begin = file2datetime(allfiles{1});
[~,~,dt_end] = readOneYearData(allfiles{end},40,0);

% remove any allsacfiles that are outside the oneyear section
allsacfiles = allsacfiles(isbetween(alltimes,dt_begin,dt_end));
sndex = length(allsacfiles);
end