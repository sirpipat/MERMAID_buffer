function hoursection_maker(filename, savedir)
% HOURSECTION_MAKER(filename, savedir)
%
% Creates hour sections of the data and stored in binary files with names
% in this format:
%       <beginning time in yyyy-MM-ddTHH:mm:SS.ssssss>.hsc
%
% INPUT
% filename  = the name of raw MERMAID data file
% savedir   = the directory of the output file
%               savedir should be a fullfile path
%
% NO OUTPUT (besides hoursection files)


fprintf("hoursection_maker('%s')\n", filename);

% sampling frequency
fs = 40.01406;

% read file
[x, dt_start, dt_end] = readOneYearData(filename, fs);

fprintf('size = %d, interval = %d, fs = %f\n', length(x), length(x)/fs, fs);

% read first section
[x, dt_B, dt_E] = readsection(filename, dt_start, dt_start + hours(1), fs);
dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
outfile = strcat(savedir, datetime2file(dt_B), '.hsc');
fid = fopen(outfile, 'w', 'l');
fwrite(fid, x, 'int32');
fclose(fid);

% read later sections
while dt_E < dt_end
    [x, dt_B, dt_E] = readsection(filename, dt_E, dt_E + hours(1), fs);
    dt_B.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
    outfile = strcat(savedir, datetime2file(dt_B), '.hsc');
    fid = fopen(outfile, 'w', 'l');
    fwrite(fid, x, 'int32');
    fclose(fid);
end

end