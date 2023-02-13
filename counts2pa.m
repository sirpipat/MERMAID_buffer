function pa = counts2pa(counts, fs, freqlimits, file, filetype, plt)
% pa = COUNTS2PA(counts, fs, freqlimits, file, filetype, plt)
%
% Converts MERMAID digital counts to pressure in pascals by removing the
% instrumental response.
%
% INPUT:
% counts        the raw amplitude output by MERMAID
% fs            sampling rate of the data
% freqlimits    vector containing 4 frequencies in order of increasing
%               frequency. These frequencies specify the corners of a
%               cosine filter applied to the data to stabilize deconvolution
% file          full path to the SAC_PZs or RESP file
% filetype      type of response file, either 'sacpz' or 'resp'
% plt           whether to plot the result. If it is set to true, the
%               pressure by removing the instrumental reponse will be
%               plotted with the pressure from dividing gain for the
%               comparison.
%
% OUTPUT:
% pa            pressure output in pascals
%
% SEE ALSO:
% TRANSFER
%
% Last modified by sirawich-at-princeton.edu, 09/29/2021

defval('fs', 40.01406)
defval('freqlimits', [0.01 0.02 10 20])
defval('file', strcat(getenv('SACPZ'), 'MERMAID_response.txt'))
defval('filetype', 'sacpz')
defval('plt', false)

% Get the poles, zeros, and constant
if strcmp(filetype,'sacpz')
    [~,~,k] = parsePZ(file);
elseif strcmp(filetype,'resp')
    [~,~,k] = parseRESP(file);
else
    error(['Incorrect fileType. Currently supported options are ',...
           '''sacpz'' or ''resp'''])
end

pa = transfer(counts, 1/fs, freqlimits, 'acceleration', file, filetype);

if plt
   figure
   ax1 = subplot('Position', [0.08 0.75 0.86 0.20], 'Box', 'on', 'TickDir', 'both');
   signalplot(counts, fs, 0, ax1, 'counts', [], 'k');
   ax2 = subplot('Position', [0.08 0.41 0.86 0.20], 'Box', 'on', 'TickDir', 'both');
   signalplot(counts/k, fs, 0, ax2, 'pressure from dividing gain', [], ...
       'k');
   signalplot(pa, fs, 0, ax2, sprintf(['pressure from transfer.m ', ...
       'with freqlimits [%.2f %.2f %.2f %.2f] Hz'], freqlimits(1), ...
       freqlimits(2), freqlimits(3), freqlimits(4)), [], 'r');
   legend('dividing gain', 'using transfer function', 'Location', ...
       'northwest');
   ax3 = subplot('Position', [0.08 0.08 0.86 0.20], 'Box', 'on', 'TickDir', 'both');
   signalplot(counts/k - pa, fs, 0, ax3, 'pressure difference', [], ...
       'k');
end
end