function [trigs,dtrigs,ratio] = pickpeaks(x,fs,tr,dtr,bufwin)
% [trigs,dtrigs,ratio] = PICKPEAKS(x,fs,tr,dtr,bufwin)
% identifies the peaks' locations
%
% Algorithm: makes all samples in the signal (x) positive. Then,
% approximate local background level as if peaks are absent. Normalize the
% signal with the background level to see the relative height of the peaks
% relative to the background level.
%
% INPUT
% x         signal (normalized by the average)
% fs        sampling rate
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
% Last modified by Sirawich Pipatprathanporn: 06/29/2020

% make all values positive
x = abs(x);

% time from the beginning of each sample
t = (0:length(x)-1) / fs;

% reference level of x as if the peaks are absent
x_ref = movmean(x, round(fs * 10800));
x_copy = x;
for ii = 1:2
    x_copy(x_copy ./ x_ref > 1) = 1 * x_ref(x_copy ./ x_ref > 1);
    x_ref_new = movmean(x_copy, round(fs * 18000));
    x_ref = x_ref_new;
end

ratio = x ./ x_ref;
t_above_tr = ratio > tr;
t_above_dtr = ratio > dtr;

% locate trigs and drigs
trigs = t(t_above_tr - circshift(t_above_tr,1) > 0) - bufwin;
dtrigs = t(t_above_dtr - circshift(t_above_dtr,1) < 0) + bufwin;

if t_above_tr(1)
    trigs = trigs(2:end);
    dtrigs = dtrigs(2:end);
end

% set out-of-bound values to the bound
trigs(trigs < t(1)) = t(1);
dtrigs(dtrigs > t(end)) = t(end);

if ~isempty(dtrigs) && (isempty(trigs)|| dtrigs(1) < trigs(1))
    dtrigs = dtrigs(2:end);
end
if ~isempty(trigs) && (isempty(dtrigs) || trigs(end) > dtrigs(end))
    dtrigs = [dtrigs, t(end)];
end

% check if trig-dtrig windows overlap each other
for ii = 1:length(trigs)-1
    if dtrigs(ii) > trigs(ii+1)
        dtrigs(ii) = NaN;
        trigs(ii+1) = NaN;
    end
end
trigs = trigs(~isnan(trigs));
dtrigs = dtrigs(~isnan(dtrigs));

% add dtrigs at the end if original dtrigs is beyond the section
if length(trigs) - length(dtrigs) == 1
    dtrigs = [dtrigs, t(end)];
end
end