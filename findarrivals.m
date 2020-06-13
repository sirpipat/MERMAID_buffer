function [t_trigs,t_dtrigs] = findarrivals(x,fs,sta,lta,p)
% [t_trigs,t_dtrigs] = FINDARRIVALS(x,fs,sta,lta,p)
% Detect signal arrivals and return the trigger/detrigger times from the 
% beginning. It plots the time-series of the signal with
% triggers/detriggers when p is set to true.
%
% INPUT:
% x         Vector containing the signal
% fs        Sampling rate
% sta       Short-term averaging window length (s)
% lta       Long-term averaging window length (s)
% p         Options to plot [true - plot, false - no plot]
%
% OUTPUT:
% t_trigs   List of trigger times from the beginning
% t_dtrigs   List of detrigger times from the beginning
%
% Last modified by Sirawich Pipatprathanporn: 06/01/2020

t = (0:length(x)-1) / fs;
[trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs] = ...
    stalta(x,1/fs,[0 t(end)-t(1)],sta,lta,[],[],[],[],[],[]);

t_trigs = t(trigs);
t_dtrigs = t(dtrigs);

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