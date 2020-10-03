function T = readvit(fname)
% T = readvit(fname)
% 
% Load a .vit file
% 
% INPUT:
% fname     full filename of the .vit file
% 
% OUTPUT:
% T         table from .vit file with the following fields
%             'Station'
%             'Date'        datetime with hh:mm:ss == 00:00:00
%             'Time'
%             'stla'
%             'stlo'
%             'HDil'
%             'VDil'
%             'VBat'
%             'Vmin'
%             'PInt'
%             'PExt'
%             'PRange'
%             'NumCommand'
%             'NumQueued'
%             'NumUploaded'
%
% Example
% % read P023 vit file [default]
% T = readvit();
% dt = T.Date + T.Time;
%
% Last modified by Sirawich Pipatprathanporn, 10/01/2020

defval('fname','/Users/sirawich/research/raw_data/metadata/P023_all.txt')

% read vit file
opts = detectImportOptions(fname);
T = readtable(fname,opts);
T.Properties.VariableNames = {'Station', ...
                              'Date', ...
                              'Time', ...
                              'stla', ...
                              'stlo', ...
                              'HDil', ...
                              'VDil', ...
                              'VBat', ...
                              'Vmin', ...
                              'PInt', ...
                              'PExt', ...
                              'PRange', ...
                              'NumCommand', ...
                              'NumQueued', ...
                              'NumUploaded'};
                          
end
