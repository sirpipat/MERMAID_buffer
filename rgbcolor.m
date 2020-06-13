function c = rgbcolor(name)
% Return rgb color triplet given the color name
%
% INPUT
% name      Name of the color
%
% OUTPUT
% c         RGB triplet
%
% Last modified by Sirawich Pipatprathanporn: 06/12/2020

switch lower(name)
    % predefined MATLAB colors
    case {'r', 'red'}
        c = [1 0 0];
    case {'g', 'lime'}
        c = [0 1 0];
    case {'b', 'blue'}
        c = [0 0 1];
    case {'c', 'cyan'}
        c = [0 1 1];
    case {'m', 'magenta'}
        c = [1 0 1];
    case {'y', 'yellow'}
        c = [1 1 0];
    case {'k', 'black'}
        c = [0 0 0];
    case {'w', 'white'}
        c = [1 1 1];
    % default cyclic colors
    case '1'
        c = [0 0.4470 0.7410];
    case '2'
        c = [0.8500 0.3250 0.0980];
    case '3'
        c = [0.9290 0.6940 0.1250];
    case '4'
        c = [0.4940 0.1840 0.5560];
    case '5'
        c = [0.4660 0.6740 0.1880];
    case '6'
        c = [0.3010 0.7450 0.9330];
    case '7'
        c = [0.6350 0.0780 0.1840];
    % add custom colors here
    case 'silver'
        c = [0.75 0.75 0.75];
    case 'gray'
        c = [0.5 0.5 0.5];
    case 'maroon'
        c = [0.5 0 0];
    case 'olive'
        c = [0.5 0.5 0];
    case 'green'
        c = [0 0.5 0];
    case {'pp', 'purple'}
        c = [0.5 0 0.5];
    case 'teal'
        c = [0 0.5 0.5];
    case 'navy'
        c = [0 0 0.5];
    case {'o', 'orange'}
        c = [1 0.5 0];
    case {'sg', 'spring green'}
        c = [0 1 0.5];
    case {'v', 'violet'}
        c = [0.5 0 1];
    case 'lime green'
        c = [0.5 1 0];
    case 'deep sky blue'
        c = [0 0.5 1];
    case 'hot pink'
        c = [1 0 0.5];
    case {'br', 'brown'}
        c = [0.30 0.10 0];
    case 'my pink'
        c = [0.8143 0.2435 0.9293];
    case 'my light green'
        c = [0.15 0.9 0.05];
    case 'my green'
        c = [0.4 0.8 0.05];
    case 'my blue'
        c = [0.1 0.7 0.9];
    % give me any color
    case {'random', 'any'}
        c = (rand(1,3) * 0.9) + 0.05;
    % if the color name is undefined return black
    otherwise
        c = [0 0 0];
end


end