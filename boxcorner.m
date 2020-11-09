function [x, y] = boxcorner(x_lim, y_lim)
% [x, y] = BOXCORNER(x_lim, y_lim)
% Returns the coordinates of the box's corners given the x-limit and
% y-limit of the box.
% 
% INPUT
% x_lim     x-limit of the box
% y_lim     y-limit of the box
%
% OUTPUT
% x         x-coordinates of the box's corner
% y         y-coordinates of the box's corner
%
% EXAMPLE
% [x, y] = boxcorner([2 5], [1 3]);
% plot(x, y);
% xlim([1 6]);
% ylim([0 4]);
%
% (2,3) +--------------------+ (5,3)
%       |                    |
%       |                    |
%       |                    |
% (2,1) +--------------------+ (5,1)
%
% Last modified by Sirawich Pipatprathanporn, 11/09/2020

x = x_lim([1 2 2 1 1]);
y = y_lim([1 1 2 2 1]);
end