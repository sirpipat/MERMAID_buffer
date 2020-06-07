function [trigs,dtrigs] = findarrivals(t,x,fs,p)
xf = bandpass(x,fs,2,10,2,2,'butter','linear');
[trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs] = ...
    stalta(xf,1/fs,[0 seconds(t(end)-t(1))],10,100,[],[],[],[],[],[]);

if p
    figure(11)
    set(gcf,'Unit','inches','Position',[2 2 6.5 3]);

    ax1 = subplot('Position', [0.07 0.57 0.87 0.35]);
    plot(t,xf,'k','LineWidth',1);
    hold on
    for ii = 1:length(trigs)
        vline(ax1,t(trigs(ii)),'--',2,'r');
        vline(ax1,t(dtrigs(ii)),'--',2,'g');
    end
    hold off
    xlim([min(t) max(t)]);
    grid on
    title('bp2-10')
    ax1.XAxis.Visible = 'off';

    ax2 = subplot('Position', [0.07 0.15 0.87 0.35]);
    plot(t,ratio,'k','LineWidth',1);
    xlim([min(t) max(t)]);
    hold on
    for ii = 1:length(trigs)
        vline(ax2,t(trigs(ii)),'--',2,'r');
        vline(ax2,t(dtrigs(ii)),'--',2,'g');
    end
    hold off
    grid on
    title('sta-lta ratio');

    figdisp([mfilename, '_run'], [], [], 2, [], 'epstopdf');
end
end