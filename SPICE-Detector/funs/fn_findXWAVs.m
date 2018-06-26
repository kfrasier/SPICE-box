function xwavNames = fn_findXWAVs(p)
% also returns .wav files

% Find folders in baseDir
folders = dir(p.baseDir);
trueIdx = [];
% Remove those that don't belong to data
for fidx = 1:length(folders)
    true = strfind(folders(fidx).name, p.depl);
    decim = strfind(folders(fidx).name, 'd100');
    other = strfind(folders(fidx).name, 'other');
    % (you can use "other" in name to avoid scanning for xwavs)
    if isempty(true) || ~isempty(decim) || ~isempty(other)
        trueIdx(fidx) = 0;
    else
        trueIdx(fidx) = 1;
    end
end

keep = find(trueIdx==1);

% Build file structure or use guided detection spreadsheet to identify files of
% interest.
folderNames = {};
m = 1;
for fidx = 1:length(keep)
    if isdir(fullfile(p.baseDir,folders(keep(fidx)).name)) == 1
        folderNames{m,1} = char(folders(keep(fidx)).name);
        m = m+1;
    end
end

% Pull out x.wav files from all folders, combine full paths into one long list
xwavNames = [];
for fidx = 1:size(folderNames,1)
    xwavDir = fullfile(p.baseDir,folderNames{fidx,1});
    metaSubDir = fullfile(p.metaDir,folderNames{fidx,1});
    if ~isdir(metaSubDir)
        mkdir(metaSubDir)
    end
    % list of files
    d = dir(fullfile(xwavDir,'*.wav')); % list of wav and/or xwav files
    xwavs = char(d.name);      % file names in directory
    
    % make full path filenames
    xwavList = [];
    for s = 1:size(xwavs,1)
        xwavList(s,:) = fullfile(p.baseDir,folderNames{fidx,1},xwavs(s,:));
    end
    xwavNames = [xwavNames;char(xwavList)];
end

