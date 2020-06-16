function [trigs,dtrigs] = pickpeaks(x,fs,tr,dtr,bufwin)

t = (0:length(x)-1) / fs;
t_above_tr = x > tr;
t_above_dtr = x > dtr;

% locate trigs and drigs
trigs = t(t_above_tr - circshift(t_above_tr,1) > 0) - bufwin;
dtrigs = t(t_above_dtr - circshift(t_above_dtr,1) < 0) + bufwin;

% set out-of-bound values to the bound
trigs(trigs < t(1)) = t(1);
dtrigs(dtrigs > t(end)) = t(end);


if and(isempty(trigs), ~isempty(dtrigs)) && dtrigs(1) < trigs(1)
    dtrigs = dtrigs(2:end);
end
if and(~isempty(trigs), isempty(dtrigs)) && trigs(end) > dtrigs(end)
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
end