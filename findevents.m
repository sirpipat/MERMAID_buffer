function evs = findevents(arrival, stlo, stla, arrival_type)
% evs = FINDEVENTS(arrival, stlo, stla, arrival_type)
% Search for event(s) that produce(s) signal in the seismogram. It requests
% events information from the catalog on IRIS. Then, it computes the
% theoretical arrival time using ray theory. It returns events that arrive
% within 3 minutes from the actual arrival time (for body wave) or events
% that arrive between 5 km/s wave and 3 km/s wave (for surface wave).
%
% INPUT
% arrival       arrival time
% stlo          station longitude [default: MERMAID P023 longitude]
% stla          station latitude  [default: MERMAID P023 latitude]
% arrival_type  either 'body' or 'surface' [Default: 'body']
%
% OUTPUT
% evs           the list of event struct with the following fields
%               - Type
%               - FlinnEngdahRegionCode
%               - FlinnEngdahRegionName
%               - PreferredTime
%               - PreferredLatitude
%               - PreferredDepth
%               - PreferredMagnitudeType
%               - PreferredMagnitydeValue
%               - PreferredOrigin
%               - Origins
%               - PreferredMagnitude
%               - Magnitudes
%               - Picks = []
%               - PublicId
%               - phase
%               - travelTime
%               - expArrivalTime
%               - diff
%               - stlo
%               - stla
%               - evlo
%               - evla
%               - distance
%               - id
% SEE ALSO
% IRISFETCH, TAUPTIME
%
% Last modified by Sirawich Pipatprathanporn: 09/08/2020

defval('stlo',[]);
defval('stla',[]);
defval('arrival_type','body');

% figure out stlo and stla from P023 position if they are not specified
if or(isempty(stlo), isempty(stla))
    [stlo,stla] = mposition(arrival);
end

% search for events
arrival.Format = 'uuuu-MM-dd HH:mm:ss.SSSSSS';
if strcmp(arrival_type,'body')
    ev = irisFetch.Events('starttime', string(arrival - minutes(20)), ...
        'endtime', string(arrival + minutes(1)));
else
    ev = irisFetch.Events('starttime', string(arrival - minutes(120)), ...
        'endtime', string(arrival + minutes(1)));
end
arrival.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

% phase list for calculating arrival times
phases = 'P, Pdiff, PKIKP, S, Sdiff, SKIKS';

evs = [];
for ii = 1:size(ev,2)
    depth = max(0, ev(ii).PreferredDepth);
    t = taupTime('ak135',depth,phases,'sta',[stla stlo], ...
        'evt',[ev(ii).PreferredLatitude ev(ii).PreferredLongitude]);
    if ~isempty(t)
        ev(ii).phase = cell(0);
        ev(ii).travelTime = [];
        ev(ii).expArrivalTime = [];
        ev(ii).diff = [];
        ev(ii).stlo = stlo;
        ev(ii).stla = stla;
        ev(ii).evlo = ev(ii).PreferredLongitude;
        ev(ii).evla = ev(ii).PreferredLatitude;
        ev(ii).distance = t(1).distance;
        id_str = split(removepath(ev(ii).PublicId), '=');
        ev(ii).id = id_str{2};
        for jj = 1:size(t,2)
            expected_arrival = datetime(ev(ii).PreferredTime,'TimeZone','UTC',...
                'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + seconds(t(jj).time);
            diff = expected_arrival - arrival;
            ev(ii).phase{size(ev(ii).phase,2)+1} = t(jj).phaseName;
            ev(ii).travelTime = [ev(ii).travelTime t(jj).time];
            ev(ii).expArrivalTime = [ev(ii).expArrivalTime ...
                expected_arrival];
            ev(ii).diff = [ev(ii).diff diff];
        end
    end
    % collect events that satisfied arrival time criteria
    % body waves: at least one phase arrivals must be within 3 minutes from
    % the input arrival
    if strcmp(arrival_type, 'body') && min(abs(ev(ii).diff)) < minutes(3)
        evs = [evs; ev(ii)];
    % surface waves: the input arrival must be between 5 km/s wave and 
    % 3 km/s wave
    elseif strcmp(arrival_type, 'surface') && ~isempty(t)
        body_traveltimes = seconds(t(1).distance * pi/180 * 6371 ./ [5 3]);
        body_arrivals = datetime(ev(ii).PreferredTime,'TimeZone','UTC',...
            'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + body_traveltimes;
        if arrival > body_arrivals(1) && arrival < body_arrivals(2)
            evs = [evs; ev(ii)];
        end
    end
end

end