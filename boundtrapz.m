function val = boundtrapz(x, y, xmin, xmax)
% val = BOUNDTRAPZ(x, y, xmin, xmax)
% calculates the integral of y = f(x) from [xmin xmax] using trapezoidal
% method.
%
% INPUT
% x         row vector of coordinates
% y         f(x) or a set of f(x)'s
% xmin      lower bound of integration
% xmax      upper bound of integration
%
% OUTOUT
% val       approximate integral of y via the trapezoidal method
%
% SEE ALSO
% TRAPZ
% Last modified by Sirawich Pipatprathanporn: 07/14/2020

xlist = [xmin, x(and(x >= xmin, x <= xmax)),xmax];
ylist = interp1(x, y, xlist);
val = trapz(xlist, ylist, 2);
end