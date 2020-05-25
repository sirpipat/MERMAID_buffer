function dts = readdatetime(filename)
% dts = READDATETIME(filename)
%
% Reads datetime column from a text file and convert to datetimes
% The date string in the file must be in this format:
%       uuuu-MM-dd HH:mm:ss.ssssss
%
% INPUT
% filename      The name of the text file
%
% OUTPUT
% dts           A column of datetimes
%
% Last modified by Sirawich Pipatprathanporn: 04/25/2020

% open the file
fid = fopen(filename,'r');
if fid < 0
    error('ERROR: cannot open %s!',filename);
end

% read data
data_size = [6 Inf];
data = fscanf(fid,'%d-%d-%d %d:%d:%f',data_size);
fclose(fid);

% convert the data to datetimes
dts = datetime(transpose(data));
dts.Format = 'uuuu-MM-dd''T''HH:mm:ss.ssssss';
end