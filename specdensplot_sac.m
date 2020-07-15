function specdensplot_sac()

[allsacfiles,sndex] = sacdata(getenv('SAC'));

% reference spectral density files
SDdir = '/Users/sirawich/research/processed_data/monthly_SD_profiles/';
[allSDs,dndex] = allfile(SDdir);

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
        dt_B-seconds(100),dt_E+seconds(1800),fs);
    
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
    
    % add title
    fig = gcf;
    fig.Children(9).Title.String = strcat(string(dt_b),' -- ', ...
        string(dt_e));
    
    % read spectral density refernce data
    % September 2018 --> 1, August 2019 --> 12
    index = (dt_b.Year - 2018) * 12 + dt_b.Month - 8;
    fid = fopen(allSDs{index},'r');
    data = fscanf(fid,'%f %f %f %f %f',[5 Inf]);
    fclose(fid);
    % add reference spectral density of the month
    ax = fig.Children(4);
    axes(ax)
    hold on
    semilogx(data(1,:),data(2,:),'Color',rgbcolor('deep sky blue'));
    semilogx(data(1,:),data(4,:),'Color',rgbcolor('gray'));
    semilogx(data(1,:),data(5,:),'Color',rgbcolor('gray'));
    hold off
    
    % save figure
    filename = strcat('specdensplot_event_',removepath(allsacfiles{ii}));
    figdisp(filename,[],[],2,[],'epstopdf');
end
end
