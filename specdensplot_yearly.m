function specdensplot_yearly(win)
% SPECDENSPLOT_YEARLY(win)
% Makes a yearly summary of monthly spectral densities of ocean
% noise recorded by a MERMAID P023 from Sep 2018 to Aug 2019. Do not
% attempt to call SPECDENSPLOT_SECTION on an enitre year section or your
% machine will run out of memory.
%
% INPUT
% win       Length of the window in seconds
%
% OUTPUT
% no output beside figures saved at $EPS
%
% SEE ALSO:
% SPECDENSPLOT_SECTION
% 
% Last modified by Sirawich Pipatprathanporn: 07/11/2021

% dt_begin and dt_end for specdensplot_section
dt_0 = datetime(2018, 9, 1, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt = dt_0 + calmonths(0:12);

% input parameters for specdensplot_section
excdir = '/Users/sirawich/research/processed_data/tphases/';
fs = 40.01406;
nfft = round(win * fs);
lwin = nfft;
olap = 70;
sfax = 10;
midval = 'median';
method = 'pct';
scale = 'log';
rmtransfer = false;
plt = false;

% titles of specdensplot heatmap
titles = {'September 2018', 'October 2018', 'November 2018', ...
          'December 2018', 'January 2019', 'February 2019', ...
          'March 2019', 'April 2019', 'May 2019', ...
          'June 2019', 'July 2019', 'August 2019'};

%% make year summary of ocean noise
figure(4);
set(gcf, 'Unit', 'inches', 'Position', [2 2 15 13]);
clf

[~, up, np, F, SDbins, Swcounts, Swmean, ~, SwU, SwL] = ...
    specdensplot_section(dt(1), dt(2), excdir, nfft, fs, lwin, olap, ...
    sfax, midval, method, scale, rmtransfer, plt);
ax(1) = subplot('Position',[0.05 2/3+0.05 1/4-0.07 1/3-0.1]);
[ax(1),axs(1),axb(1)] = specdensplot_heatmap(ax(1), up, np, F, SDbins, Swcounts, Swmean, SwU, ...
    SwL, sfax, scale, titles{1});

Swcounts_total = Swcounts;
for ii = 2:12
    [~, up, np, F, ~, Swcounts, Swmean, ~, SwU, SwL] = ...
        specdensplot_section(dt(ii), dt(ii+1), excdir, nfft, fs, lwin, ...
        olap, sfax, midval, method, scale, rmtransfer, plt);
    Swcounts_total = Swcounts_total + Swcounts;
    
    % grid coordinates for panels (1,1) = bottom left, (4,3) = top right
    yy = 3 - ceil(ii/4);
    xx = ii - 4 * ceil(ii/4) + 3;
    ax(ii) = subplot('Position',[xx/4+0.05 yy/3+0.05 1/4-0.07 1/3-0.1]);
    [ax(ii),axs(ii),axb(ii)] = specdensplot_heatmap(ax(ii), up, np, F, SDbins, Swcounts, Swmean, ...
        SwU, SwL, sfax, scale, titles{ii});
end

% Make a loop for this
for ii = [2 3 4 6 7 8 10 11 12]
    ax(ii).YLabel = [];
    ax(ii).YTickLabel = [];
end

% another loop
for ii = [1 2 3 5 6 7 9 10 11]
    axs(ii).YTickLabel = [];
end

% bring panels closer
for ii = 0:4:8
    serre(ax((1:4) + ii), 0.7, 'across');
    serre(axs((1:4) + ii), 0.7, 'across');
    serre(axb((1:4) + ii), 0.27,'across');
end

for jj = 0:3
    serre(ax([1 5 9] + jj),0.2,'down');
    serre(axs([1 5 9] + jj),0.2,'down');
    serre(axb([1 5 9] + jj),0.121,'down');
end

figdisp('yearly_summary', [], [], 2, [], 'epstopdf');
end