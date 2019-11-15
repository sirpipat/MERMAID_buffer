function psdplot(x, fs, nfft)
%
% Plots power spectral density

defval('nfft', 1024);

L = length(x);               
X = fft(x, nfft);       
Px = X .* conj(X) / (nfft * L); %Power of each freq components       
fVals = fs * (0:nfft/2-1) / nfft;      
loglog(fVals, Px(1:nfft/2),'b','LineWidth',1);         
title('One Sided Power Spectral Density');       
xlabel('Frequency (Hz)')         
ylabel('PSD');

end