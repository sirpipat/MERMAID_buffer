function specdensplot_weekly()
% SPECDENSPLOT_WEEKLY()
% makes spectral density of each week from Sep 2018 to Aug 2019 of ocean
% noise recorded by a MERMAID P023
%
% INPUT
% no input
%
% OUTPUT
% no output beside figures saved at $EPS
%
% SEE ALSO:
% SPECDENSPLOT_SECTION
% 
% Last modified by Sirawich Pipatprathanporn: 07/06/2020

% dt_begin and dt_end for specdensplot_section
dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt = dt_0 + calweeks(0:49);

% input parameters for specdensplot_section
excdir = '/Users/sirawich/research/processed_data/tphases/';
fs = 40.01406;
nfft = round(100 * fs);
lwin = nfft;
olap = 70;
sfax = 10;
scale = 'log';
plt = true;

for ii = 1:49
    specdensplot_section(dt(ii), dt(ii+1), excdir, nfft, fs, lwin, ...
        olap, sfax, scale, plt);
    % save figure
    savefile = strcat(mfilename, '_', replace(string(dt(ii)), ':', ...
        '_'),'.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
end
end