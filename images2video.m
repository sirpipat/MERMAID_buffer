function v = images2video(images, ext, framerate, savename, savedir)
% v = IMAGES2VIDEO(images, ext, framerate, savename)
%
% Convert a series of photos to video.
%
% INPUT
% images        a series of images
% ext           file extension of the images
% framerate     framerate of the video (frames per second)
% savename      name of the video
% savedir       directory of the saved video
%               The video is saved as 'images2video_savename.mp4'
%
% OUTPUT
% v             video object
%
% Last modified by Sirawich Pipatprathanporn, 06/09/2021

defval('savedir', getenv('EPS'))

% create the video writer
v = VideoWriter(strcat(savedir, '/', mfilename, '_', savename, '.mp4'), 'MPEG-4');
v.FrameRate = framerate;

% open the video writer
open(v);
% wrtie the frames to the video
for ii = 1:length(images)
    A = imread(images{ii}, ext);
    writeVideo(v, A);
end
% close the writer object
close(v);
end