function specdensplot_sac()

[allsacfiles,sndex] = sacdata(getenv('SAC'));

for ii = 1:sndex
    [~,Hdr,~,~,~] = readsac(allsacfiles{ii});
    dt_ref = datetime(Hdr.NZYEAR, 1, 0, Hdr.NZHOUR, Hdr.NZMIN, Hdr.NZSEC, ...
        Hdr.NZMSEC, 'TimeZone', 'UTC', 'Format', ...
        'uuuu-MM-dd''T''HH:mm:ss.SSSSSS') + days(Hdr.NZJDAY);                          
    dt_B = dt_ref + seconds(Hdr.B);
    dt_E = dt_ref + seconds(Hdr.E);
    
    % Assume the buffer's sampling rate to be twice of the SAC's sampling rate
    fs = (Hdr.NPTS - 1) / (Hdr.E - Hdr.B) * 2;
    
    % finds raw file(s) containing dt_B and dt_E
    [sections,intervals] = getsections(getenv('ONEYEAR'),...
        dt_B-seconds(100),dt_E+seconds(300),fs);
    
    % reads the section from raw file(s)
    % Assuming there is only 1 secion
    [x,dt_b,dt_e] = readsection(sections{1},intervals{1}{1},...
        intervals{1}{2},fs);

    % relative position of the sliced section in the file
    [~,dt_start,dt_end] = readOneYearData(sections{1},fs);
    p = [(dt_b - dt_start) (dt_e - dt_start)] / (dt_end - dt_start) * 100;
    
    nfft = round(100 * fs);
    lwin = nfft;
    
    timfreqplot(x,[],[],[],[],dt_b,nfft,fs,lwin,70,10,0,'s',p,false);
%     figure(3);
%     set(gcf,'Unit','inches','Position',[2 2 6.5 6.5]);
%     clf
%     ax = subplot('Position', [0.1 0.5 0.82 0.34]);
%     
%     p = specdensplot(x,nfft,fs,lwin,70,10,'s');
%     p(1).Color = [0.8 0.4 0];
%     p(2).Color = [1 1 1];
%     p(3).Color = [1 1 1];
%     grid on
%     ylim([40 140]);
%     
%     % fix the precision of the time on XAxis label
%     ax.XAxis.Label.String = sprintf('frequency (Hz): %d s window', round(nfft/fs));
%     
%     % fix the precision of the frequency on YAxis label
%     y_label = ax.YAxis.Label.String;
%     y_split = split(y_label, '=');
%     f_string = sprintf(' %.4f', fs/nfft);
%     y_label = strcat(y_split{1}, ' =', f_string);
%     ax.YAxis.Label.String = y_label;
% 
%     % add label on the top and right
%     ax.TickDir = 'both';
%     axs = doubleaxes(ax);
% 
%     % add axis label
%     inverseaxis(axs.XAxis, 'Period (s)');
%     
%     % add title
%     axs.Title.String = strcat(string(dt_begin),' -- ', string(dt_end));
    
    fig = gcf;
    fig.Children(9).Title.String = strcat(string(dt_b),' -- ', ...
        string(dt_e));

    % save figure
    filename = strcat('specdensplot_event_',removepath(allsacfiles{ii}));
    figdisp(filename,[],[],2,[],'epstopdf');
end
end