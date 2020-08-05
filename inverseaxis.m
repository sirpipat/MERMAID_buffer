function inverseaxis(axis, label)
% INVERSEAXIS(axis, label)
%
% inverse the axis labels
% For example:
% axis label = [1 2 4 8]
% inverse axis label = [1 0.5 0.25 0.125]
%
% INPUT:
% axis      axis object to invert
% label     label for the inverted axis
%
% OUTPUT:
% none (axis object will be modified)
%
% Last modified by Sirawich Pipatprathanporn: 08/04/2020

axis.Label.String = label;
new_labels = {};
for ii = 1:length(axis.TickLabels)
    label_str = string(axis.TickLabels{ii});
    value = str2double(label_str);
    
    % check if the value is a number or not
    if isnan(value)
        % assume '10^{%d}' format where %d is an integer
        d = str2double(erase(erase(label_str, "10^{"), "}"));
        new_labels{ii} = sprintf('10^{%d}', -d);
    else
        new_labels{ii} = sprintf('%.3g',1/value);
    end
end
axis.TickLabels = new_labels;
end
