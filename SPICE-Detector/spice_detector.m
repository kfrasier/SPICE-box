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
    fprintf('Loading settings file %s\n',detParamsFile)
    run(detParamsFile);
else
    % If no settings file provided, prompt for input
    currentDir = mfilename('fullpath');
    expectedSettingsDir = fullfile(fileparts(currentDir),'settings');
    [settingsFileName,settingsFilePath , ~] = uigetfile(expectedSettingsDir);
    if ~isempty(settingsFileName)
        settingsFullFile = fullfile(settingsFilePath,settingsFileName);
        fprintf('Loading settings file %s\n',settingsFullFile)
        run(settingsFullFile);
    else 
        error('No settings file selected')
    end
end

if detParams.diary
	diary('on')
end

detParams = dt_buildDirs(detParams);

% Build list of (x)wav names in the base directory.
% Right now only wav and xwav files are looked for.
detFiles = fn_findXWAVs(detParams);

if detParams.guidedDetector && ~isempty(detParams.gDxls)
    [detFiles,encounterTimes] = fn_guidedDetection(detFiles,detParams);
    fprintf('Using guided detections from file %s \n',detParams.gDxls')
else 
    encounterTimes = [];
end

% return a list of files to be built
[fullFiles,fullLabels] = fn_getFileset(detParams,detFiles); 

% profile on
% profile clear
if ~isempty(detFiles)
    % Short time detector
    if detParams.lowResDet
        tic 
        display('Beginning low-res detection')
        dt_LR_batch(fullLabels,fullFiles,detParams); % run detector
        display('Done with low-res detector')
        toc
    end
    
    % High res detector
    if detParams.highResDet
        tic
        display('Beginning high-res detection')
        dt_HR_batch(fullFiles,fullLabels,detParams,encounterTimes)
        display('Done with high-res detector')
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