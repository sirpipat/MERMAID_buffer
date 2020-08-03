function wwspecdensmaker(sfax, midval, intval)
% WWSPECDENSMAKER(sfax, midval, intval)
% Computes spectral density (monthly at this point) of equivalent surface
% pressure from WAVEWATCH at the location of MERMAID P023
%
% INPUT
% sfax          Y-axis scaling factor [default: 10]
% midval        middle values ('mean' or 'median') [default: 'median']
% intval        method for confidence limit ('std' or 'pct') [default: 'pct']
%
% OUTPUT
% no output beside files in savedir
%
% Last modified by Sirawich Pipatprathanporn: 08/03/2020

defval('sfax', 10)
defval('midval','median')
defval('midval','pct')

% get all p2l files
[allp2ls, pndex] = allfile(strcat(getenv('NCFILES'),'p2l/'));

% 
savedir = '/Users/sirawich/research/processed_data/monthly_WWSD_profiles/';
% titles of spectral density profile output
titles = {'2018_09', '2018_10', '2018_11', '2018_12', '2019_01', ...
          '2019_02', '2019_03', '2019_04', '2019_05', '2019_06', ...
          '2019_07', '2019_08'};
for ii = 1:pndex
    % read p2lfile
    [lon,lat,f,~,dt,p2l] = readp2l(allp2ls{ii});
    
    % find location of MERMAID P023
    [mlon,mlat] = mposition(dt);
    
    spec = zeros(size(p2l,3),size(p2l,4));
    for jj = 1:size(dt,1)
        % find best lon and lat index
        [~,ilon] = min(abs(lon - mlon(jj)));
        [~,ilat] = min(abs(lat - mlat(jj)));
        [~,itime] = min(abs(dt - dt(jj)));
        spec(:,jj) = sfax * reshape(p2l(ilon,ilat,:,itime), size(p2l,3), 1);
    end
    
    % remove NaN
    keep = [];
    for jj = 1:size(dt,1)
        if all(~isnan(spec(:,jj)))
            keep = [keep jj];
        end
    end
    spec = spec(:, keep);
    
    % compute spectral density
    if strcmp(midval, 'mean')
        SDmid = mean(spec, 2);
    else
        SDmid = median(spec, 2);
    end
    SDstd = std(spec, 0, 2);
    if strcmp(intval, 'std')
        kcon = 1.96;
        SDU = SDmid + kcon * SDstd;
        SDL = SDmid - kcon * SDstd;
    else
        SDU = prctile(spec, 95, 2);
        SDL = prctile(spec, 5, 2);
    end
    
    % write data
    fid = fopen(strcat(savedir,mfilename,'_',titles{ii},'.txt'),'w');
    % the columns: F     median   std   SwU(95%)     SwL(5%)
    data = [f, SDmid, SDstd, SDU, SDL]';
    fprintf(fid, '%10.6f %10.6f %10.6f %10.6f %10.6f\n', data);
    fclose(fid);
end
end