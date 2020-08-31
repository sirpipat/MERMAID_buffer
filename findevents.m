function events = findevents(arrival,stlo,stla)
% events = FINDEVENTS(arrival,stlo,stla)
% Search for event(s) that produce(s) signal in the seismogram. It requests
% events information from the catalog on IRIS. Then, it computes the
% theoretical arrival time using ray theory. It returns events which the
% P-wave arrives within 3 minutes from the actual arrival time.
%
% INPUT
% arrival       arrival time from the seismogram
% stlo          station longitude
% stla          station latitude
%
% OUTPUT
% events        the list of events which P-wave arrives with in 3 minutes
%               from arrival
%
% SEE ALSO
% IRISFETCH, TAUPTIME
%
% Last modified by Sirawich Pipatprathanporn: 08/25/2020

defval('stlo',[]);
defval('stla',[]);

if or(isempty(stlo), isempty(stla))
    [stlo,stla] = mposition(arrival);
end

arrival.Format = 'uuuu-MM-dd HH:mm:ss.SSSSSS';
ev = irisFetch.Events('starttime', string(arrival - minutes(20)), ...
    'endtime', string(arrival + minutes(1)));

phases = 'p, P, pP, PP, Pn, Pg, s, S, Sn, Sg, PcP, Pdiff, PKP, PKiKP, PKIKP';

events = [];
for ii = 1:size(ev,2)
    depth = max(0, ev(ii).PreferredDepth);
    t = taupTime('ak135',depth,phases,'sta',[stla stlo], ...
        'evt',[ev(ii).PreferredLatitude ev(ii).PreferredLongitude]);
    if ~isempty(t)
        expected_arrival = datetime(ev(ii).PreferredTime,'TimeZone','UTC',...
            'Format','uuuu-MM-dd HH:mm:ss.SSSSSS') + seconds(t(1).time);
        diff = expected_arrival - arrival;
        if abs(diff) < minutes(3)
            events = [events; ev(ii)];
            ev(ii)
            fprintf('Arrival Time : %s\n',string(arrival));
            fprintf('Expected Time: %s\n',string(expected_arrival));
            fprintf('Difference   : %s\n',string(diff));
        end
    end
end
end