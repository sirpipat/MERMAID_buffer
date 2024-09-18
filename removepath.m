function filename = removepath(full_filename)
% filename = REMOVEPATH(full_filename)
%
% Removes the path from filename string
%
% INPUT:
% full_filename         full path to a file name
%
% OUTPUT:
% filename              file name without the path to the file
%
% EXAMPLE:
% % returns 'file.txt', for non-PC machine
% remove_path('/home/Document/file.txt')
%
% % example for PC
% remove_path('\home\Document\file.txt')
%
% SEE ALSO:
% FILEPARTS
%
% Last modified by sirawich-at-princeton.edu, 09/18/2024

splited_name = split(full_filename, filesep);
filename = cell2mat(splited_name(end));
end