function [x, t_begin, t_end] = readFromEnd(filename, fs)

defval('fs', 40);

% convert seconds to days
d2s = 86400;

x = loadb(filename, 'int32', 'l');
t_end = file2datetime(filename);
t_begin = t_end - ((length(x) - 1) / fs) / d2s;
end