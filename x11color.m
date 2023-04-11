function c = x11color(name, c1, c2)
% c = X11COLOR(name, color1, color2)
%
% Returns rgb color triplet given a X11 color name. See the list of color
% at https://gitlab.freedesktop.org/xorg/app/rgb/raw/master/rgb.txt
%
% INPUT
% name      Name of defined X11 color e.g. 'red' or 'Lime'. If the color
%           name is not found, it will call RGBCOLOR(name).
%
%           Call X11COLOR('list') to see the list of colors. 
%           Call X11COLOR('find', COLOR1, COLOR2) to see the list of colors
%           closest to COLOR1 with a preference towards COLOR2
%
% color1    RGB triplet of the starting color for 'find' option
% color2    RGB triplet of the preference color for 'find' option
%           [default: color1]
%
% OUTPUT
% c         RGB triplet
%
% EXAMPLE
% % get a salmon color
% c = x11color('salmon');
% x = 1:10;
% plot(x,x.^2,'Color',c)
%
% % print the list of defined color
% x11color('list');
%
% % see what color that is close to salmon and a bit more red
% x11color('find', csscolor('salmon'), [1 0 0]);
%
% SEE ALSO
% RGBCOLOR, CSSCOLOR
%
% Last modified by sirawich-at-prineton.edu: 04/11/2023

defval('name', 'list')

% loop through cell array
if iscell(name)
    c = nan(length(name), 3);
    for ii = 1:length(name)
        if ~strcmpi(name{ii}, 'list')
            try
                c(ii, :) = x11color(name{ii});
            catch ME
                switch ME.identifier
                    case 'x11color:datatype'
                        warning('[color #%d] Name must be a string or char cell', ii)
                    case 'rgbcolor:namenotfound'
                        warning('[color #%d] Color name not found. Try x11color(''list'')', ii)
                    otherwise
                        rethrow(ME)
                end
                continue
            end
        end
    end
    return
end

% validate the input
if isstring(name)
    name = char(name);
end
if ~ischar(name)
    errorStruct.message = 'name must be a string or char cell';
    errorStruct.identifier = 'x11color:datatype';
    error(errorStruct)
end

% Make sure you have downloaded rgb.txt from 
% https://gitlab.freedesktop.org/xorg/app/rgb/raw/master/rgb.txt
% and store at $IFILES/COLORLISTS/
colorfile = fullfile(getenv('IFILES'), 'COLORLISTS', 'rgb.txt');

% read the color list
color_cell = {};
fid = fopen(colorfile);
l = fgetl(fid);
while ischar(l)
    % remove the leading/trailing whitespaces
    l = strtrim(l);
    color = sscanf(l, '%d')';
    cname = char(join(indeks(split(string(l)), '4:end')));
    chex  = sprintf('#%s', dec2hex(color, 2)');
    color_cell{end+1} = cname;
    color_cell{end+1} = color / 255;
    color_cell{end+1} = chex;
    l = fgetl(fid);
end
fclose(fid);

% length for listing colors
len = length(color_cell);
if strcmpi(name, 'find')
    defval('c2', c1)
    c2 = c1 + 0.8 * (c2 - c1);
    % distance from one color to another
    d = nan(1, length(color_cell)/3);
    for ii = 2:3:length(color_cell)
        c0 = color_cell{ii};
        jj = (ii + 1) / 3;
        d(jj) = norm(c0 - c1) + norm(c0 - c2);
    end
    % sort
    [~, ic] = sort(d);
    color_cell = color_cell(reshape((ic * 3 + (-2:0)'), [1 numel(ic)*3]));
    name = 'list';
    len = 60;
    fprintf('Listing first %d colors\n', len/3);
end

if strcmpi(name, 'list')
    % print the listed colors
    fprintf('-----------------------------------------------------------\n');
    fprintf('          name          = [  R      G      B   ] , hexcode \n');
    fprintf('-----------------------------------------------------------\n');
    for ii = 1:3:len                                                     
        fprintf('%23s = [%.4f %.4f %.4f] , %s\n', ...
            cell2commasepstr(color_cell(ii)), ...          
            indeks(color_cell{ii+1},1), ...
            indeks(color_cell{ii+1},2), ...
            indeks(color_cell{ii+1},3), ...
            color_cell{ii+2});
    end
    fprintf('-----------------------------------------------------------\n');
    fprintf(' see also: rgbcolor(''list'')\n');
    fprintf('-----------------------------------------------------------\n');
elseif any(strcmpi(name, {'random', 'any'}))
    idx = randi([1 length(color_cell)/3]);
    fprintf('COLOR = %s\n', upper(color_cell{3 * idx - 2}));
    c = color_cell{3 * idx - 1};
else
    % check the predefined colors
    for ii = 1:3:length(color_cell)
        if any(strcmpi(color_cell{ii}, name))
            c = color_cell{ii+1};
            return
        end
    end
    % if the name is undefined, check the color in rgbcolor.m
    fprintf('CALLING RGBCOLOR(''%s'') ...\n', name);
    c = rgbcolor(name);
end
end