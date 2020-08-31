function specdensplot_biweekly(win,option)
% SPECDENSPLOT_BIWEEKLY(win, option)
% makes spectral density of each 2-weeks from Sep 2018 to Aug 2019 of ocean
% noise recorded by a MERMAID P023
%
% INPUT
% win       Length of the window in seconds
% option    'plot' or 'save'
%           'plot' gives log-scale spectral density heat map
%           'save' gives SD profiles saved at ...
%           /Users/sirawich/research/processed_data/biweekly_SD_profiles/
%
% OUTPUT
% figures saved at $EPS or SD profiles saved at ...
% /Users/sirawich/research/processed_data/biweekly_SD_profiles/
%
% SEE ALSO:
% SPECDENSPLOT_SECTION, SPECDENSPLOT_HEATMAP
% 
% Last modified by Sirawich Pipatprathanporn: 08/10/2020

defval('win', 100)
defval('option', 'plot')

% check invalid input
if win <= 0
    error('win must be above 0.');
elseif ~or(strcmp(option, 'plot'), strcmp(option, 'save'))
    error('option must be either ''plot'' or ''save''');
end

% dt_begin and dt_end for specdensplot_section
dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt = dt_0 + calweeks(0:2:49);

% input parameters for specdensplot_section
excdir = '/Users/sirawich/research/processed_data/tphases/';
fs = 40.01406;
nfft = round(win * fs);
lwin = nfft;
olap = 70;
sfax = 10;
midval = 'median';
method = 'pct';
if strcmp(option, 'save')
    scale = 'linear';
    plt = false;
else
    scale = 'log';
    plt = true;
end

savedir = '/Users/sirawich/research/processed_data/biweekly_SD_profiles/';

for ii = 1:size(dt,2)-1
    [~, ~, ~, F, ~, ~, Swmid, Swstd, SwU, SwL] = ...
        specdensplot_section(dt(ii), dt(ii+1), excdir, nfft, fs, lwin, ...
        olap, sfax, midval, method, scale, plt);
    % save figure
    if strcmp(option, 'plot')
        savefile = strcat(mfilename, '_', replace(string(dt(ii)), ':', ...
            '_'),'.eps');
        figdisp(savefile, [], [], 2, [], 'epstopdf');
    % write data
    else
        titles = sprintf('%d_%02d_%02d',dt(ii).Year,dt(ii).Month,dt(ii).Day);
        fid = fopen(strcat(savedir,mfilename,'_',titles,'.txt'),'w');
        % the columns: F     median   std   SwU(95%)     SwL(5%)
        data = [F, Swmid, Swstd, SwU, SwL]';
        fprintf(fid, '%10.6f %10.6f %10.6f %10.6f %10.6f\n', data);
        fclose(fid);
    end
end
end