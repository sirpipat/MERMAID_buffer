function [t, x] = sinewave(dt, amps, freqs, phases, fs)
% [t, x] = SINEWAVE(dt, amps, freqs, phases, fs)
% Creates sine waves of specified frequencies
%
% INPUT:
% dt        length of the sine waves in seconds
% amp       amplitudes as an array of doubles
% freqs     frequencies as an array of doubles
% phases    initial phases in radians
% fs        sampling frequencies
%
% OUTPUT:
% t         equally-spaced time with sampling frequency of fs
% x         sine waves signal
%
% Last modified by Sirawich Pipatprathanporn: 01/12/2021

% convert all inputs to row vectors
if size(amps, 2) > 1
    amps = amps';
end
if size(freqs, 2) > 1
    freqs = freqs';
end
if size(phases, 2) > 1
    phases = phases';
end

% creates sine functions
t = 0:(1/fs):dt;
x = amps' * sin(2 * pi * (freqs * t) + phases);
end