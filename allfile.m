function [allfiles,fndex] = allfile(dir)
% [allfiles,fndex]=ALLFILE(ddir)
%
% INPUT:
%
%  ddir      Where you keep the data (trailing slash needed!)
%
% OUTPUT:
%
% allfiles   Bottom-file list with complete file names
% fndex      The total number of elements in the list
%
% Last modified by Sirawich Pipatprathanporn, 11/16/2019

% Remember that when using LS2CELL in full path mode, you need the
% trailing file separators

% Makes the table of contents
allfiles = {};
fndex = 0;
files = ls2cell(dir, 1);
for index = 1:length(files)
    allfiles{index} = files{index};
end
fndex = index;
