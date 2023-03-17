function [QUAKES, Mw, CMT] = getfocalmech(option, info)
% [QUAKES, Mw, CMT] = GETFOCALMECH(option, info)
%
% Looks up for a full moment tensor of a specified earthquake. The file(s)
% to monthly moment tensor catalogs have to be located at $IFILES/CMT/.
%
% INPUT:          
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
% OUTPUT:
% QUAKES         [time depth lat lon Mtensor]
% Mw             All the scalar seismic moments
% CMT            A structure for the requested event (if not all)
%                containing the following fields:
%      DateTime       A string containing the time of the even
%                     in the format 'yyyy/mm/dd hh/mm/ss.s'
%      EventName      see INPUT:cmtcode
%      MomentType     The type of moment-rate function. 
%                     BOXHD <-> boxcar; TRIHD <-> triangular
%      HalfDuration   Half the duration of the moment rate function
%      CentroidTime   Offset in seconds w.r.t. DateTime
%      Lat            Centroid Latitude [degrees]
%      Lon            Centroid Longitude [degrees]
%      Dep            Centroid Depth [km]
%      Exp            Moment tensor components are to be multiplied by
%                     to get M in units of dyne/cm 
%      M              M=[Mrr Mtt Mpp Mrt Mrp Mtp] in [dyne cm]
%      Mw             Moment magnitude (Hanks & Kanamori 1979)
%
% SEE ALSO:
% READCMT, FOCALMECH, IRISFETCH, ADDFOCALMECH
%
% Last modified by sirawich-at-princeton.edu, 03/17/2023

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
    [QUAKES, Mw, CMT] = readCMT(fname, strcat(getenv('IFILES'),'CMT'), ...
        tbeg, tend, mblo, mbhi, depmin, depmax);
catch ME
    QUAKES = [];
    Mw     = [];
    CMT    = [];
end
if size(Mw,1) > 1
    fprintf('size(Mw,1) > 1\n');
    fprintf('Choosing based on distance from the centroids to the event\n');
    distKM = zeros(size(Mw));
    for ii = 1:length(distKM)
        distKM(ii) = grcdist([CMT(ii).Lon CMT(ii).Lat], ...
            [event.PreferredLongitude event.PreferredLatitude]);
    end
    [~, I] = min(distKM);
    QUAKES = QUAKES(I);
    Mw = Mw(I);
    CMT = CMT(I);
end
end