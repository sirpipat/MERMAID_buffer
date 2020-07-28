function specdensplot_weekly(win)
% SPECDENSPLOT_WEEKLY()
% makes spectral density of each week from Sep 2018 to Aug 2019 of ocean
% noise recorded by a MERMAID P023
%
% INPUT
% win       Length of the window in seconds
%
% OUTPUT
% figures saved at $EPS and
% SD profiles saved at ...
% /Users/sirawich/research/processed_data/weekly_SD_profiles/
%
% SEE ALSO:
% SPECDENSPLOT_SECTION
% 
% Last modified by Sirawich Pipatprathanporn: 07/29/2020

% dt_begin and dt_end for specdensplot_section
dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt = dt_0 + calweeks(0:49);

% input parameters for specdensplot_section
excdir = '/Users/sirawich/research/processed_data/tphases/';
fs = 40.01406;
nfft = round(win * fs);
lwin = nfft;
olap = 70;
sfax = 10;
midval = 'median';
method = 'pct';
scale = 'linear';
plt = true;

savedir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';

for ii = 1:49
    [~, ~, ~, F, ~, ~, Swmid, Swstd, SwU, SwL] = ...
        specdensplot_section(dt(ii), dt(ii+1), excdir, nfft, fs, lwin, ...
        olap, sfax, midval, method, scale, plt);
    % save figure
    savefile = strcat(mfilename, '_', replace(string(dt(ii)), ':', ...
        '_'),'.eps');
    figdisp(savefile, [], [], 2, [], 'epstopdf');
    
    % write data
    titles = sprintf('%d_%02d_%02d',dt(ii).Year,dt(ii).Month,dt(ii).Day);
    fid = fopen(strcat(savedir,mfilename,'_',titles,'.txt'),'w');
    % the columns: F     median   std   SwU(95%)     SwL(5%)
    data = [F, Swmid, Swstd, SwU, SwL]';
    fprintf(fid, '%10.6f %10.6f %10.6f %10.6f %10.6f\n', data);
    fclose(fid);
end
end