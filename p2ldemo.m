function p2ldemo(h, f)
% P2LDEMO(h, f)
% Demonstrates the relationship of ocean wave height (m) and pressure 
% spectral density (Pa2 s). The ocean wave consists of a sine wave with
% amplitude h and frequency f and random Gaussian noise with zero mean and
% h/10 sigma.
%
% INPUT
% h         wave height
% f         wave frequency
%
% Last modified by Sirawich Pipatprathanporn, 11/08/2020

fs = 100;
t_end = 10000;
t = linspace(0, t_end, fs * t_end + 1);

% wave height
y = h * sin(2 * pi * f * t);

% noise
n = h/10 * randn(size(t));
y = y + n;

% plot wave height
figure
set(gcf, 'Unit', 'inches', 'Position', [0.5 8 4.8 6]);
ax1 = subplot('Position', [0.16 0.63 0.76 0.32]);
plot(t, y, 'LineWidth', 1);
grid on
xlim([0 5/f]);
xlabel('time (s)');
ylabel('wave height (m)');
title(sprintf('amplitude = %5.2f m, frequency = %5.2f Hz', h, f));
set(ax1, 'FontSize', 12, 'TickDir', 'both');

% pressure: P = \rho g h
p = 1000 * 9.8 * y;

% compute spectral density
nfft = fs * 100;
lwin = nfft;
olap = 70;
sfax = 10;
unit = 's';

ax2 = subplot('Position', [0.16 0.12 0.76 0.32]);
specdensplot(p,nfft,fs,lwin,olap,sfax,unit);
ax2.Children(1).Marker = 'square';
ax2.Children(1).MarkerSize = 8;
ax2.Children(1).MarkerFaceColor = 'k';
ax2.Children(2).LineWidth = 1;
ax2.Children(3).LineWidth = 1;
ax2.Children(4).LineWidth = 1;
grid on
xlim(f*[1/10.01 10.01]);
ylim([0 100]);
ylabel('10 log_{10} spectral density (energy/Hz)');
set(ax2, 'FontSize', 12, 'TickDir', 'both');
ax2s = doubleaxes(ax2);
inverseaxis(ax2s.XAxis, 'period (s)');

% save figure
fname = sprintf('%s_h=%.2f_f=%.2f.eps', mfilename, h, f);
figdisp(fname, [], [], 2, [], 'epstopdf');
end