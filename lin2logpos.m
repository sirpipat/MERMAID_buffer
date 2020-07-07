function logpos = lin2logpos(linval,minval,maxval)
% logpos = LIN2LOGPOS(linval,minval,maxval)
% Maps value to a proper position on the plot where the coordinate is
% linear, but the label is logarithmic, mainly used in SPECDENSPLOT_HEATMAP
% (log version).
%
% INPUT
% linval        orignal, linear value
% minval        minimum value of logarithmic spaced sequence
% maxval        maximum value of logarithmic spaced sequence
%
% OUTPUT
% logpos        logarithmic position on the plot
%
% SEE ALSO
% SPECDENSPLOT_HEATMAP
%
% Last modified by Sirawich Pipatprathanporn: 07/07/2020

logpos = log10(linval / minval) * maxval / log10(maxval / minval);
end