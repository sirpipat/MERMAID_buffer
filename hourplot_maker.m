function hourplot_maker(hscdir, savedir)
% HOURPLOT_MAKER(hscdir, savedir)
%
% Make 1-hr seismograms from all hoursection (.hsc) files
%
% INPUT:
%
%  hscdir	Where you keep all hoursection (.hsc) files  
%  savedir	Location for the hourplots
%
% OUTPUT:
%
%  No output besides the hourplots
%
% Last modified by Sirawich Pipatprathanporn, 12/16/2019

[allhscfiles, hndex] = allfile(hscdir);

% assume sampling frequency to be 40 Hz
fs = 40;

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    signalplot(y,fs, time(erase(allhscfiles{ii},'.hsc')), 'left');
    
    savefile = erase(allhscfiles{ii},'.hsc');
    savefile = remove_path(savefile);
    % includes datetime to the title of the plot
    titlestr = replace(savefile, '_','\_');
    title(titlestr);

    % save the figure
    savefile = strcat(savedir, savefile, '_rawplot', '.eps');
    saveas(gcf, savefile,'epsc');
end
end

% Requires: filename must be in this format: 
%           "yyyy-MM-dd 'T' HH:mm:SS(.ssssss)"
% Modifies: nothing
% Effects:  calculate datetime of the file
function t = time(filename)
    filename = remove_path(filename);
    datestr = replace(filename,'_',':');
    % append '.000000' if ss does not have any decimals.
    if ~contains(datestr,'.')
        str = [datestr,'.000000'];
        datestr = join(str);
    end
    t = datetime(datestr,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
end

% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'
function filename = remove_path(full_filename)
    % remove file path from the file name
    splited_name = split(full_filename, '/');
    filename = cell2mat(splited_name(end));
end
