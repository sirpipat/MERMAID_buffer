function hourspecdens_maker(hscdir, savedir)

[allhscfiles, hndex] = allfile(hscdir);

% parameter list
nfft = 1024;
fs = 40;
lwin = 1024;
olap = 70;
sfax = 10;

for ii = 1:hndex
    fprintf('%s\n', allhscfiles{ii});
    % read the files
    y = loadb(allhscfiles{ii},'int32','l');
    
    % skip if the file is too short
    if length(y) > lwin + 1024
        % plot spectral density plot
        specdensplot(y,nfft,fs,lwin,olap,sfax,'s');    

        savefile = erase(allhscfiles{ii},'.hsc');
        savefile = remove_path(savefile);
        % includes datetime to the title of the plot
        titlestr = replace(savefile, '_','\_');
        title(titlestr);

        % save the figure
        savefile = strcat(savedir, savefile, '_specdens', '.eps');
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
