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
        specdensplot(y,nfft,fs,lwin,olap,sfax,'s');
        % add grid to the plot
        grid on

        savefile = erase(allhscfiles{ii},'.hsc');
        savefile = removepath(savefile);
        % includes datetime to the title of the plot
        titlestr = replace(savefile, '_','\_');
        title(titlestr);

        % save the figure
        savefile = strcat(savefile, '_specdens', '.eps');
        figdisp(savefile, [], [], 2, [], 'epstopdf');
    end
end
end