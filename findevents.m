function evs = findevents(arrival,stlo,stla)
% events = FINDEVENTS(arrival,stlo,stla)
% Search for event(s) that produce(s) signal in the seismogram. It requests
% events information from the catalog on IRIS. Then, it computes the
% theoretical arrival time using ray theory. It returns events that arrive
% within 3 minutes from the actual arrival time.
%
% INPUT
% arrival       arrival time from the seismogram
% stlo          station longitude
% stla          station latitude
%
% OUTPUT
% evs           the list of events which P-wave arrives with in 3 minutes
%               from arrival
%
% SEE ALSO
% IRISFETCH, TAUPTIME
%
% Last modified by Sirawich Pipatprathanporn: 09/01/2020

defval('stlo',[]);
defval('stla',[]);

if or(isempty(stlo), isempty(stla))
    [stlo,stla] = mposition(arrival);
end

arrival.Format = 'uuuu-MM-dd HH:mm:ss.SSSSSS';
ev = irisFetch.Events('starttime', string(arrival - minutes(20)), ...
    'endtime', string(arrival + minutes(1)));
arrival.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

phases = 'p, P, pP, PP, Pn, Pg, s, S, Sn, Sg, SS, PcP, Pdiff, PKP, PKiKP, PKIKP';

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
        for jj = 1:size(t,2)
            expected_arrival = datetime(ev(ii).PreferredTime,'TimeZone','UTC',...
                'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + seconds(t(jj).time);
            diff = expected_arrival - arrival;
            ev(ii).phase{size(ev(ii).phase,2)+1} = t(jj).phaseName;
            ev(ii).travelTime = [ev(ii).travelTime t(jj).time];
            ev(ii).expArrivalTime = [ev(ii).expArrivalTime ...
                expected_arrival];
            ev(ii).diff = [ev(ii).diff diff];
            ev(ii)
            fprintf('Arrival Time : %s\n',string(arrival));
            fprintf('Expected Time: %s\n',string(expected_arrival));
            fprintf('Difference   : %s\n',string(diff));
        end
    end
    if min(abs(ev(ii).diff)) < minutes(3)
        evs = [evs; ev(ii)];
    end
end

end