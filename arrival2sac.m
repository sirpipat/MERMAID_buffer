function arrival2sac(arrival, stlo, stla, arrival_type, endtime, fs, vfile, sacfile)
% ARRIVAL2SAC(arrival, stlo, stla, arrival_type, endtime, fs, vfile, sacfile)
%
% Finds the best known event candidate from a picked arival time. Then, 
% writes a sacfile containing a seismogram starting at 5 minutes before the
% origin time to the specified endtime. The header contains information of
% the event location, origin time, magnitude type, magnitude value, station
% location, and arrival times associated with phase names. This code is
% designed specifically for MERMAID. The SAC file is saved to $SFILES
% directory.
%
% INPUT
% arrival       picked arrival time
% stlo          station longitude [default: MERMAID P023 longitude]
% stla          station latitude  [default: MERMAID P023 latitude]
% arrival_type  either 'body' or 'surface' [default: 'body']
% endtime       the endtime of the seismogram
% fs            sampling rate     [default: 40.01406]
% vfile         vit file of the MERMAID
% sacfile       SAC filename
% 
% OUTPUT
% SEE ALSO
% ONEYEAR2SAC
%
% Last modified by Sirawich Pipatprathanporn, 01/31/2021

defval('fs', 40.01406)
defval('vitfile','/Users/sirawich/research/raw_data/metadata/vit/P023_all.txt')

% figure out stlo and stla from P023 position if they are not specified
if or(isempty(stlo), isempty(stla))
    [stlo,stla] = mposition(arrival);
end

%% find best match events
evs = findevents(arrival, stlo, stla, arrival_type);
% best match : highest magnitude
if isempty(evs)
    fprintf('No match. Exit.\n');
    return
end
ev_best = evs(1);
ev_index = 1;
while ev_index < length(evs)
    ev_index = ev_index + 1;
    if evs(ev_index).PreferredMagnitudeValue > ev_best.PreferredMagnitudeValue
        ev_best = evs(ev_index);
    end
end

% reject the match if the magnitude is below 4.0
if ev_best.PreferredMagnitudeValue < 4.0
    fprintf('No match. Exit.\n');
    return
end

%% read the buffer
% read a section from 5 minutes before the arrival time to the end of the
% section
dt_origin = datetime(ev_best.PreferredTime,...
   'TimeZone','UTC','Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS');

[sections, intervals] = getsections(getenv('ONEYEAR'), ...
                                    dt_origin - minutes(5), ...
                                    endtime, ...
                                    fs);
% determine the proper section
proper_section_no = 1;
while and(arrival > intervals{proper_section_no}{2}, ...
          proper_section_no < length(sections))
    proper_section_no = proper_section_no + 1;
end
% read the section
[x, dt_B, dt_E] = readsection(sections{proper_section_no}, ...
                              intervals{proper_section_no}{1}, ...
                              intervals{proper_section_no}{2}, ...
                              fs);

%% write into a SAC file

% read vit file
T = readvit(vfile);
dt = T.Date + T.Time;
dt.TimeZone = 'UTC';
dt.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

% find latest known position before
dt_M1 = interp1(dt, dt, dt_B, 'previous');
stlo_M1 = T.stlo(dt == dt_M1);
stla_M1 = T.stla(dt == dt_M1);

% find first known position after
dt_M2 = interp1(dt, dt, dt_E, 'next');
stlo_M2 = T.stlo(dt == dt_M2);
stla_M2 = T.stla(dt == dt_M2);

% -------- SAC HEADER ---------
badval = -12345;
badalpha = '-12345..';

% ----- floats -----
HdrData = makehdr;
HdrData.DELTA = 1 / fs;
HdrData.DEPMIN = badval;
HdrData.DEPMAX = badval;
HdrData.SCALE = badval;
HdrData.ODELTA = 1 / fs;
HdrData.B = seconds(dt_B - dt_origin);
HdrData.E = seconds(dt_B - dt_origin) + (size(x,1) - 1) / fs;
HdrData.O = badval;
HdrData.A = badval;
HdrData.INTERNAL = badval;
HdrData.T0 = badval;
HdrData.T1 = badval;
HdrData.T2 = badval;
HdrData.T3 = badval;
HdrData.T4 = badval;
HdrData.T5 = badval;
HdrData.T6 = badval;
HdrData.T7 = badval;
HdrData.T8 = badval;
HdrData.T9 = badval;
HdrData.F = badval;
HdrData.RESP0 = badval;
HdrData.RESP1 = badval;
HdrData.RESP2 = badval;
HdrData.RESP3 = badval;
HdrData.RESP4 = badval;
HdrData.RESP5 = badval;
HdrData.RESP6 = badval;
HdrData.RESP7 = badval;
HdrData.RESP8 = badval;
HdrData.RESP9 = badval;
HdrData.STLA = stla;
HdrData.STLO = stlo;
HdrData.STEL = badval;
HdrData.STDP = badval;
HdrData.EVLA = ev_best.evla;
HdrData.EVLO = ev_best.evlo;
HdrData.EVEL = badval;
HdrData.EVDP = ev_best.PreferredDepth;
HdrData.MAG = ev_best.PreferredMagnitudeValue;
HdrData.USER0 = seconds(dt_B - dt_M1);
HdrData.USER1 = stla_M1;
HdrData.USER2 = stlo_M1;
HdrData.USER3 = seconds(dt_M2 - dt_E);
HdrData.USER4 = stla_M2;
HdrData.USER5 = stlo_M2;
HdrData.USER6 = str2double(ev_best.id);
HdrData.USER7 = badval;
HdrData.USER8 = badval;
HdrData.USER9 = badval;
HdrData.DIST = badval;
HdrData.AZ = badval;
HdrData.BAZ = badval;
HdrData.GCARC = ev_best.distance;
HdrData.SB = badval;
HdrData.SDELTA = badval;
HdrData.DEPMEN = badval;
HdrData.CMPAZ = badval;
HdrData.CMPINC = badval;
HdrData.XMINIMUM = badval;
HdrData.XMAXIMUM = badval;
HdrData.YMINIMUM = badval;
HdrData.YMAXIMUM = badval;
HdrData.ADJTM = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
% ----- int -----
HdrData.NZYEAR = dt_origin.Year;
HdrData.NZJDAY = datenum(dt_origin.Year, dt_origin.Month, dt_origin.Day) ...
    - datenum(dt_origin.Year, 1, 0);
HdrData.NZHOUR = dt_origin.Hour;
HdrData.NZMIN = dt_origin.Minute;
HdrData.NZSEC = floor(dt_origin.Second);
HdrData.NZMSEC = (dt_origin.Second - floor(dt_origin.Second)) * 1000;
HdrData.NVHDR = 6;
HdrData.NORID = badval;
HdrData.NEVID = badval;
HdrData.NPTS = size(x,1);
HdrData.NSNPTS = badval;
HdrData.NWFID = badval;
HdrData.NXSIZE = badval;
HdrData.NYSIZE = badval;
%HdrData.UNUSED = badval;
HdrData.IFTYPE = 1;
HdrData.IDEP = 1;
HdrData.IZTYPE = 2;
%HdrData.UNUSED = badval;
HdrData.IINST = badval;
HdrData.ISTREG = badval;
HdrData.IEVREG = badval;
HdrData.IEVTYP = badval;
HdrData.IQUAL = badval;
HdrData.ISYNTH = badval;
HdrData.IMAGTYP = badval;
HdrData.IMAGSRC = badval;
HdrData.IBODY = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
%HdrData.UNUSED = badval;
% ----- logical -----
HdrData.LEVEN = 1;
HdrData.LPSPOL = badval;
HdrData.LOVROK = badval;
HdrData.LCALDA = badval;
%HdrData.UNUSED = badval;
% ----- alphanumeric -----
HdrData.KSTNM = 'P023';

HdrData.KEVNM = strcat(badalpha, badalpha);

HdrData.KO = badalpha;

HdrData.KA = badalpha;

HdrData.KHOLE = badalpha;

HdrData.KT0 = badalpha;

HdrData.KT1 = badalpha;

HdrData.KT2 = badalpha;

HdrData.KT3 = badalpha;

HdrData.KT4 = badalpha;

HdrData.KT5 = badalpha;

HdrData.KT6 = badalpha;

HdrData.KT7 = badalpha;

HdrData.KT8 = badalpha;

HdrData.KT9 = badalpha;

HdrData.KF = badalpha;

HdrData.KUSER0 = 'PGPST0-2';

HdrData.KUSER1 = 'NGPST3-5';

HdrData.KUSER2 = 'EventID6';

HdrData.KCMPNM = 'PRESSURE';

HdrData.KNETWK = 'MERMAID';

HdrData.KDATRD = badalpha;

HdrData.KINST = 'MERMAID';

% add arrival time of each phase
for ii = 1:length(ev_best.expArrivalTime)
    switch ii
        case 1
            HdrData.T0 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT0 = ev_best.phase{ii};
        case 2
            HdrData.T1 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT1 = ev_best.phase{ii};
        case 3
            HdrData.T2 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT2 = ev_best.phase{ii};
        case 4
            HdrData.T3 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT3 = ev_best.phase{ii};
        case 5
            HdrData.T4 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT4 = ev_best.phase{ii};
        case 6
            HdrData.T5 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT5 = ev_best.phase{ii};        
        case 7
            HdrData.T6 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT6 = ev_best.phase{ii};
        case 8
            HdrData.T7 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT7 = ev_best.phase{ii};
        case 9
            HdrData.T8 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT8 = ev_best.phase{ii};
        case 10
            HdrData.T9 = seconds(ev_best.expArrivalTime(ii) - dt_origin);
            HdrData.KT9 = ev_best.phase{ii};
        otherwise
            fprintf('The number of phases exceeds the number of available time slots.\n');
            break
    end
end

writesac(x, HdrData, strcat(getenv('SFILES'), sacfile));
end