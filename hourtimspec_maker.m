function hourtimspec_maker(hscdir, nfft, fs, wlen, wolap, beg)
% HOURTIMSPEC_MAKER(hscdir, nfft, fs, wlen, wolap, beg)
%
% Plots spectrograms from hour section files (.hsc) using PChave algorithm
%
% INPUT
% hscdir        Directory of all hsc files
% nfft          Number of FFT points [Default: 1024]
% fs            Sampling frequency [Default: 40.01406]
% wlen          Window length, in samples [Default: 1024]
% wolap         Window overlap, as a fraction [Default: 0.7]
% beg           Signal beginning - actually, can get this from h 

[allhscfiles, hndex] = allfile(hscdir);

% default parameter list
defval('nfft', 1024);
defval('fs', 40.01406);
defval('wlen', 1024);
defval('wolap', 0.70);
defval('beg', 0);

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    % skip if the file is too short
    if length(y) > wlen + 1024
        figure(1);
        clf
        % plot spectral density plot
        timspecplot_ns(y,nfft,fs,wlen,wolap,beg,'s');    

        savefile = erase(allhscfiles{ii},'.hsc');
        savefile = removepath(savefile);
        % includes datetime to the title of the plot
        titlestr = replace(savefile, '_','\_');
        title(titlestr);

        % save the figure
        savefile = strcat(savefile, '_timspec', '.eps');
        figdisp(savefile, [], [], 2, [], 'epstopdf');
    end
end
end