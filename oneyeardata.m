function [allfiles,fndex]=oneyeardata(ddir)
% [allfiles,fndex]=ONEYEARDATA(ddir)
%
% INPUT:
%
%  ddir      Where you keep the data (trailing slash needed!)
%
% OUTPUT:
%
% allfiles   Bottom-file list with complete file names
% fndex      The total number of elements in the list
%
% EXAMPLE:
%
% [a,b]=oneyeardata;
% for index=1:b
% h=loadb(a{index},'int32','l');
% plot(h)
% pause 
% end
%
% Last modified by fjsimons-at-alum.mit.edu, 10/22/2019

% Remember that when using LS2CELL in full path mode, you need the
% trailing file separators
defval('ddir',fullfile(getenv('MERMAID'),'OneYearData/'))

% Makes the table of contents
allfiles={};
fndex=0;
mdirs=ls2cell(ddir,1);
for index=1:length(mdirs)
  ddirs=ls2cell(sprintf('%s/',mdirs{index}),1);
  for jndex=1:length(ddirs)
    files=ls2cell(sprintf('%s/',ddirs{jndex}),1);
    for ondex=1:length(files)
      allfiles{fndex+ondex}=files{ondex};
    end
    fndex=fndex+ondex;
  end
end

