function [A, B, C, xest, F, P] = sinefit(t, x, w, f)
% [A, B, C, xest, F, P] = SINEFIT(t, x, w, f)
%
% Determines the least-square solution (overdetermined) or
%            the least-norm   solution (underdetermined) for the equation 
%                   N
% x(t) = sqrt(2) * sum [A(n) * sin(2*pi*f(n)*t) + B(n) * cos(2*pi*f(n)*t)] + C
%                  n=1
% where N is the number of frequencies
%
% INPUT
% t         time
% x         signal
% w         window
% f         target frequencies
%
% OUTPUT
% A         coefficients of sine terms
% B         coefficients of cosine terms
% C         coefficient  of steady-state term
% xest      estimated signal from best-fit coefficients
% F         sorted frequencies for PSD (equivalent to [0 sort(f)])
% P         power spectral density
%
% Last modified by Sirawich Pipatprathanporn, 12/08/2020

defval('w', ones(size(x)))

% convet all input vectors to row vectors
if size(t, 1) > 1
    t = t';
end
if size(x, 1) > 1
    x = x';
end
if size(w, 1) > 1
    w = w';
end
if size(f, 1) > 1
    f = f';
end
%% inversion for A, B, and C
% sorts frequencies
f = sort(f);

% number of frequencies to fit
n = length(f);

% forward matrix
G = [sqrt(2) * sin(2 * pi * f' * t)', sqrt(2) * cos(2 * pi * f' * t)', ...
    ones(size(t))'];
% inversion for model parameters A,B,C
m = geninverse(G) * (x .* w)';
A = m(1:n)';
B = m((n+1):(2*n))';
C = m(end);

% computes the estimation of the data given the model parameters
xest = G * m;
%% power spectral density
dt = (max(t) - min(t)) / (length(t) - 1);
N = length(t);

F = [0 f];
P = ([C sqrt(A.^2 + B.^2)] .^ 2);
end