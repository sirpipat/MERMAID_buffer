function ncplots_wavewatch(ncfile,var)
% NCPLOTS_WAVEWATCH(ncfile,var)
% Reads a variable from a NC file and then plot. Only works for waveheight
% files from ftp://ftp.ifremer.fr/ifremer/ww3/HINDCAST/SISMO/

vardata = ncread(ncfile,var);

for ii = 1:size(vardata,3)
    figure(4);
    imagesc(vardata(:,:,ii)');
    axis xy
    colorbar
    figdisp(strcat(mfilename,'_',string(ii),'.eps'),[],[],2,[],'epstopdf');
end
end