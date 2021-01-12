function wavetrains(L, dur, a, k, p0, w, dx, dt, speed, savedir)
% WAVETRAINS(L, dur, a, k, p0, w, dx, dt, speed, savedir)
%
% Plots time progression of several wave trains and save the plots as an 
% mp4 video.
%
% INPUT
% L         length
% dur       duration
% a         amplitudes of waves
% k         wave numbers
% p0        initial phases
% w         angular frequencies
% dx        spatial spacing
% dt        temporal spacing
% speed     speed reduction between plots
% savedir   directory of the output mp4 video
%
% Last modified by Sirawich Pipatprathanporn, 01/11/2021

figure
clf
set(gcf, 'Unit', 'inches', 'Position', [18 8 6.5 4]);
Lex = 1.5 * L;
for t = 0:dt:dur
    p = p0 - (w * t) - (k * 0.25 * L);
    [x, y] = sinewave(Lex, a, k/2/pi, p, 1/dx);
    x = x - 0.25 * L;
    % compute the envelope of the waves
    [yu, yl] = envelope(y, length(y), 'analytic');
    cla
    plot(x, y, 'LineWidth', 0.8)
    hold on
    plot(x, yu, 'r', 'LineWidth', 0.8)
    plot(x, yl, 'r', 'LineWidth', 0.8)
    grid on
    xlim([0 L])
    ylim([-1.1 1.1] * sum(a))
    title(sprintf('t = %.3f s', t))
    hold off
    xlabel('position (m)')
    ylabel('water height (m)')
    set(gca, 'FontSize', 12);
    F(round(t/dt)+1) = getframe(gcf);
    drawnow
end

% create the video writer with speed * 1/dt fps
writerObj = VideoWriter(strcat(savedir, mfilename, '.mp4'), 'MPEG-4');
writerObj.FrameRate = round(speed * 1/dt);

% open the video writer
open(writerObj);
% wrtie the frames to the video
for ii = 1:length(F)
    % convert the image to a frame
    frame = F(ii);
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
end