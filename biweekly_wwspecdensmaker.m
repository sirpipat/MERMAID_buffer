function biweekly_wwspecdensmaker(sfax, midval, intval)
% BIWEEKLY_WWSPECDENSMAKER(sfax, midval, intval)
% Computes spectral density (biweekly) of equivalent surface
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
% Last modified by Sirawich Pipatprathanporn: 08/10/2020

% get all p2l files
[allp2ls, pndex] = allfile(strcat(getenv('NCFILES'),'p2l/'));

% output location
savedir = '/Users/sirawich/research/processed_data/biweekly_WWSD_profiles/';

% read all p2l files
spec = [];      % spec = spec(ifreq, idt)
dts = [];       % dts  = dts(1, idt)
for ii = 1:pndex
    [lon,lat,f,~,dt,p2l] = readp2l(allp2ls{ii});
    [mlon,mlat] = mposition(dt);
    
    % remove NaN locations
    keep = and(~isnan(mlon), ~isnan(mlat));
    mlon = mlon(keep);
    mlat = mlat(keep);
    dt = dt(keep);
    
    % append spectral density
    for jj = 1:size(dt,1)
        % find best lon and lat index
        [~,ilon] = min(abs(lon - mlon(jj)));
        [~,ilat] = min(abs(lat - mlat(jj)));
        [~,idt] = min(abs(dt - dt(jj)));
        spec = [spec, sfax * reshape(p2l(ilon,ilat,:,idt), size(p2l,3), 1)];
    end
    
    % append time
    dts = [dts, dt'];
end
dts.TimeZone = 'UTC';

% datetimes
dt_0 = datetime(2018, 9, 13, 'TimeZone', 'UTC', 'Format', ...
    'uuuu-MM-dd''T''HH:mm:ss.SSSSSS');
dt_week = dt_0 + calweeks(0:2:49);

for ii = 1:size(dt_week,2)-1
    [~,idt_b] = min(abs(dts - dt_week(ii)));
    [~,idt_e] = min(abs(dts - dt_week(ii+1)));
    spec_weekly = spec(:,idt_b:idt_e);
    
    % compute spectral density
    if strcmp(midval, 'mean')
        SDmid = mean(spec_weekly, 2);
    else
        SDmid = median(spec_weekly, 2);
    end
    SDstd = std(spec_weekly, 0, 2);
    if strcmp(intval, 'std')
        kcon = 1.96;
        SDU = SDmid + kcon * SDstd;
        SDL = SDmid - kcon * SDstd;
    else
        SDU = prctile(spec_weekly, 95, 2);
        SDL = prctile(spec_weekly, 5, 2);
    end
    
    % write data
    title = sprintf('%d_%02d_%02d', dt_week(ii).Year, dt_week(ii).Month, ...
        dt_week(ii).Day);
    fid = fopen(strcat(savedir, mfilename, '_', title, '.txt'), 'w');
    % the columns: F     median   std   SwU(95%)     SwL(5%)
    data = [f, SDmid, SDstd, SDU, SDL]';
    fprintf(fid, '%10.6f %10.6f %10.6f %10.6f %10.6f\n', data);
    fclose(fid);
end
end