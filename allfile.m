function [allfiles,fndex] = allfile(dir)
% [allfiles,fndex]=ALLFILE(ddir)
%
% INPUT:
%
%  ddir     Where you keep the data (trailing slash needed!)
%           This should be a character vector
%
% OUTPUT:
%
% allfiles   Bottom-file list with complete file names
% fndex      The total number of elements in the list
%            -1 if dir does not exist as a directory
%             0 if dir is an empty directory
%
% Last modified by Sirawich Pipatprathanporn, 11/01/2021
%
% Remember that when using LS2CELL in full path mode, you need the
% trailing file separators

% Makes the table of contents
allfiles = {};
fndex = 0;

% check whether dir is a directory
switch exist(dir)
    case 2
        % fprintf('It exists as a file not a directory.\n');
        fndex = -1;
        return
    case 7
    otherwise
        % fprintf('This directory does not exist');
        fndex = -1;
        return
end

% check whether dir is empty
try
    files = ls2cell(dir, 1);
catch
    % fprintf('This direcotry is empty.\n');
    return
end

for index = 1:length(files)
    allfiles{index} = files{index};
end
fndex = index;
