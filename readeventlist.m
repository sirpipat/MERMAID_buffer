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
begins = datetime(data(:,1),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
ends = datetime(data(:,2),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
arrivals = datetime(data(:,3),'InputFormat',fmt,'TimeZone','UTC',...
    'Format',fmt);
tags = data(:,4);

if size(tag,1) == 1
    begins = begins(strcmp(tags,tag));
    ends = ends(strcmp(tags,tag));
    arrivals = arrivals(strcmp(tags,tag));
    tags = tags(strcmp(tags,tag));
else

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