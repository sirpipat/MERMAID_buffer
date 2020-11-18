function [f, gain] = mermaidcurve(fname)
% [f, gain] = MERMAIDCURVE
%
% Read MERMAID gain curve from database.
%
% INPUT
% fname     data filename
%
% OUTPUT
% f         frequency
% gain      MERMAID gain
%
% Last modified by Sirawich Pipatprathanporn, 11/10/2020


defval('fname', strcat('/Users/sirawich/research/raw_data/metadata/', ...
    'mermaid/mermaid_curve.mat'));
s = load(fname);
f = s.f;
gain = s.gain;
end