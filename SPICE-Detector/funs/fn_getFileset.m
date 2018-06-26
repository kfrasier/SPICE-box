function [fullFiles,fullLabels] = fn_getFileset(p,detFiles)
% Make list of what you're going to name your output files, for easy
% reference later.
fullFiles = []; % wav or xwav
fullLabels = []; % .c files

for f2 = 1:size(detFiles,1)
    thisFile = detFiles(f2,:);
    fullFiles{f2}= thisFile;
    [pathStr, thisName, ext] = fileparts(thisFile);
    [~,subDir] = fileparts(pathStr);
    thisName2 = [thisName,ext];
    if strfind(thisName2,'.x.wav')
        thisLabel = strrep(thisName2,'.x.wav','.c');
    elseif strfind(thisName2,'.wav')
        thisLabel = strrep(thisName2,'.wav','.c');
    elseif strfind(thisName2,'.WAV')
        thisLabel = strrep(thisName2,'.WAV','.c');
    end
    fullLabels{f2} = fullfile(p.metaDir,subDir,thisLabel);
end
