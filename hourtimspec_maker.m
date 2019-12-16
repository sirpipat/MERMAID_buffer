function hourtimspec_maker(hscdir, savedir)

[allhscfiles, hndex] = allfile(hscdir);

% parameter list
nfft = 1024;
fs = 40;
wlen = 1024;
wolap = 0.70;
beg = 0;

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    % skip if the file is too short
    if length(y) > wlen + 1024
        % plot spectral density plot
        timspecplot_ns(y,nfft,fs,wlen,wolap,beg,'s');    

        savefile = erase(allhscfiles{ii},'.hsc');
        savefile = remove_path(savefile);
        % includes datetime to the title of the plot
        titlestr = replace(savefile, '_','\_');
        title(titlestr);

        % save the figure
        savefile = strcat(savedir, savefile, '_timspec', '.eps');
        saveas(gcf, savefile,'epsc');
    end
end
end

% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'
function filename = remove_path(full_filename)
    % remove file path from the file name
    splited_name = split(full_filename, '/');
    filename = cell2mat(splited_name(end));
end