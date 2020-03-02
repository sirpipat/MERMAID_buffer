function filelength_histogram()
% FILELENGTH_HISTOGRAM()
% plots histograms of all filelengths
%
% SEE ALSO:
% READ_FILESIZE
%
% Last modified by Sirawich Pipatprathanporn: 03/01/2020

% read the length of the files. Then, convert to hours
[allfilelengths, ~] = read_filesize();
alldurs = (allfilelengths - 1)/40/3600;

figure(2)
% Plot overall histogram
subplot(2,2,1)
h = histogram(alldurs);
h.BinWidth = 10;
hold on
text(125,325,sprintf('f_s = 40 Hz'));
hold off
xlim([0,190]);
xlabel('Length (hours) [bin width = 10 hours]');
ylabel('Counts');
grid on
ax = gca();
ax.TickDir = 'both';
ax.Title.String = 'Histograms of appearent file lengths';

% Plot long-time histogram
subplot(2,2,2)
h = histogram(alldurs);
h.BinWidth = 10;
hold on
text(135,25,sprintf('f_s = 40 Hz'));
hold off
xlim([20,190]);
ylim([0,30]);
xlabel('Length (hours) [bin width = 10 hours]');
ylabel('Counts');
grid on
ax = gca();
ax.TickDir = 'both';
ax.Title.String = 'Histograms of apparent file lengths';

% Plot short-time histogram
subplot(2,2,3)
h = histogram(alldurs);
h.BinWidth = 1;
hold on
text(13,240,sprintf('f_s = 40 Hz'));
hold off
xlim([0,20]);
xlabel('Length (hours) [bin width = 1 hour]');
ylabel('Counts');
grid on
ax = gca();
ax.TickDir = 'both';
ax.Title.String = 'Histograms of apparent file lengths';

% Plot short-time histogram
subplot(2,2,4)
h = histogram(A(19,:)/4/40/60);
h.BinWidth = 1;
hold on
text(40,200,sprintf('f_s = 40 Hz'));
hold off
xlim([0,60]);
xlabel('Length (minutes) [bin width = 1 minute]');
ylabel('Counts');
grid on
ax = gca();
ax.TickDir = 'both';
ax.Title.String = 'Histograms of apparent file lengths';
saveas(gcf(), sprintf('%shistogram_of_filelength.eps', filedir), 'epsc');
end