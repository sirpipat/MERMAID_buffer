function [allfilelengths,fndex] = read_filesize(filesizename)
% generate an array of filelengths in samples from the filesize file

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