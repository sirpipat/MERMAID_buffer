function [begins,ends,arrivals,tags] = readeventlist(tag)

defval('tag',[])

fmt = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
fname = '/Users/sirawich/research/processed_data/events.txt';

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

if size(tag,1) >= 1
    begins = [];
    ends = [];
    arrivals = [];
    tags = [];
    for ii = 1:size(tag,1)
        begins = [begins; data_begins(strcmp(data_tags,tag{ii}))];
        ends = [ends; data_ends(strcmp(data_tags,tag{ii}))];
        arrivals = [arrivals; data_arrivals(strcmp(data_tags,tag{ii}))];
        tags = [tags; data_tags(strcmp(data_tags,tag{ii}))];
    end
end

[begins, sorted_index] = sort(begins);
ends = ends(sorted_index);
arrivals = arrivals(sorted_index);
tags = tags(sorted_index);

% figure(1);
% clf
% hold on
% for ii = 1:size(begins,1)
%     plot([begins(ii) ends(ii)], [ii ii], 'k', 'LineWidth', 2);
% end
% scatter(arrivals, 1:size(arrivals,1), 10, 'or');
% hold off
% grid on
% 
% figure(2);
% clf
% hold on
% scatter(begins - arrivals, 1:size(begins), 'or');
% scatter(ends - arrivals, 1:size(begins), 'ob');
% vline(gca,seconds(0),'--',1,'k');
% hold off
% grid on
end