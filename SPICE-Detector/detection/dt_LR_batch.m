function dt_LR_batch(fullLabels,fullFiles,p)
% Runs a quick energy detector on a set of files using
% the specified set of detection parameters. Flags times containing signals
% of interest, and outputs the results to a .c file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(fullFiles,1);
previousFs = 0; % make sure we build filters on first pass

% get file type list
fTypes = io_getFileType(detFiles);

for idx = 1:N  % "parfor" works here, parallellizing the process across as
    % many cores as your machine has available.
    % It's faster, but the drawback is that if the code crashes,
    % it's hard to figure out where it was, and how many files
    % have been completed. It will also eat up your cpu.
    % You can use regular "for" too.
    outFileName = fullLabels{idx};
    detections = []; % initialize
    
    % Pull in a file to examine
    currentRecFile = fullFiles{idx};
    hdr = io_readXWAVHeader(currentRecFile,p,'fType',fTypes(idx));
    
    if isempty(hdr)
        warning(fprintf('No header info returned for file %s',...
            currentRecFile));
        disp('Moving on to next file')
        continue
    end
    
    % Read the file header info
    if fTypes(idx) == 1 
        [startsSec,stopsSec,p] = dt_LR_chooseSegments(p,hdr);
    else
        % divide xwav by raw file
        [startsSec,stopsSec] = dt_chooseSegmentsRaw(hdr);
    end    

    % Build a bandpass filter on first pass or if sample rate has changed
    if hdr.fs ~= previousFs
        [previousFs,p] = fn_buildFilters(p,hdr.fs);
        
        % also need to compute an amplitude threshold cutoff in counts
        % keep it conservative for now by using the transfer function
        % maximum across the band of interest
        p = fn_interp_tf(p);
        if ~exist('p.countThresh') || isempty(p.countThresh)
            p.countThresh = (10^((p.dBppThreshold - median(p.xfrOffset))/20))/2;
        end
    end
    
    % Open audio file
    fid = fopen(currentRecFile, 'r');
    buffSamples = p.LRbuffer*hdr.fs;
    % Loop through search area, running short term detectors
    for k = 1:length(startsSec)
        % Select iteration start and end
        startK = startsSec(k);
        stopK = stopsSec(k);
        
        % Read in data segment
        if strncmp(fType,'.wav',4)
            data = io_readWav(fid, hdr, startK, stopK, 'Units', 's',...
                'Channels', p.channel, 'Normalize', 'unscaled')';
        else
            data = io_readRaw(fid, hdr, k, p.channel);
        end
        if isempty(data)
            warning('No data read from current file segment. Skipping.')
            continue
        end
        % bandpass
        if p.filterSignal
            filtData = filtfilt(p.fB,p.fA,data);
        else
            filtData = data;
        end
        energy = filtData.^2;
        
        % Flag times when the amplitude rises above a threshold
        aboveThreshold = find(energy>((p.countThresh^2)));        
        
        % add a buffer on either side of detections.
        detStart = max((((aboveThreshold - buffSamples)/hdr.fs) + startK), startK);
        detStop = min((((aboveThreshold + buffSamples)/hdr.fs) + startK), stopK);
        
        % Merge flags that are close together.
        if length(detStart)>1
            [stopsM,startsM] = dt_mergeCandidates(buffSamples/hdr.fs,...
                detStop', detStart');
        else
            startsM = detStart;
            stopsM = detStop;
        end
        
        % Add current detections to overall detection vector
        if ~isempty(startsM)
            detections = [detections; [startsM,stopsM]];
        end
    end
    
    % done with current audio file
    fclose(fid);
    
    % Write out .c file for this audio file
    if ~isempty(detections)
        io_writeLabel(outFileName, detections);
    else % write zeros to file if no detections.
        io_writeLabel(outFileName, [0,0])
    end
end