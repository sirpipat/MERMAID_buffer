function axb = boxedlabel(ax, corner, w, unit, str, varargin)
% axb = BOXEDLABEL(ax, corner, w, unit, str, varargin)
% Adds a boxed axes label to a corner.
%
% INPUT
% ax        target axes
% corner    which corner to add a boxed label. Opitions include
%           'northwest', 'northeast', 'southwest', and 'southeast'
% w         width of the squre box
% unit      unit of the width of the box ('norm' or [], if [], it will use 
%           the unit of the figure.)
% str       the label in the box
%
% OUTPUT
% axb       axes handle of the box
%
% SEE ALSO
% ADDBOX, AXESLABEL
%
% Last modified by sirawich@princeton.edu: 07/02/2021

% invoke the axes
axes(ax)

% if w is in a normalized unit, then just scale to the axes position
if strcmp(unit, 'norm')
    norm_width = w / ax.Position(3);
    norm_height = w / ax.Position(4);
% otherwise, normalize first by dividing the dimension of the figure
else
    fig = ax.Parent;
    norm_width = w / fig.Position(3) / ax.Position(3);
    norm_height = w / fig.Position(4) / ax.Position(4);
end

% compute the norm position of the box
switch corner
    case 'northwest'
        norm_left = 0;
        norm_bottom = 1 - norm_height;
    case 'northeast'
        norm_left = 1 - norm_width;
        norm_bottom = 1 - norm_height;
    case 'southwest'
        norm_left = 0;
        norm_bottom = 0;
    case 'southeast'
        norm_left = 1 - norm_width;
        norm_bottom = 0;
    otherwise
        error('invalid corner\n');
end

% add the box and the label
axb = addbox(ax, [norm_left norm_bottom norm_width norm_height]);
T = axeslabel(axb, 0.28, 3/5, str, varargin{:});
end