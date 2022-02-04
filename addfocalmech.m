function addfocalmech(ax, loc, option, info)
% ADDFOCALMECH(ax, loc, option, info)
%
% Looks up for a full moment tensor of a specified earthquake and draws a 
% full moment tensor beachball diagram to a plot. If no moment tensor is
% found, a pentagram will be added in place of the beachball. The file(s)
% to monthly moment tensor catalogs have to be located at $IFILES/CMT/.
%
% INPUT:
% ax            target axes to plot
% loc           location of the earthquake [Default: [lon lat]]             
% option        type of information to supply: either one of these
%                   'PublicID'
%                   'Event'
% info          information for the given option
%                   - for 'PublicID', the info is a string representing
%                     IRIS event ID
%                   - for 'Event', the info is a struct representing an
%                     earthquake event that is returned from
%                     IRISFETCH.EVENTS
%
% This function updates the target axes, ax.
%
% SEE ALSO:
% READCMT, FOCALMECH, IRISFETCH
%
% Last modified by sirawich-at-princeton.edu, 10/07/2021


if strcmpi(option, 'publicid')
    event = irisFetch.Events('eventID', info);
elseif strcmpi(option, 'event')
    event = info;
else
    return
end

dt_origin = datetime(event.PreferredTime, ...
   'TimeZone', 'UTC', 'Format', 'uuuu-MMM-dd''T''HH:mm:ss.SSSSSS');
tbeg = datenum(dt_origin - minutes(1));
tend = datenum(dt_origin + minutes(1));
mblo = event.PreferredMagnitudeValue - 0.5;
mbhi = event.PreferredMagnitudeValue + 0.5;
depmin = event.PreferredDepth - 50;
depmax = event.PreferredDepth + 50;

% searching for the CMT filename
datechar = char(dt_origin);
monthname = lower(datechar(6:8));
fname = sprintf('%s%02d.ndk', monthname, mod(dt_origin.Year, 100));

% get the moment tensor
try
    [quake,Mw] = readCMT(fname, strcat(getenv('IFILES'),'CMT'), tbeg, tend, ...
        mblo, mbhi, depmin, depmax);
catch
    quake = [];
    Mw = [];
end
if size(Mw,1) > 1
    fprintf('size(Mw,1) > 1\n');
end

% draws a moment tensor
if isempty(loc)
    loc = [mod(event.PreferredLongitude,360), ...
        event.PreferredLatitude];
end

if ~isempty(quake) && size(Mw,1) == 1
    M = quake(5:end);
    r = (ax.XLim(2) - ax.XLim(1)) / 50;   % radius of the beachball
    focalmech(ax, M, loc(1), loc(2), r, 'b');
else
    scatter(ax, loc(1), loc(2), 100, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
end
end