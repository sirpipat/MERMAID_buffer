function filename = datetime2file(dt)
% filename = TIME2DATETIME(dt)
%
% convert the datetime to the filename with the following format:
% 'uuuu-MM-ddTHH:mm:ss.SSSSSS', the same as raw buffer file from MERMAID
%
% INPUT:
% dt            datetime
% 
% OUTPUT:
% filename      the output filename
%
% Last modified by Sirawich Pipatprathanporn: 04/10/2020

dt.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
filename  = string(dt);
end