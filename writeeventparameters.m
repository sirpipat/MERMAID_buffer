function writeeventparameters(criteria)
% WRITEEVENTPARAMETERS(criteria)
%
% Reads events from eventscatalog.txt, then inquires events from IRIS web 
% service, finds the best matches, and writes the stats to 
% eventparameters.txt.
%
% INPUT:
% criteria      how to sort events
%               - 'tag'     sorted from 'DET', 'REQ', '***', '**', to '*'
%               - 'time'    sorted by picked arrival time (original)
%
% OUTPUT:
% no output
%
% SEE ALSO:
% EVENTCATALOG
%
% Last modified by Sirawich Pipatprathanporn, 03/18/2021

%% read eventcatalog
[s, ~, ~] = eventcatalog();

defval('sname', sprintf('%s_%s.mat', mfilename, hash([s.evlo, s.evla, s.mag], 'SHA-1')))

pname = fullfile(getenv('IFILES'), 'HASHES', sname);

if ~exist(pname, 'file')
    for ii = 1:length(s)
        % assign arrival type
        switch s(ii).tag
            case 'DET'
                s(ii).arrival_type = 'body';
            case 'REQ'
                s(ii).arrival_type = 'body';
            case '***'
                s(ii).arrival_type = 'body';
            case 'S3'
                s(ii).arrival_type = 'surface';
            case '**'
                s(ii).arrival_type = 'body';
            case 'S2'
                s(ii).arrival_type = 'surface';
            case '*'
                s(ii).arrival_type = 'body';
            case 'S1'
                s(ii).arrival_type = 'surface';
            otherwise
                s(ii).arrival_type = '';
        end
    end
    % sort by tag
    % 1 DET
    % 2 REQ
    % 3 *** + S3
    % 4 **  + S4
    % 5 *   + S5
    if strcmp(criteria, 'tag')
        for ii = 1:length(s)
            % assign a value to tag for sorting
            switch s(ii).tag
                case 'DET'
                    s(ii).tagvalue = 1;
                case 'REQ'
                    s(ii).tagvalue = 2;
                case '***'
                    s(ii).tagvalue = 3;
                case 'S3'
                    s(ii).tagvalue = 3;
                case '**'
                    s(ii).tagvalue = 4;
                case 'S2'
                    s(ii).tagvalue = 4;
                case '*'
                    s(ii).tagvalue = 5;
                case 'S1'
                    s(ii).tagvalue = 5;
                otherwise
                    s(ii).tagvalue = 6;
            end
        end
        t = struct2table(s);
        ts = sortrows(t, {'tagvalue', 'origin'}, 'ascend');
        s = table2struct(ts);
    end

    %% find best match events
    evs = [];
    for ii = 1:length(s)
        ev_all = findevents(s(ii).arrival, s(ii).stlo, s(ii).stla, s(ii).arrival_type);
        % best match : highest magnitude
        if isempty(ev_all)
            fprintf('No match. Exit.\n');
            return
        end
        ev_best = ev_all(1);
        origin = datetime(ev_all(1).PreferredTime, ...
                'InputFormat', 'uuuu-MM-dd HH:mm:ss.SSS', ...
                'TimeZone', 'UTC');
        best_origin_diff = abs(origin - s(ii).origin);
        ev_index = 1;
        while ev_index < length(ev_all)
            ev_index = ev_index + 1;
            origin = datetime(ev_all(ev_index).PreferredTime, ...
                'InputFormat', 'uuuu-MM-dd HH:mm:ss.SSS', ...
                'TimeZone', 'UTC');
            if abs(origin - s(ii).origin) < best_origin_diff
                ev_best = ev_all(ev_index);
                best_origin_diff = abs(origin - s(ii).origin);
            end
        end

        % reject the match if the magnitude is below 4.0
        if ev_best.PreferredMagnitudeValue < 4.0
            fprintf('No match.');
            pause;
            continue
        end
        
        ev_best.pickedArrivalTime = s(ii).arrival;
        ev_best.arrival_type = s(ii).arrival_type;
        ev_best.tag = s(ii).tag;
        ev_best.tagvalue = s(ii).tagvalue;
        evs = [evs ev_best];
    end
    save(pname, 'evs', 's');
else
    load(pname, 'evs');
end

for ii = 1:length(evs)
    ev = evs(ii);
    % REMOVE THIS
    plotevent(ev.pickedArrivalTime, ev.arrival_type, ev, [], 40.01406);
    %%%
end

%% write the event parameters
fname = '/Users/sirawich/research/processed_data/events/eventparameters.txt';
fid = fopen(fname, 'w');
for ii = 1:length(evs)
    ev = evs(ii);
    fprintf(fid, 'Event number %d\n', ii);
    arrival = ev.pickedArrivalTime;
    arrival.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
    fprintf(fid, 'Picked arrival: %s\n', string(arrival));
    fprintf(fid, 'Tag           : %s\n', ev.tag);
    fprintf(fid, 'Arrival type  : %s\n', ev.arrival_type);
    fprintf(fid, '\n');
    fprintf(fid, 'Event parameters\n');
    fprintf(fid, 'IRIS Event ID : %s\n', ev.id);
    fprintf(fid, 'Origin time   : %s\n', ev.PreferredTime);
    fprintf(fid, 'Latitude      : %9.4f\n', ev.evla);
    fprintf(fid, 'Longitude     : %9.4f\n', ev.evlo);
    fprintf(fid, 'Depth         : %9.4f\n', ev.PreferredDepth);
    fprintf(fid, 'Magnitude     : %7.2f   %s\n', ...
        ev.PreferredMagnitudeValue, ev.PreferredMagnitudeType);
    fprintf(fid, '\n');
    fprintf(fid, 'Station parameters\n');
    fprintf(fid, 'Latitude      : %9.4f\n', ev.stla);
    fprintf(fid, 'Longitude     : %9.4f\n', ev.stlo);
    fprintf(fid, 'Distance      : %9.4f\n', ev.distance);
    fprintf(fid, '\n');
    fprintf(fid, 'Phase parameters\n');
    fprintf(fid, 'Phase\tTravel time\tExpected arrival time \n');
    for jj = 1:length(ev.travelTime)
        % convert format to uuuu-MM-dd HH:mm:ss.SSS
        exparrival = ev.expArrivalTime(jj);
        exparrival.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
        fprintf(fid, '%5s\t%11.4f\t%s\n', ev.phase{jj}, ev.travelTime(jj), ...
            string(exparrival));
    end
    fprintf(fid, '------------------------------------------------\n');
end
fclose(fid);
end