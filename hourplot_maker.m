function hourplot_maker(hscdir, savedir, fs)
% HOURPLOT_MAKER(hscdir, savedir, fs)
%
% Make 1-hr seismograms from all hoursection (.hsc) files
%
% INPUT:
%
%  hscdir	Where you keep all hoursection (.hsc) files  
%  savedir	Location for the hourplots
%  fs       Sampling rate [Default: 40.01406 Hz]
%
% OUTPUT:
%
%  No output besides the hourplots
%
% Last modified by Sirawich Pipatprathanporn, 04/11/2020

[allhscfiles, hndex] = allfile(hscdir);

defval('fs', 40.01406);

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    % plot the signal
    signalplot(y, fs, file2datetime(erase(allhscfiles{ii},'.hsc')), ...
        axes, [], 'left');
    
    savefile = erase(allhscfiles{ii},'.hsc');
    savefile = removepath(savefile);
    % includes datetime to the title of the plot
    titlestr = replace(savefile, '_','\_');
    title(titlestr);

    % save the figure
    savefile = strcat(savedir, savefile, '_rawplot');
    figdisp(savefile, [], [], 2, [], 'esptopdf');
end
end
