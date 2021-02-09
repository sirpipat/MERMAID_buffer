function v = images2video(images, ext, framerate, savename)


% create the video writer
v = VideoWriter(strcat(pwd, '/', mfilename, '_', savename, '.mp4'), 'MPEG-4');
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