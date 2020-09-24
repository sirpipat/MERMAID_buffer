function matchevents()
% MATCHEVENTS()
% Reads events from events.txt, then inquires events from IRIS web service,
% plots the matches and writes the stats to matched_events.txt.
%
% INPUT:
% No input
%
% OUTPUT:
% No return values
% Save matches figures in $EPS
% Save the stats to matched_events.txt
%   the columns are
%   1.  actual arrival times
%   2.  tags (*** = outstanding signal, ** = good signal)
%   3.  station longitudes
%   4.  station latitudes
%   5.  event longitudes
%   6.  event latitudes
%   7.  event depths
%   8.  magnitudes
%   9.  distances
%   10. phases
%   11. event origin times
%   12. expected arrival times
%   13. travel times
%   14. difference
%   15. PublicId
%
%
% SEE ALSO:
% READEVENTLIST, FINDEVENTS, PLOTEVENT
%
% Last modified by Sirawich Pipatprathanporn: 09/24/2020
[b,e,a,tg] = readeventlist();

% store information of events
arrivals = datetime.empty;
arrivals.TimeZone = 'UTC';
arrivals.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
tags = [];
stlos = [];
stlas = [];
evlos = [];
evlas = [];
depths = [];
mags = [];
phases = cell(0);
dists = [];
origin_times = datetime.empty;
origin_times.TimeZone = 'UTC';
origin_times.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
exp_arrivals = datetime.empty;
exp_arrivals.TimeZone = 'UTC';
exp_arrivals.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
travel_times = [];
diffs = [];
ids = cell(0);

for ii = 1:size(a,1)
    [stlo, stla] = mposition(a(ii));
    % arrival_type
    if tg{ii}(1) == 'S'
        arrival_type = 'surface';
    else
        arrival_type = 'body';
    end
    
    % search for events using IRIS web service
    events = findevents(a(ii), stlo, stla, arrival_type);
    if isempty(events)
        continue
    end
    
    % plot the events
    for jj = 1:size(events, 1)
        plotevent(a(ii), arrival_type, events(jj), e(ii));
        depth = max(0, events(jj).PreferredDepth);
        for kk = 1:size(events(jj).travelTime,2)
            arrivals = [arrivals a(ii)];
            tags = [tags tg(ii)];
            stlo = events(jj).stlo;
            stla = events(jj).stla;
            evlo = events(jj).evlo;
            evla = events(jj).evla;
            stlos = [stlos stlo];
            stlas = [stlas stla];
            evlos = [evlos evlo];
            evlas = [evlas evla];
            depths = [depths depth];
            mags = [mags events(jj).PreferredMagnitudeValue];
            phases{size(phases,2)+1} = events(jj).phase{kk};
            dists = [dists events(jj).distance];
            origin_time = datetime(events(jj).PreferredTime,...
                                   'TimeZone','UTC','Format',...
                                   'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
            origin_times = [origin_times origin_time];
            exp_arrivals = [exp_arrivals events(jj).expArrivalTime(kk)];
            travel_times = [travel_times events(jj).travelTime(kk)];
            diffs = [diffs events(jj).diff(kk)];
            ids{size(ids,2)+1} = events(jj).id;
        end
    end
end

% handles NaN, NaT
travel_times = duration(seconds(travel_times));
travel_times.Format = 'hh:mm:ss';
diffs.Format = 'hh:mm:ss';
origin_strings = string(origin_times);
origin_strings(ismissing(origin_strings)) = "NaT";
exp_strings = string(exp_arrivals);
exp_strings(ismissing(exp_strings)) = "NaT";
diff_strings = string(diffs);
diff_strings(ismissing(diff_strings)) = "NaN";
travel_time_strings = string(travel_times);
travel_time_strings(ismissing(travel_time_strings)) = "NaN";

% writing output
fname = '/Users/sirawich/research/processed_data/events/matched_events.txt';
fid = fopen(fname, 'w');
for ii = 1:size(arrivals,2)
    % the columns are
    % 1.  actual arrival times
    % 2.  tags (*** = outstanding signal, ** = good signal)
    % 3.  station longitudes
    % 4.  station latitudes
    % 5.  event longitudes
    % 6.  event latitudes
    % 7.  event depths
    % 8.  magnitudes
    % 9.  distances
    % 10. phases
    % 11. event origin times
    % 12. expected arrival times
    % 13. travel times
    % 14. difference
    % 15. PublicId
    %
    fprintf(fid,'%s %3s %7.2f %7.2f %7.2f %7.2f %6.2f %5.2f %6.2f %+5s %+26s %+26s %+9s %+9s %+8s\n',...
            string(arrivals(ii)),tags{ii},stlos(ii),stlas(ii),evlos(ii),evlas(ii),depths(ii),mags(ii),...
            dists(ii),phases{ii},origin_strings(ii),exp_strings(ii),travel_time_strings(ii),diff_strings(ii),ids{ii});
end
fclose(fid);
end