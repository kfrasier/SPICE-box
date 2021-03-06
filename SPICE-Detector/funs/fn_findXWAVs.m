function fullFileNames = fn_findXWAVs(p)

% also returns .wav files
fList = fn_subdir(fullfile(p.baseDir,[p.depl,'*.wav']));

% Pull out x.wav files from all folders, combine full paths into one long list
fullFileNames = {fList(:).name}';

% check for duplicate file names and warn user if found
fileNames = cell(size(fullFileNames));
for iFN = 1:size(fullFileNames,1)
    [~, fileNameTemp,fileExtTemp] = fileparts(fullFileNames{iFN});
    fileNames{iFN} = [fileNameTemp,fileExtTemp];
end

[uFnames,uI] = unique(fileNames);
if size(uFnames,1)<size(fileNames,1)
    duplicateIdx = setdiff(uI,1:length(size(fileNames,1)));
    warning('Duplicate sound files found')
    disp(fileNames{duplicateIdx})
end
