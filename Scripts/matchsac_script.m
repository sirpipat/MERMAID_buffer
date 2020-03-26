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
        matchsac(allsacfiles{ii}, getenv('ONEYEAR'), [], true);
end

%% plot the time shift vs hour since the beginning and CC vs hours since the beginning
dt_begin = DUMMY_DATETIME;
for ii = 1:sndex
    [sections, intervals] = getsections(getenv('ONEYEAR'),dt_B(1,ii),dt_E(1,ii),40);
    dt_begin(1,ii) = file2datetime(sections{1});
end

t_since = hours((dt_B - dt_begin) + seconds(t_shift));
t_sincef = hours((dt_B - dt_begin) + seconds(t_shiftf));

% remove unmatched records
where = and(abs(t_shiftf) < 200, abs(t_shift) < 200);
t_since = t_since(where);
t_sincef = t_sincef(where);
t_shift = t_shift(where);
t_shiftf = t_shiftf(where);

% find best fit lines
P_t_shift = polyfit(t_since, t_shift, 1);
P_t_shiftf = polyfit(t_sincef, t_shiftf, 1);

P_Cmax = polyfit(t_since, Cmax(where), 1);
P_Cfmax = polyfit(t_sincef, Cfmax(where), 1);

figure(7)
set(gcf,'Units','inches','Position',[1 1 9 4]);
subplot('Position', [0.06 0.11 0.43 0.8]);
scatter(t_since, t_shift, 'Marker', 'x');
hold on
scatter(t_sincef, t_shiftf, 'Marker', '+');
plot(t_since, P_t_shift(1) * t_since + P_t_shift(2));
plot(t_sincef, P_t_shiftf(1) * t_sincef + P_t_shiftf(2));
hold off
grid on
P_label = sprintf('t-shfit [Raw] = (%6.4f) H + (%6.4f)', P_t_shift(1), P_t_shift(2));
Pf_label = sprintf('t-shift [Filtered] = (%6.4f) H + (%6.4f)', P_t_shiftf(1), P_t_shiftf(2));
legend('Time shift [Raw]','Time shift [Filtered]',P_label,Pf_label,...
    'Location','northwest');
ylim([0 0.55]);
xlabel('Hours since the beginning of raw data section [hours]');
ylabel('Time shift [s]');
title('Time shift vs Hours since the beginning');

subplot('Position', [0.55 0.11 0.43 0.8]);
scatter(t_since, Cmax(where), 'Marker', 'x');
hold on
scatter(t_sincef, Cfmax(where), 'Marker', '+');
plot(t_since, P_Cmax(1) * t_since + P_Cmax(2));
plot(t_sincef, P_Cfmax(1) * t_sincef + P_Cfmax(2));
hold off
grid on
P_label = sprintf('CC [Raw] = (%6.4f) H + (%6.4f)', P_Cmax(1), P_Cmax(2));
Pf_label = sprintf('CC [Filtered] = (%6.4f) H + (%6.4f)', P_Cfmax(1), P_Cfmax(2));
legend('CC [Raw]','CC [Filtered]',P_label,Pf_label,'Location','southwest');
ylim([0 1.3]);
xlabel('Hours since the beginning of raw data section [hours]');
ylabel('Correlation coefficients');

title('CC vs Hours since the beginning');
figdisp('timeshift_vs_hours_since_beginning', [], [], 2, [], 'epstopdf');

%% plots histogram of CC [raw] next to histogram of CC [filtered]
figure(8)
set(gcf,'Units','inches','Position',[1 1 9 4]);
subplot('Position', [0.06 0.11 0.43 0.8]);
h = histogram(Cmax(where));
h.BinWidth = 0.0005;
grid on
xlabel('Correlation coefficient');
ylabel('Counts');
title_name = strcat('Histogram of CC [raw buffer, raw sac report]');
title(title_name);
figdisp('raw_cc_histogram', [], [], 2, [], 'epstopdf');

subplot('Position', [0.55 0.11 0.43 0.8]);
h = histogram(Cfmax(where));
h.BinWidth = 0.05;
grid on
xlabel('Correlation coefficient');
ylabel('Counts');
title_name = strcat('Histogram of CC [filtered buffer, filtered sac report]');
title(title_name);
figdisp('filtered_cc_histogram', [], [], 2, [], 'epstopdf');
