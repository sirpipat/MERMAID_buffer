function [sfile, cmtfile, parfile, sac1D, sac3D] = readshakemovie(shakedir)
% [sfile, cmtfile, parfile, 1Dsac, 3Dsac] = READSHAKEMOVIE(shakedir)
% Read contents in a ShakeMovie directory. Once you download ShakeMovie of
% an earthquake, you need to move any files that are not SAC files from
% both 1D and 3D SAC directories. Those files include CMTSOLUTIONS,
% constants.h, Par_file, and STATIONS. 
%
% INPUT
% shakedir      root directory of ShakeMovie (with a trailing slash)
%
% OUTPUT
% sfile         STATION file
% cmtfile       CMTSOLUTION file
% parfile       Par_file
% sac1D         directory for 1D synthetic SAC files
% sac3D         directory for 3D synthetic SAC files
%
% EXAMPLE
% shakedir = ...
%       '/Users/sirawich/research/raw_data/ShakeMovie/C201907140910A/';
% [sfile, cmtfile, parfile, sac1D, sac3D] = readshakemovie(shakedir);
% [sac1Dfiles, sndex1] = allfile(sac1D);
% [sac3Dfiles, sndex3] = allfile(sac3D);
%
% Last modified by Sirawich Pipatprathanporn: 10/21/2020

sfile = strcat(shakedir, 'STATIONS');
cmtfile = strcat(shakedir, 'CMTSOLUTION');
parfile = strcat(shakedir, 'Par_file');
sac1D = strcat(shakedir, removepath(shakedir(1:end-1)), '.1D.sac/');
sac3D = strcat(shakedir, removepath(shakedir(1:end-1)), '.3D.sac/');
end