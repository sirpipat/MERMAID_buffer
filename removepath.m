function filename = removepath(full_filename)
% filename = removepath(full_filename)
% remove the path from filename string
% e.g. remove_path('/home/Document/file.txt') == 'file.txt'

splited_name = split(full_filename, '/');
filename = cell2mat(splited_name(end));

end