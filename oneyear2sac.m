function oneyear2sac(ofile, vfile, sacfile, fs)
% ONEYEAR2SAC(ofile, vfile, sacfile, fs)
% 
% Writes binary (not alphanumeric SAC file from a oneyear file.
%
% INPUT:
% ofile         Fullfile name of the oneyear file
% vfile         vit file of the MERMAID
% sacfile       Fullfile name of the output (SAC) file
% fs            sampling rate [default: 40.01406 Hz]
%
% OUTPUT:
% The SAC file saved at sacfile directory
%
% SEE ALSO:
% WRITESAC, READSAC, MAKEHDR
%
% Last modified by Sirawich Pipatprathanporn, 10/23/2020


defval('fs', 40.01406);
[x, dt_begin, dt_end] = readOneYearData(ofile, fs);

% read vit file
T = readvit(vfile);
dt = T.Date + T.Time;
dt.TimeZone = 'UTC';
dt.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';

% find latest known position before
dt_M1 = interp1(dt, dt, dt_begin, 'previous');
stlo_M1 = T.stlo(dt == dt_M1);
stla_M1 = T.stla(dt == dt_M1);

% find first known position after
dt_M2 = interp1(dt, dt, dt_end, 'next');
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
HdrData.B = 0;
HdrData.E = (size(x,1) - 1) / fs;
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
HdrData.STLA = badval;
HdrData.STLO = badval;
HdrData.STEL = badval;
HdrData.STDP = badval;
HdrData.EVLA = badval;
HdrData.EVLO = badval;
HdrData.EVEL = badval;
HdrData.EVDP = badval;
HdrData.MAG = badval;
HdrData.USER0 = seconds(dt_begin - dt_M1);
HdrData.USER1 = stla_M1;
HdrData.USER2 = stlo_M1;
HdrData.USER3 = seconds(dt_M2 - dt_end);
HdrData.USER4 = stla_M2;
HdrData.USER5 = stlo_M2;
HdrData.USER6 = badval;
HdrData.USER7 = badval;
HdrData.USER8 = badval;
HdrData.USER9 = badval;
HdrData.DIST = badval;
HdrData.AZ = badval;
HdrData.BAZ = badval;
HdrData.GCARC = badval;
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
HdrData.NZYEAR = dt_begin.Year;
HdrData.NZJDAY = datenum(dt_begin.Year, dt_begin.Month, dt_begin.Day) ...
    - datenum(dt_begin.Year, 1, 0);
HdrData.NZHOUR = dt_begin.Hour;
HdrData.NZMIN = dt_begin.Minute;
HdrData.NZSEC = floor(dt_begin.Second);
HdrData.NZMSEC = (dt_begin.Second - floor(dt_begin.Second)) * 1000;
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

HdrData.KUSER2 = badalpha;

HdrData.KCMPNM = 'PRESSURE';

HdrData.KNETWK = 'MERMAID';

HdrData.KDATRD = badalpha;

HdrData.KINST = 'MERMAID';



writesac(x, HdrData, sacfile);
end