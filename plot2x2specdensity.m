function plot2x2specdensity(hscdir, index1, index2, index3, index4)
% create 4 spectograms for 4 time windows
% plotted as 2x2 subplots

% parameter list
nfft = 1024;
fs = 40;
lwin = 1024;
olap = 70;
sfax = 10;

[allhscfiles, hndex] = allfile(hscdir);
index = {index1 index2 index3 index4};


for ii = 1:4
    % load data from the file
    filename = allhscfiles{index{ii}};
    y = loadb(filename,'int32','l');
    
    % create a subplot
    subplot(2, 2, ii);
    
    % plot
    [p,xl,yl,F,SD,Ulog,Llog]=specdensplot(y,nfft,fs,lwin,olap,sfax,'s');
    grid on
    ylim([40 140]);
    
    % change color line
    p(1).Color = [0.8 0.25 0.25];
    p(2).Color = [0.5 0.5 0.5];
    p(3).Color = [0.5 0.5 0.5];
    
    % add label
    if ii == 1
        label_str = 'a';
    elseif ii == 2
        label_str = 'b';
    elseif ii == 3
        label_str = 'c';
    else
        label_str = 'd';
    end
    text(13, 135, label_str, 'FontSize', 14);
    
    % make title
    titlestr = remove_path(erase(filename,'.hsc'));
    titlestr = replace(titlestr,'_',':');
    titlestr = replace(titlestr,'T',' ');
    splited_str = split(titlestr, '.');
    titlestr = cell2mat(splited_str(1));
    title(titlestr);
end
end

% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'
function filename = remove_path(full_filename)
    % remove file path from the file name
    splited_name = split(full_filename, '/');
    filename = cell2mat(splited_name(end));
end