function varargout=psd2time(f,Sf,d,Fs,M)
% [F,Sfest,Sfestf,f,Sf]=PSD2TIME(f,Sf,d,Fs,M)
%
% Converts power spectral density to time-series data and back again
%
% INPUT:
%
% f       discrete frequencies, not necessarily equally spaced
% Sf      one-sided spectral density at those frequencies, to be
%         interpreted as providing variance contributions over a finite
%         frequency interval that is an OUTPUT of this program
% d       duration [s]
% Fs      sampling rate [Hz]
% M       number of experiments
%
% OUTPUT:
%
% F       the frequency axis for the estimated spectral density
% Sfest   the estimated one-sided spectral density of the generated signals
% Sfestf  the estimated spectral density at the input frequencies
% f       the input discrete frequencies
% Sf      the input one-sided spectral density 
%
% Last modified by Sirawich Pipatprathanporn, 11/16/2020
% Last modified by fjsimons-at-alum.mit.edu, 11/18/2020

% Discrete frequencies
defval('f',[1 2 5 7 8 9 14 18]);
% Spectral density at these frequencies
defval('Sf',randi(20,[1 length(f)]));
% Number of experiments
defval('M',400);
% Duration
defval('d',50);
% Sampling frequency
defval('Fs',80);
% Number of time samples
N = d*Fs+1;
% Time-domain axis
t=linspace(0,d,N);

% Random amplitudes, properly apportioned
af=randn(M,length(f)).*repmat(sqrt(Sf*2),M,1);
% Deterministic?
% af=repmat(af(1,:),size(af,1),1);

% Phase-randomized Fourier series with these amplitudes
% Note the variance of the sampled sine itself is 1/2
y=[af*sin(2*pi*f'*t+2*pi*repmat(rand(length(f),1),1,length(t)))]';

% MATLAB's implementation of the Fourier transform
Y=fft(y);

% Direct spectral estimator of Percival and Walden (206c) without any
% window, which means 1/sqrt(N) window. Equal to the periodogram.
% Assume real-valued signals by taking half the frequency  but make up
% for lost power by doubling what comes out
PY=abs(Y(1:floor(size(Y,1)/2),:).^2/Fs/N)*2;

% Frequencies for the spectral density estimate
F=((1:size(PY,1))'-1)/d;

% Means etc over the runs
Sfest=   mean(PY,   2);
Sfmin=prctile(PY, 5,2);
Sfmax=prctile(PY,95,2);

% Plot the results
subplot(211)
% Just some of the time signals 
plot(t,y(:,1:min(5,M)))
xlabel('time [s]')
ylabel('signal')

% This needs to check out up to tolerance, PW p134
% The variance of the sample sequence equals the integrated spectral density
% [var(y,1)' sum(PY,1)'/d]
difer(abs([var(y,1)-sum(PY,1)/d]./var(y,1)),1)
% This needs to check out up to tolerance, PW p128
% The variance of the sample sequence made up from the harmonic
% components, but with the doubling due to our generation.
% But no surprise here since the variance of the sampled sine is 1/2
% itself and there is no covariance between the different frequencies
% [var(y,1)' sum(af.^2/2,2)]
difer(abs([var(y,1)-sum(af.^2/2,2)']./var(y,1)),1)
% Where do the frequencies match? If they are integer multiples
try
  [~,b]=intersect(F,f);
  % This needs to match in expectation but know the periodogram is not
  % great and it seems to get worse closer to the Nyquist
  % Check some random experiments
  % c=randi(M);[PY(b,c)/d af(c,:)'.^2/2]
  % Check it in the mean
  % [mean(PY(b,:),2)/d mean(af.^2/2)']
  % abs(mean(PY(b,:),2)/d-mean(af.^2/2)')./mean(af.^2/2)'
  difer(abs(mean(PY(b,:),2)/d-mean(af.^2/2)')./mean(af.^2/2)',-1)
  % If you want to make the comparison formally: if you want an estimated
  % frequency to stand in for its neighbors it needs to be remultiplied
  % with the area
  Sfestf=Sfest(b)'/d;
catch
  % Maybe interpolate
  Sfestf=NaN;
end

% Now get an idea of the time-domain powers
title(sprintf('signal rms %8.3f vs scaled power %8.3f',...
	      rms(rms(y')),sqrt(sum(Sf))*sqrt(2)/2))

subplot(212)
semilogy(F,Sfest,'b')
hold on
% semilogy(F,Sfmin,'r')
% semilogy(F,Sfmax,'g')
% Really need to assign the power over a range of df in the PY/SF to the
% single coefficients so divide by df to make it have the same
% interpretation as an area in the plot, and see the comparisons above
% So the stem times the increment equals the area under the equivalent
% blue curve, in expectation, so the plot needs to be different
stem(f,log10(mean(af.^2/2)*d))

% Plot the input spectral density
semilogy(f,Sf,'k+')
hold off
grid on
xlabel('frequency (Hz)')
ylabel('power spectral density')
xlim([0 20])

% Variable output
varns={F,Sfest,Sfestf,f,Sf};
varargout=varns(1:nargout);
