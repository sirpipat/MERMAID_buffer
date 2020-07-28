function [t,E] = energy(F_ranges,sfax,option,scale)
% [t,E] = ENGERGY(F_ranges,sfax,option,scale)
% Integrates spectral density over frequency ranges over one year of
% MERMAID buffer. Then, plot the result.
% E(a <= f <= b) = \int_a^b s(f) df where s(f) is spectral density.
%
% INPUT
% F_ranges      frequency ranges e.g.
%               [0.4  0.75] : 1 range from 0.4 to 0.75 Hz
%               [1  2; 5 8] : 2 ranges from 1 to 2 Hz and 5 to 8 Hz
% sfax          Y-axis scaling factor [default: 10]
% option        either 'weekly' or 'monthly'
% scale         scaling of energy output [default: 1]
%               1 -- log scale multiplied by sfax
%               2 -- linear scale
%
% OUTPUT
% t             time
% E             energy over frequency ranges and 12 months.
%               size(E) == [12 num_range] for 'monthly' option
%               size(E) == [48 num_range] for 'weekly' option
%
% Last modified by Sirawich Pipatprathanporn: 07/29/2020

defval('sfax',10)
defval('scale',1)

num_ranges = size(F_ranges,1);

% read precomputed spectral densities from files 
if strcmp(option,'monthly')
    SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
elseif strcmp(option,'weekly')
    SDdir = '/Users/sirawich/research/processed_data/weekly_SD_profiles/';
else
    fprintf('Invalid Input\n');
    return
end
[allSDs,dndex] = allfile(SDdir);

% compute energy by integrating spectral density over frequency ranges
E = zeros(dndex,num_ranges);

for ii = 1:dndex
    % read data from files
    fid = fopen(allSDs{ii},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    
    F = data(1,:);
    SD = data(2,:);
    
    % integration using trapezoidal method
    for jj = 1:num_ranges
        E(ii,jj) = boundtrapz(F, 10 .^ (SD / sfax), F_ranges(jj, 1), ...
            F_ranges(jj, 2));
    end
end

% make Y-axis log scale
if scale == 1
    E = sfax * log10(E);
end

% label for each energy curve in the plot
labels = cell(1,num_ranges);
for ii = 1:num_ranges
    labels{1,ii} = sprintf('%5.2f-%5.2f Hz', F_ranges(ii,1), F_ranges(ii,2));
end

% plot results
if strcmp(option,'monthly')
    t = datetime(2018,9,1,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calmonths(0:11);
elseif strcmp(option,'weekly')
    t = datetime(2018,9,13,'Format','uuuu-MM-dd''T''HH:mm:ss.SSSSSS',...
        'TimeZone','UTC') + calweeks(0:48);
end
figure;
plot(t,E,'LineWidth',1);
grid on
if scale == 1
    ylabel(sprintf('%g log_{10} (Energy)', sfax))
else
    ylabel('Energy')
end
legend(labels,'Location','best')
end