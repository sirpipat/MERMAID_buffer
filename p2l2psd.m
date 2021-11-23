function psd = p2l2psd(p2l, lat)
% psd = P2L2PSD(p2l, lat)
%
% Converts P2L to PSD. LAT can be either a scalar or a vector. If LAT is a
% vector, P2L has to be a multi-dimentional (>=2) array with latitude
% describing the second index. In other words, size(P2L,2) == length(LAT).
%
% INPUT:
% p2l       frequency spectrum of the second order pressure
% lat       latitude(s) in degrees
%
% OUTPUT:
% psd       power spectral density
%
% SEE ALSO:
% READP2L
%
% Last modified by sirawich-at-princeton.edu, 11/23/2021

% validate the input
if size(p2l, 2) ~= length(lat)
    error('size(P2L,2) must be equal to length(LAT)');
end

% make sure that the latitude is a row vector
if size(lat, 2) == 1
    lat = lat';
end

% convert P2L to spectral density 
% (in Pa^2 m^2 s +1E-12) by 10 .^ P2L
sd = 10 .^ p2l;

% multiply 1E12 to remove +1E-12 in the unit
sd = sd * 1e12;

% multiply (4E-4)^2 to remove a scale factor associated with the pressure
sd = sd * (4e-4) ^ 2;

% divide the area by 0.5x0.5 degrees rectangle converted to squared meters
R = 6371000;
A = (0.5 * pi / 180 * R) ^ 2 .* cos(lat * pi / 180);
sd = sd ./ A;

% convert to PSD (in decibels)
psd = 10 * log10(sd);
end