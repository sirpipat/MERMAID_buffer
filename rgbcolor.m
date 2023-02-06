function c = rgbcolor(name)
% c = RGBCOLOR(name)
%
% Return rgb color triplet given the color name. The list of predefined
% names can be accessed by calling RGBCOLOR('list'). More colors can be
% added to a cell variable COLORCELL_MORE in the file.
%
% INPUT
% name      Name of the color. It can be either
%           1 defined name characters or strings e.g. 'red', 'r', "ReD". 
%             Call rgbcolor('list') to see the list of defined colors 
%           2 Hexadecimal code e.g. 'ff0000' or '#FF0000'
%           3 'random' or 'any' to request for a random color
%           4 Cell array containing any combinations of 1-3
%             e.g. {'yellow', "Green", '#7F7F7F', 'random'}
%
% OUTPUT
% c         RGB triplets
%
% EXAMPLE
% % get a brown color
% c = rgbcolor('brown');
% x = 1:10;
% plot(x,x.^2,'Color',c)
%
% % print the list of defined color
% rgbcolor('list');
%
% % get a random color
% c = rgbcolor('random')
%
% Last modified by Sirawich Pipatprathanporn: 02/06/2023

defval('name', 'list')

% loop through cell array
if iscell(name)
    c = nan(length(name), 3);
    for ii = 1:length(name)
        if ~strcmpi(name{ii}, 'list')
            try
                c(ii, :) = rgbcolor(name{ii});
            catch ME
                switch ME.identifier
                    case 'rgbcolor:datatype'
                        warning('[color #%d] Name must be a string or char cell', ii)
                    case 'rgbcolor:namenotfound'
                        warning('[color #%d] Color name not found. Try rgbcolor(''list'')', ii)
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
    errorStruct.identifier = 'rgbcolor:datatype';
    error(errorStruct)
end

% remove the leading # for hex color code
if name(1) == '#'
    name = name(2:end);
end

%% basic colors
% DO NOT add any new line of color into this variable. If you want to add
% color, define a new color in COLORCELL_MORE instead. However, you may add
% alternative name to existing colors as you please.
colorcell = {
    {'r','red'},             [1 0 0], ...
    {'g','lime'},             [0 1 0], ...
    {'b','blue'},             [0 0 1], ...
    {'c','cyan'},             [0 1 1], ...
    {'m','magenta'},             [1 0 1], ...
    {'y','yellow'},             [1 1 0], ...
    {'k','black'},             [0 0 0], ...
    {'w','white'},         [1 1 1], ...
    {'1'},             [0 0.4470 0.7410], ...
    {'2'},             [0.8500 0.3250 0.0980], ...
    {'3'},             [0.9290 0.6940 0.1250], ...
    {'4'},             [0.4940 0.1840 0.5560], ...
    {'5'},             [0.4660 0.6740 0.1880], ...
    {'6'},             [0.3010 0.7450 0.9330], ...
    {'7'},             [0.6350 0.0780 0.1840], ...
    {'gray','grey'},   [0.5 0.5 0.5], ...
    {'maroon'},        [0.5 0 0], ...
    {'olive'},         [0.5 0.5 0], ...
    {'green'},         [0 0.5 0], ...
    {'pp','purple'},        [0.5 0 0.5], ...
    {'teal'},          [0 0.5 0.5], ...
    {'navy'},          [0 0 0.5], ...
    {'o','orange'},        [1 0.5 0], ...
    {'sg','spring green'},  [0 1 0.5], ...
    {'v','violet'},        [0.5 0 1], ...
    {'lime green'},    [0.5 1 0], ...
    {'deep sky blue'}, [0 0.5 1], ...
    {'hot pink'},      [1 0 0.5]};

%% define more color here
% please follow this format:
% {'colorname_1', 'colorname_2', ...}, [R G B], ... 
colorcell_more = {
    {'silver'},        [0.75 0.75 0.75], ...
    {'br','brown'},    [0.3 0.1 0], ...
    {'my pink'},       [0.8143 0.2435 0.9293], ...
    {'my light green'},[0.15 0.9 0.05], ...
    {'my green'},      [0.4 0.8 0.05], ...
    {'my blue'},       [0.1 0.7 0.9] ...
    };
colorcell = [colorcell, colorcell_more];

%% handle the input
if strcmpi(name, 'list')
    % print the listed colors
    fprintf('---------------------------------------------------\n');
    fprintf('          name   = [  R      G      B   ]          \n');
    fprintf('---------------------------------------------------\n');
    % print basic colors
    for ii = 1:2:16
        fprintf('%16s = [%d %d %d]\n', ...
            cell2commasepstr(colorcell{ii}), ...
            indeks(colorcell{ii+1},1), indeks(colorcell{ii+1},2), ...
            indeks(colorcell{ii+1},3));
    end
    fprintf('---------------------------------------------------\n');
    for ii = 17:2:30
        fprintf('%16s = [%.4f %.4f %.4f]\n', ...
            cell2commasepstr(colorcell{ii}), ...
            indeks(colorcell{ii+1},1), indeks(colorcell{ii+1},2), ...
            indeks(colorcell{ii+1},3));
    end
    fprintf('---------------------------------------------------\n');
    for ii = 31:2:56
        fprintf('%16s = [%.1f %.1f %.1f]\n', ...
            cell2commasepstr(colorcell{ii}), ...
            indeks(colorcell{ii+1},1), indeks(colorcell{ii+1},2), ...
            indeks(colorcell{ii+1},3));
    end
    fprintf('---------------------------------------------------\n');
    % print user-defined colors
    for ii = 57:2:length(colorcell)
        fprintf('%16s = [%.4f %.4f %.4f]\n', ...
            cell2commasepstr(colorcell{ii}), ...
            indeks(colorcell{ii+1},1), indeks(colorcell{ii+1},2), ...
            indeks(colorcell{ii+1},3));
    end
    fprintf('---------------------------------------------------\n');
% random colors
elseif any(strcmpi(name, {'random', 'any'}))
    c = (rand(1,3) * 0.9) + 0.05;
    return
else
    % check if it is hexadecimal code
    try
        c = [hex2dec(name(1:2)) hex2dec(name(3:4)) hex2dec(name(5:6))] / 255;
        return
    catch
    end
    % check the predefined colors
    for ii = 1:2:length(colorcell)
        if any(strcmpi(colorcell{ii}, name))
            c = colorcell{ii+1};
            return
        end
    end
    % if the name is undefined, throw an error
    errorStruct.message = 'color name not found';
    errorStruct.identifier = 'rgbcolor:namenotfound';
    error(errorStruct)
end
end