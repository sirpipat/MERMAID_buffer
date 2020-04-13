function hourspecdens_maker(hscdir, nfft, fs, lwin, olap, sfax)
% HOURSPECDENS_MAKER(hscdir, nfft, fs, lwin, olap, sfax)
%
% Plots spectral density plots from hour section files (.hsc) using pChave
% algorithm
%
% INPUT
% nfft     Number of FFT points [default: lwin]
% fs       Sampling frequency [Default: 40.01406]
% lwin     Window length, in samples [default: 256]
% olap     Window overlap, in percent [default: 70]
% sfax     Y-axis scaling factor [default: 10]
%
% OUTPUT
% No output besides the power spectral density plots saved at $EPS
%
% SEE ALSO
% SPECDENSPLOT, DOUBLEAXES, INVERSEAXIS
%
% Last modified by Sirawich Pipatprathanporn, 04/13/2020

% get all filenames
[allhscfiles, hndex] = allfile(hscdir);

% parameter list
defval('nfft', 1024);
defval('fs', 40.01406);
defval('lwin', 1024);
defval('olap', 70);
defval('sfax', 10);

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    % skip if the file is too short
    if length(y) > lwin + 1024
        % plot spectral density plot
        clf
        p = specdensplot(y,nfft,fs,lwin,olap,sfax,'s');
        % add grid to the plot
        grid on
        % add the second axes and label
        ax = p(1).Parent;
        ax.Position = [0.1300 0.1100 0.7750 0.7150];
        ax2 = doubleaxes(ax);
        inverseaxis(ax2.XAxis, 'period (s)');
        
        % fix the precision of the frequency on YAxis label
        y_label = ax.YAxis.Label.String;
        y_split = split(y_label, '=');
        f_string = sprintf(' %.4f', fs/nfft);
        y_label = strcat(y_split{1}, ' =', f_string);
        ax.YAxis.Label.String = y_label;
        
        savefile = erase(allhscfiles{ii},'.hsc');
        savefile = removepath(savefile);
        % includes datetime to the title of the plot
        titlestr = replace(savefile, '_','\_');
        ax2.Title.String = titlestr;

        % save the figure
        savefile = strcat(savefile, '_specdens', '.eps');
        figdisp(savefile, [], [], 2, [], 'epstopdf');
    end
end
end
