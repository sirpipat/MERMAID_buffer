function x = sinewave(dt, freqs, fs)
% x = SINEWAVE(dt, freqs, fs)
% Creates sine waves of specified frequencies
%
% INPUT:
% dt        length of the sine waves in seconds
% freqs     frequencies as an array of doubles
% fs        sampling frequencies
%
% OUTPUT:
% x         sine waves signal
%
% Last modified by Sirawich Pipatprathanporn: 02/04/2020

% creates sine functions
t = 0:dt*fs;
x = 0;
for ii = 1:length(freqs)
    x = x + sin(2 * pi * freqs(ii) * t / fs);
end

% normalizes the funciton
x = x / length(freqs);
end