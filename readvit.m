function text = readvit(file)
% text = readvit(file)
% 
% Load a .vit file
% 
% INPUT:
% file = filename string
% 
% last modified by Sirawich Pipatprathanporn, 10/07/2019

x = loadb(file, '*char', 'l');
text = convertCharsToStrings(x);
