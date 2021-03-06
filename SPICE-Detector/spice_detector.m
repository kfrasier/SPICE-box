function spice_detector(varargin)

% All input parameters should be contained within a script
% See detector_settings_default.m  for default settings and descriptions. 
% Make your own versions(s) with different names to modify the settings as
% you see fit.

fclose all;

% Load detector settings
detParamsFile = [];

if nargin == 1 
    % Check if settings file was passed in function call
	detParamsFile = varargin{1};	
    % If so, load it
    fprintf('Loading settings file %s\n\n',detParamsFile)
    run(detParamsFile);
else
    % If no settings file provided, prompt for input
    currentDir = mfilename('fullpath');
    expectedSettingsDir = fullfile(fileparts(currentDir),'settings');
    [settingsFileName,settingsFilePath , ~] = uigetfile(expectedSettingsDir);
    if ~isempty(settingsFileName)
        settingsFullFile = fullfile(settingsFilePath,settingsFileName);
        fprintf('Loading settings file %s\n\n',settingsFullFile)
        run(settingsFullFile);

    else 
        error('No settings file selected')
    end
end

if detParams.verbose
    % display settings variables
    disp(detParams)
end

if detParams.diary
	diary('on')
end

detParams = dt_buildDirs(detParams);

% Build list of (x)wav names in the base directory.
% Right now only wav and xwav files are looked for.
fullFileNames = fn_findXWAVs(detParams);

if detParams.guidedDetector && ~isempty(detParams.gDxls)
    [fullFileNames,encounterTimes] = fn_guidedDetection(fullFileNames,detParams);
    fprintf('Using guided detections from file %s \n',detParams.gDxls')
else 
    encounterTimes = [];
end

% return a list of files to be built
fullLabels = fn_getFileset(detParams,fullFileNames); 

% profile on
% profile clear
if ~isempty(fullFileNames)
    % Short time detector
    if detParams.lowResDet
        tic 
        fprintf('Beginning low-res detection\n\n')
        dt_LR_batch(fullLabels,fullFileNames,detParams); % run detector
        fprintf('Done with low-res detector\n\n')
        toc
    end
    
    % High res detector
    if detParams.highResDet
        tic
        fprintf('Beginning high-res detection\n\n')
        dt_HR_batch(fullFileNames,fullLabels,detParams,encounterTimes)
        fprintf('Done with high-res detector\n\n')
        toc
    end
else
    disp('Error: No wav/xwav files found')
end

% profile viewer
% profile off
if detParams.diary
	diary('off')
end