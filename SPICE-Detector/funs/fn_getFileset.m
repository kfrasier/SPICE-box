function fullLabels = fn_getFileset(p,detFiles)
% Make list of what you're going to name your output files, for easy
% reference later. 
% mimics file structure of original recordings
fullLabels = cell(size(detFiles)); % .c files

for f2 = 1:size(detFiles,1)
    thisFile = detFiles{f2,1};
    thisName = strrep(thisFile,p.baseDir,'');
    if strfind(thisName,'.x.wav')
        thisLabel = strrep(thisName,'.x.wav','.c');
    elseif strfind(thisName2,'.wav')
        thisLabel = strrep(thisName,'.wav','.c');
    elseif strfind(thisName2,'.WAV')
        thisLabel = strrep(thisName,'.WAV','.c');
    end
    fullLabels{f2,1} = fullfile(p.metaDir,thisLabel);
    if ~isdir(fileparts(fullLabels{f2,1}))
        mkdir(fileparts(fullLabels{f2,1}))
    end
end


