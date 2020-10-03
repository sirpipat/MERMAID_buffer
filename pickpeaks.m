function [trigs,dtrigs,ratio] = pickpeaks(x,fs,str,ltr,tr,dtr,bufwin)
% [trigs,dtrigs,ratio] = PICKPEAKS(x,fs,str,ltr,tr,dtr,bufwin)
% Identifies the peaks' locations in the signal. It is an alternative to
% STA/LTA algorithm to find arrivals in the signal. However, this one is
% not designed for automatic detection of earthquake arrivals. Instead, the
% goal is to identify the peaks and remove them from the signal.
%
% Algorithm: compute short-term moving rms of x. Then, using the moving rms
% to approximate local background level (long-term) as if peaks are absent. 
% Normalize the moving rms with the background level to see the relative 
% height of the peaks relative to the background level.
%
% INPUT
% x         signal
% fs        sampling rate
% str       short-term moving rms window length
% ltr       long-term moving rms (reference) window length
% tr        trigger value
% dtr       detrigger value
% bufwin    time buffer added to beginning and end of the section
%
% OUTPUT
% trigs     vector of trigger points in seconds
% dtrigs    vector of detrigger points in seconds
% ratio     adjusted ratio used for determining trigger and detrigger
%           points
%
% SEE ALSO
% STALTA
%
% Last modified by Sirawich Pipatprathanporn: 10/02/2020

defval('str',60)
defval('ltr',10800)
defval('tr',1.5)
defval('dtr',1.5)
defval('bufwin',60)

% short-term moving rms normalized by the overall rms
x_sq = x .^ 2;
x_str = (movmean(x_sq, round(fs * str)) .^ 0.5) / 1;

% time from the beginning of each sample
t = (0:length(x_str)-1) / fs;

% long-term window cannot be longer the signal
ltr = min(t(end), ltr);

% reference level of x as if the peaks are absent
x_ref = movmean(x_str, round(fs * ltr));
x_copy = x_str;
for ii = 1:2
    x_copy(x_copy ./ x_ref > 1) = 1 * x_ref(x_copy ./ x_ref > 1);
    x_ref_new = movmean(x_copy, round(fs * ltr));
    x_ref = x_ref_new;
end

ratio = x_str ./ x_ref;
t_above_tr = ratio > tr;
t_above_dtr = ratio > dtr;

% locate trigs and drigs
trigs = t([t_above_tr(1); t_above_tr(2:end) - t_above_tr(1:end-1)] > 0) - bufwin;
dtrigs = t([t_above_dtr(1); t_above_dtr(2:end) - t_above_dtr(1:end-1)] < 0) + bufwin;

% remove the trigger at the beginning (first sample)
if t_above_tr(1)
    trigs = trigs(2:end);
    dtrigs = dtrigs(2:end);
end

% set out-of-bound values to the bound
trigs(trigs < t(1)) = t(1);
dtrigs(dtrigs > t(end)) = t(end);

% add dtrigs = t(end) if the detrigger of the last peak is beyond the end
if t_above_dtr(end)
    dtrigs = [dtrigs, t(end)];
end

% simplify overlapping trig-dtrig windows
[trigs, dtrigs] = simplifyintervals(trigs, dtrigs);

% add dtrigs at the end if original dtrigs is beyond the section
if length(trigs) - length(dtrigs) == 1
    dtrigs = [dtrigs, t(end)];
end
end