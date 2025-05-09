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
% Last modified by Sirawich Pipatprathanporn, 05/09/2025

defval('savedir', getenv('EPS'))

% determine largest image size
dim = [0 0];
for ii = 1:length(images)
    A = imread(images{ii}, ext);
    dim(1) = max(dim(1), size(A, 1));
    dim(2) = max(dim(2), size(A, 2));
end

% create the video writer
v = VideoWriter(strcat(savedir, '/', mfilename, '_', savename, '.mp4'), 'MPEG-4');
v.FrameRate = framerate;

% open the video writer
open(v);
% wrtie the frames to the video
for ii = 1:length(images)
    A = imread(images{ii}, ext);
    % pad white pixels to match the size of the largest image
    if size(A,1) < dim(1)
        A(size(A,1)+1:dim(1), :, :) = uint8(255);
    end
    if size(A,2) < dim(2)
        A(:, size(A,2)+1:dim(2), :) = uint8(255);
    end
    try
        writeVideo(v, A);
    catch ME
        keyboard
    end
end
% close the writer object
close(v);
end