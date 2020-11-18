function T = axeslabel(ax, x_norm, y_norm, str, varargin)
% T = AXESLABEL(ax, xnorm, ynorm, str, varargin)
%
% Adds a label into a figure.
%
% INPUT
% ax            axes of interest
% x_norm        normalized x cooridnate on the axes
% y_norm        normalized y cooridnate on the axes
% str           text to be added
% varargin      input options for TEXT
%
% OUTPUT
% T             text object: use T to modify properties of the text
%
% SEE ALSO
% NORM2TRUEPOSITION, TEXT
%
% Last modified by Sirawich Pipatprathanporn, 11/14/2020

[x, y] = norm2trueposition(ax, x_norm, y_norm);
axes(ax);
T = text(x,y,str,varargin{:});
end