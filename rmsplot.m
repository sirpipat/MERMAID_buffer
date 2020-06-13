function rmsplot(x,fs,dt_begin,win)

dt_begin.Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS';
%% calculation of mov rms
t = dt_begin + seconds((0:length(x)-1) / fs);
zero_line = zeros(1,length(x));
x_mov_rms = movmean(x .^ 2, round(fs * win)) .^ 0.5;
x_mov_rms_long = movmean(x .^ 2, round(fs * win * 20)) .^ 0.5;
x_total_rms = rms(x);
x_rms_mean = mean(x_mov_rms);
one_line = ones(1,length(x));
%% plot
figure(1)
set(gcf,'Unit','inches','Position',[2 2 6.5 3]);
clf
plot(t,x/x_rms_mean,'Color',rgbcolor('k'));
hold on
plot(t,zero_line,'Color',rgbcolor('v'),'LineWidth',1.5);
%plot(t,ones(1,length(x))*x_total_rms/x_rms_mean,'m','LineWidth',1.5');
plot(t,x_mov_rms/x_rms_mean,'Color',rgbcolor('r'),'LineWidth',1);
plot(t,x_mov_rms_long/x_rms_mean,'Color',rgbcolor('g'),'LineWidth',1);
plot(t,one_line,'Color',rgbcolor('my blue'),'LineWidth',1.5);
hold off
grid on
xlim([t(1) t(end)]);
ylim([-1 1] * 10);
xlabel('time')
ylabel('x / mean(x_{mov rms})')
title(sprintf('Moving rms: window = %.2f, %.2f s', win, win*20))
set(gca,'Position',[0.08 0.16 0.9 0.76]);
%% save figure
savefile = strcat(mfilename, '_', replace(string(dt_begin), ':', '_'), '.eps');
figdisp(savefile, [], [], 2, [], 'epstopdf');
end