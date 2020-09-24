function [begins,ends,arrivals,tags] = readeventlist(tag)
% [begins,ends,arrivals,tags] = READEVENTLIST(tag)
% Reads events from events.txt and returns events with specified tag(s).
%
% INPUT:
% tag           what kind(s) of events
%       []      all kinds of events    [default]
%       DET     triggered, reported events
%       REQ     requested, reported events
%       ***     unreported strong events,   arrival = P-wave arrival
%       **      unreported moderate events, arrival = P-wave arrival
%       *       unreported weak events,     arrival = P-wave arrival
%       S3      unreported strong events,   arrival = surface wave arrival
%       S2      unreported moderate events, arrival = surface wave arrival
%       S1      unreported weak events,     arrival = surface wave arrival
%       
% OUTPUT:
% begins        beginning datetime 
% ends          ending datetime
% arrivals      picked arrivals datetime (between begins and ends)
% tags          the kind of events
%
% Examples
% % return all events
% [begins,ends,arrivals,tags] = READEVENTLIST();
%
% % return triggered, reported events
% [begins,ends,arrivals,tags] = READEVENTLIST('DET');
%
% % return all unreported events, with arrival = P-wave arrivals
% [begins,ends,arrivals,tags] = READEVENTLIST({'***', '**', '*'});
% 
% Last modified by Sirawich Pipatprathanporn: 09/24/2020

defval('tag',[])

fmt = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

% change this if your file is in a different location
fname = '/Users/sirawich/research/processed_data/events/events.txt';

fid = fopen(fname,'r');
txt = fscanf(fid, '%c');
fclose(fid);
data = split(txt);
data = data(1:end-1);
data = reshape(data,4,size(data,1)/4)';
data_begins = datetime(data(:,1),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
data_ends = datetime(data(:,2),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
data_arrivals = datetime(data(:,3),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
data_tags = data(:,4);

% for multiple tags
if size(tag,2) >= 1
    begins = [];
    ends = [];
    arrivals = [];
    tags = [];
    for ii = 1:size(tag,2)
        begins = [begins; data_begins(strcmp(data_tags,tag{ii}))];
        ends = [ends; data_ends(strcmp(data_tags,tag{ii}))];
        arrivals = [arrivals; data_arrivals(strcmp(data_tags,tag{ii}))];
        tags = [tags; data_tags(strcmp(data_tags,tag{ii}))];
    end
% for single tag or no tag
else
    begins = data_begins;
    ends = data_ends;
    arrivals = data_arrivals;
    tags = data_tags;
end

% filter the arrivals based on tags
[begins, sorted_index] = sort(begins);
ends = ends(sorted_index);
arrivals = arrivals(sorted_index);
tags = tags(sorted_index);
end