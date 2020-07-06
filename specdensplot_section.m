function fig = specdensplot_section(dt_begin,dt_end,excdir,nfft,fs,...
    lwin,olap,sfax,unt)
% fig = SPECDENSPLOT_SECTION(dt_begin,dt_end,excdir,nfft,fs,...
%    lwin,olap,sfax,unit)
% plot spectral sensity heat map of a section from dt_begin and dt_end
%
% INPUT
% dt_begin      beginning datetime
% dt_end        end datetime
% excdir        directory for files containing sections to exclude
% nfft          number of frequencies [default: 256]
% fs            sampling rate (Hz) [default: 40.01406]
% lwin          length of windows, in samples [default: 256]
% olap          overlap of data segments, in percent [default: 70]
% sfax          Y-axis scaling factor [default: 10]
% unt           string with the unit name [default: s]
%
% OUTPUT
% fig           figure handling this plot
%
% Last modified by Sirawich Pipatprathanporn: 07/06/2020

defval('nfft',256)
defval('fs',40.01406)
defval('lwin',nfft)
defval('olap',70)
defval('sfax',10)
defval('unt','s')

%% get data and remove all signals
% find all raw buffer sections between dt_begin and dt_end
[sections, intervals] = getsections(getenv('ONEYEAR'), dt_begin, dt_end, fs);

X = {};
for ii = 1:length(sections)
    % read the buffer
    [y, dt_b, dt_e] = readsection(sections{ii}, intervals{ii}{1}, ...
        intervals{ii}{2}, fs);
    
    % convert the content to datetimes
    if ~isempty(excdir)
        % read the exclusion periods
        filename = strcat(excdir, 'rmsplot_', ...
            replace(string(file2datetime(sections{ii})), ':', '_'), '.txt');
        fid = fopen(filename, 'r');
        str = fscanf(fid, '%c');
        fclose(fid);
        
        datestr = split(str);
        dt_all = datetime(datestr, 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS', ...
            'TimeZone', 'UTC', 'Format', 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
        dt_all = dt_all(~isnat(dt_all));
        dt_trigs = dt_all(1:2:end);
        dt_dtrigs = dt_all(2:2:end);
    else
        dt_trigs = datetime.empty(1,0);
        dt_dtrigs = datetime.empty(1,0);
    end
    
    % remove t-phases and separate into sub-intervals
    if ~isempty(dt_trigs)
        sub_intervals = cell(1,length(dt_trigs)+1);
        sub_intervals{1} = {dt_b, dt_trigs(1)};
        for jj = 1:length(dt_dtrigs)-1
            sub_intervals{jj+1} = {dt_dtrigs(jj), dt_trigs(jj+1)};
        end
        sub_intervals{length(dt_trigs)+1} = {dt_dtrigs(end), dt_e};
    else
        sub_intervals = {{dt_b, dt_e}};
    end
    
    % slice the sections by sub-intervals
    for jj = 1:length(sub_intervals)
        [yy, ~, ~] = slicesection(y, dt_b, ...
            sub_intervals{jj}{1}, sub_intervals{jj}{2}, fs);
        if ~isempty(yy) && length(yy) >= nfft * (2 - olap/100)
            X{length(X)+1} = yy;
        end
    end
end

%% compute power spectral density
% Overlap in samples
olap = floor(olap/100*lwin);

% Compute window
dwin = dpss(lwin,4,1);

% Normalize window so the sum of squares is unity (PW 208a)
dwin = dwin/sqrt(dwin'*dwin);

% Start of the loop over the elements of cell X
% Initialize Power Spectral Density matrix with window 
Pw = [];
for index = 1:length(X)
  x = X{index}(:);
  npts = length(x);
  % If npts equals lwin any amount of overlap still only produces one
  % window 
  checkit = (npts-olap)/(lwin-olap);
  nwin = floor(checkit);

  fprintf('Window size for spectral density: %8.1f\n',lwin/fs)

  fprintf('Number of overlapping data segments: %i\n',nwin)   
  if nwin ~= checkit
    fprintf(...
	'Number of  segments is not  integer: %i / %i points truncated\n',...
	 npts-(nwin*(lwin-olap)+olap),npts)
  end
  if nwin <= 1
      error('Data sequence not long enough');
  end
  
  % Make matrix out of suitably repeated windowed segments 
  % of the data 'xsdw' is x segmented THEN detrended THEN 
  % windowed with normalized window
   xsd = detrend(...
      x(repmat([1:lwin]',1,nwin)+...
	repmat([0:(nwin-1)]*(lwin-olap),lwin,1)));
  xsdw = xsd.*repmat(dwin,1,nwin);
  % Check segmented THEN detrended THEN windowed 
  % with normalized boxcar window  
  xsdb = xsd/sqrt(lwin);
  % Fill power matrix up progressively - initialization would speed this up
  Pw = [Pw (abs(fft(xsdw,nfft,1)).^2)];
  % For this cell section, compare with the boxcar version
  Pb = abs(fft(xsdb,nfft,1)).^2;
  % You can verify Percival and Walden (Eq. 134):
  % $\var\{x\}=\int_{-f_N}^{f_N}S(f)\,df$ by checking var(x) against
  % sum(mean(Pb,2))*(fs/nfft) which equals mean(mean(Pb,2))*fs
  % or of course mean(mean(Pb,2)) - if you've used a boxcar.
  % This checks how closely the total variance of x is captured
  % by the overlapping detrended boxcar windowing scheme.
  % Variations are due to taper forms, overlap, etc.
  % This is why you better don't compare absolute values of the 
  % spectral density, but normalize them on a decibel scale
  %  disp(sprintf(...
  %      'Parseval check: %8.3e (time) vs %8.3e (frequency)',...
  %      var(x(1:nwin*(lwin-olap)+olap)),mean(Pb(:))))
end

% Total number of estimates available
nwint = size(Pw,2);

% P is the POWER SPECTRAL DENSITY or the ENERGY/SECOND/FREQUENCY
% Units of ENERGY thus UNIT^2
% S=P*Dt=P/fs is the SPECTRAL DENSITY or ENERGY/FREQUENCY
% So that its integral over all frequencies int(S(f)df) equals variance
% Units are UNIT^2/HZ or UNITS^2*SECOND
% Note that the area in frequency space is given by 2*fN, which is 1/Dt
Sw = Pw/fs;

% spectral density in log space
Slog = log10(Sw) * sfax;

% Calculate frequency vector for real signals
% and get rid of periodicity in spectrum
selekt = (1:floor(nfft/2)+1);
F = (selekt-1)'*fs/nfft;
Slog = Slog(selekt,:);

% Bins for the number of spectral density lines going through
binedges = 20:1:140;
Swcounts = zeros(length(F), length(binedges)-1);
for ii = 1:length(F)
    Swcounts(ii,:) = histcounts(Slog(ii,:), 'BinEdges', binedges);
end

% Frequencies bin in log space
Flog = logspace(log10(F(2)), log10(F(end)), length(F) -1);

% interpoate bin to log space frequency bins
Slogcounts = interp1(F, Swcounts, Flog);

%% create figure
figure(3)
set(gcf, 'Unit', 'inches', 'Position', [18 8 6.5 6.5]);
clf

% plot title
ax0 = subplot('Position',[0.05 0.93 0.9 0.02]);
title(sprintf('%s - %s', string(dt_begin), string(dt_end)));
set(ax0, 'FontSize', 12, 'Color', 'none');
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';

% make power spectral density plot
ax = subplot('Position', [0.11 0.04 0.83 0.84]);
p = imagesc([Flog(1) Flog(end)],[2 140], Slogcounts');
axis xy

cmap = colormap('parula');
cmap = [1 1 1; cmap];
colormap(gcf, cmap);

% add colorbar
c = colorbar('southoutside');
c.Label.String = sprintf('counts (total = %i)', size(Sw, 2));

% fix x-label
ax.XTick = log10([0.1 1 10] / Flog(1)) * Flog(end) / ...
    log10(Flog(end)/Flog(1));
ax.XTickLabel = {'0.1'; '1'; '10'};
grid on

% fix the precision of the time on XAxis label
ax.XAxis.Label.String = sprintf('frequency (Hz): %d s window', round(nfft/fs));

% fix the precision of the frequency on YAxis label
yfreq = 'spectral density (energy/Hz)';
y_label = ylabel(sprintf('%s ; %s = %.4f', yfreq, '\Delta\itf', fs/nfft));

% add label on the top and right
ax.TickDir = 'both';
axs = doubleaxes(ax);

% add axis label
inverseaxis(axs.XAxis, 'Period (s)');

% add frequency bands label
hold on
ax = vline(ax, log10([0.05, 0.1] / Flog(1)) * Flog(end) / ...
    log10(Flog(end)/Flog(1)), '--', 1, rgbcolor('green'));
ax = vline(ax, log10([2, 10] / Flog(1)) * Flog(end) / ...
    log10(Flog(end)/Flog(1)), '--', 1, rgbcolor('brown'));
hold off

fig = gcf;
end