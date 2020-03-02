function [allfilelengths,fndex] = read_filesize(filesizename)
% [allfilelengths,fndex] = READ_FILESIZE(filesizename)
% generates an array of filelengths in samples from the filesize file
%
% INPUT:
% filesizename          The name of the filesize file
%
% OUTPUT:
% allfilelengths        An array of filelengths [in samples]
% fndex                 The number of elements in allfilelengths
%
% Last modified by Sirawich Pipatprathanporn: 03/01/2020

filedir = '/home/sirawich/research/processed_data/toc/';
defval('filesizename', sprintf('%sOneYearData_filesize.txt',filedir));

% read the file
fileID = fopen(filesizename);
formatSpec = '%10s %8s %d';
sizeA = [19 Inf];
A = fscanf(fileID,formatSpec,sizeA);
fclose(fileID);

allfilelengths = A(19,:) / 4;
fndex = length(allfilelengths);
end