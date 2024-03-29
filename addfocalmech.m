function addfocalmech(ax, loc, option, info, s, varargin)
% ADDFOCALMECH(ax, loc, option, info, s, varargin)
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
% s             size of the beachball [default: 25]
% varargin      optional arguments for FOCALMECH
%
% This function updates the target axes, ax.
%
% SEE ALSO:
% READCMT, FOCALMECH, IRISFETCH, GETFOCALMECH
%
% Last modified by sirawich-at-princeton.edu, 03/15/2023

defval('s', 25)

% set the default color to blue to conform with the expected output of the
% previous versions
if isempty(varargin)
    varargin = {'b'};
end

% get the moment tensor
try
    [quake,Mw] = getfocalmech(option, info);
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
    r = (ax.XLim(2) - ax.XLim(1)) * s / 625;   % radius of the beachball
    focalmech(ax, M, loc(1), loc(2), r, varargin{:});
else
    scatter(ax, loc(1), loc(2), s * 4, 'Marker', 'p', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
end
end