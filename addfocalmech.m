function addfocalmech(ax, options)
% ADDFOCALMECH(ax, option, info)
%
% Looks up for a full moment tensor of a specified earthquake and draws a 
% full moment tensor beachball diagram to a plot. If no moment tensor is
% found, a pentagram will be added in place of the beachball. The file(s)
% to monthly moment tensor catalogs have to be located at $IFILES/CMT/.
%
% INPUT:
% ax            target axes to plot
% option        type of information to supply: either one of these
%                   'PublicID'
%                   'Event'
% info          information for the given option
%                   - for 'PublicID', the info is an integer representing
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
% Last modified by sirawich-at-princeton.edu, 09/03/2021

arguments
    ax                  (1,1) matlab.graphics.axis.Axes
    options.PublicID    (1,1) double
    options.Event       (1,1) struct
end

if ~isempty(options.PublicID)
    event = irisFetch.Events('eventID', options.PublicID);
elseif ~isempty(options.Event)
    event = options.Event;
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
[quake,Mw] = readCMT(fname, strcat(getenv('IFILES'),'CMT'), tbeg, tend, ...
    mblo, mbhi, depmin, depmax);
if size(Mw,1) > 1
    fprintf('size(Mw,1) > 1\n');
end

% draws a moment tensor
if ~isempty(quake) && size(Mw,1) == 1
    M = quake(5:end);
    r = (ax3.XLim(2) - ax3.XLim(1)) / 18;   % radius of the beachball
    focalmech(ax, M, mod(event.PreferredLongitude,360), ...
        event.PreferredLatitude, r, 'b');
else
    scatter(ax, mod(event.PreferredLongitudeo,360), ...
        event.PreferredLatitude, 100, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
end
end