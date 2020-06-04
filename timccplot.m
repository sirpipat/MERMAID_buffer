function timccplot(plotfilter)
%% Read all SAC files
sacdir = getenv('SAC');
[allsacfiles, sndex] = sacdata(sacdir);

%% Containers for start/end time, timeshift, and correlation coefficient
DUMMY_DATETIME = datetime(2000,1,1,0,0,0,'TimeZone','UTC');
dt_B = DUMMY_DATETIME;
dt_E = DUMMY_DATETIME;
Cmax = zeros(1,sndex);
Cfmax = zeros(1,sndex);
t_shift = zeros(1,sndex);
t_shiftf = zeros(1,sndex);

%% Plots SAC files with respect to raw buffers
%savedir = '/home/sirawich/research/plots/interp_matched_SACs/';
for ii = 1:sndex
    [dt_B(1,ii), dt_E(1,ii), Cmax(1,ii), Cfmax(1,ii), ...
        t_shift(1,ii), t_shiftf(1,ii)] = ...
        matchsac(allsacfiles{ii}, getenv('ONEYEAR'), [], [], true, ...
                 plotfilter);
end

keyboard;

%% plot the time shift vs hour since the beginning and CC vs hours since the beginning
% find the begin datetime of the raw buffer including each SAC report
dt_begin = DUMMY_DATETIME;
for ii = 1:sndex
    [sections, intervals] = getsections(getenv('ONEYEAR'),dt_B(1,ii),dt_E(1,ii),40);
    dt_begin(1,ii) = file2datetime(sections{1});
end
%%
% the time since dt_begin to the beginning time of the SAC segment
t_since = hours((dt_B - dt_begin) + seconds(t_shift));
if plotfilter
    t_sincef = hours((dt_B - dt_begin) + seconds(t_shiftf));
end

% remove unmatched records
where = abs(t_shift) < 200;
if plotfilter
    where = and(abs(t_shiftf) < 200, where);
end
t_since = t_since(where);
t_shift = t_shift(where);
if plotfilter
    t_sincef = t_sincef(where);
    t_shiftf = t_shiftf(where);
end
dt_begin = dt_begin(where);

% find all unique dt_begin
[dt_bu,idt_begin,idt_bu] = unique(dt_begin);
dt_begin_label = string(1:length(dt_bu));

% find best fit lines
P_t_shift = polyfit(t_since, t_shift, 1);
P_Cmax = polyfit(t_since, Cmax(where), 1);

if plotfilter
    P_t_shiftf = polyfit(t_sincef, t_shiftf, 1);
    P_Cfmax = polyfit(t_sincef, Cfmax(where), 1);
end

figure(7)
clf
set(gcf,'Units','inches','Position',[1 1 9 4]);
subplot('Position', [0.06 0.11 0.43 0.8]);
text(t_since, t_shift, dt_begin_label(idt_bu));
hold on
if plotfilter
    p2 = scatter(t_sincef, t_shiftf, 'Marker', '+');
end
p3 = plot(t_since, P_t_shift(1) * t_since + P_t_shift(2));
P_label = sprintf('t-shfit [Raw] = (%6.4f) H + (%6.4f)', P_t_shift(1), P_t_shift(2));
if plotfilter
    p4 = plot(t_sincef, P_t_shiftf(1) * t_sincef + P_t_shiftf(2));
    Pf_label = sprintf('t-shift [Filtered] = (%6.4f) H + (%6.4f)', P_t_shiftf(1), P_t_shiftf(2));
end
hold off
grid on
% legend('Time shift [Raw]','Time shift [Filtered]',P_label,Pf_label,...
%     'Location','northwest');
ylim([-0.1 0.5]);
xlim([0 140]);
xlabel('Hours since the beginning of raw data section [hours]');
ylabel('Time shift [s]');
title('Time shift vs Hours since the beginning');
delete(p3);
if plotfilter
    delete(p2);
    delete(p4);
end

subplot('Position', [0.6 0.11 0.38 0.8]);
p5 = scatter(t_since, Cmax(where), 'Marker', 'd', 'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'b');
hold on
if plotfilter
    p6 = scatter(t_sincef, Cfmax(where), 'Marker', '+');
end
p7 = plot(t_since, P_Cmax(1) * t_since + P_Cmax(2));
P_label = sprintf('CC [Raw] = (%6.4f) H + (%6.4f)', P_Cmax(1), P_Cmax(2));
if plotfilter
    p8 = plot(t_sincef, P_Cfmax(1) * t_sincef + P_Cfmax(2));
    Pf_label = sprintf('CC [Filtered] = (%6.4f) H + (%6.4f)', P_Cfmax(1), P_Cfmax(2));
end
hold off
grid on
% legend('CC [Raw]','CC [Filtered]',P_label,Pf_label,'Location','southwest');
ylim([0.998 1.0005]);
xlabel('Hours since the beginning of raw data section [hours]');
ylabel('Correlation coefficients');
delete(p7);
if plotfilter
    delete(p6);
    delete(p8);
end

title('CC vs Hours since the beginning');
figdisp('timeshift_vs_hours_since_beginning', [], [], 2, [], 'epstopdf');

%% plots histogram of CC [raw] next to histogram of CC [filtered]
figure(8)
if plotfilter
    set(gcf,'Units','inches','Position',[1 1 9 4]);
    subplot('Position', [0.06 0.11 0.43 0.8]);
else
    set(gcf,'Units','inches','Position',[1 1 4.5 4]);
    subplot('Position', [0.06 0.11 0.93 0.8]);
end

h = histogram(Cmax(where));
h.BinWidth = 0.0005;
grid on
xlabel('Correlation coefficient');
ylabel('Counts');
title_name = strcat('Histogram of CC [raw buffer, raw sac report]');
title(title_name);

if plotfilter
    subplot('Position', [0.55 0.11 0.43 0.8]);
    h = histogram(Cfmax(where));
    h.BinWidth = 0.05;
    grid on
    xlabel('Correlation coefficient');
    ylabel('Counts');
    title_name = strcat('Histogram of CC [filtered buffer, filtered sac report]');
    title(title_name);
end
figdisp('cc_histograms', [], [], 2, [], 'epstopdf');

end