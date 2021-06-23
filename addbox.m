function axb = addbox(ax,norm_position)
% axb = ADDBOX(ax, norm_position)
% Adds a box into a plot. It makes an axes handling the box the current
% axes.
%
% INPUT
% ax                axes to put a box inside
% norm_position     normalized position of the box inside the axes
%                   [left bottom width height]
%
% OUTPUT
% axb               axes handling the box
%
% Last modified by Sirawich Pipatprathanporn: 06/22/2021

% invoke the axes
axes(ax)

% create an empty box
axb = axes();

left = ax.Position(1);
bot = ax.Position(2);
width = ax.Position(3);
height = ax.Position(4);

b_left = norm_position(1);
b_bot = norm_position(2);
b_width = norm_position(3);
b_height = norm_position(4);

% resize the box
axb.Position = [left + b_left * width, ...
                bot + b_bot * height, ...
                b_width * width, ...
                b_height * height];

% create the box's boundary
axb.Box = 'on';
axb.BoxStyle = 'full';
axb.XTick = [];
axb.YTick = [];
end