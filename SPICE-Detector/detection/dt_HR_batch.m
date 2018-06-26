function dt_HR_batch(fullFiles,fullLabels,p,encounterTimes)

N = length(fullFiles);
previousFs = 0; % make sure we build filters on first pass

for idx1 = 1:N % for each data file
    fprintf('beginning file %d of %d \n',idx1,N)
    %(has to be inside loop for parfor, ie, filters are rebuilt every time,
    % can be outside for regular for)
    
    recFile = fullFiles{idx1};
    labelFile = fullLabels{idx1};
    
    % read file header
    hdr = dt_getHRinput(recFile,p);
    
    if isempty(hdr)
        continue % skip if you couldn't read a header
    elseif hdr.fs ~= previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        [previousFs,p] = fn_buildFilters(p,hdr.fs);
        
        p = fn_interp_tf(p);
        if ~exist('p.countThresh') || isempty(p.countThresh)
            p.countThresh = (10^((p.dBppThreshold - min(p.xfrOffset))/20))*(1/2);
        end
    end
    
    if exist(labelFile,'file')
        % Read in the .c file produced by the short term detector.
        [starts,stops] = io_readLabelFile(labelFile);
    else
        fprintf('No low res label file matching %s\n',recFile)
        continue
    end
    % Open xwav file
    fid = fopen(recFile, 'r');
    
    % Look for clicks, hand back parameters of retained clicks
    [cParams,f] = dt_processHRstarts(fid,starts,stops,...
        p,hdr,recFile);
    
    % Done with that file
    fclose(fid);
    fclose all;
    fprintf('done with %s\n', recFile);
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    clickTimes = sortrows(cParams.clickTimes);
    
    keepFlag = dt_postproc(labelFile,clickTimes,p,hdr,encounterTimes);
    keepIdx = find(keepFlag==1);
    
    % save a mat file now, rather than recalculating later
    cParams.clickTimes = clickTimes(keepIdx,:);
    cParams.ppSignalVec = cParams.ppSignalVec(keepIdx,:);
    cParams.durClickVec = cParams.durClickVec(keepIdx,:);
    cParams.bw3dbVec = cParams.bw3dbVec(keepIdx,:);
    
    cParams.specClickTfVec = cParams.specClickTfVec(keepIdx,:);
    if p.saveNoise
        cParams.specNoiseTfVec = cParams.specNoiseTfVec(keepIdx,:);
    end
    cParams.peakFrVec = cParams.peakFrVec(keepIdx,:);
    cParams.deltaEnvVec = cParams.deltaEnvVec(keepIdx,:);
    cParams.nDurVec = cParams.nDurVec(keepIdx,:);
    
    if ~isempty(keepIdx)
        cParams.yFiltVec = cParams.yFiltVec(keepIdx);
        cParams.yFiltBuffVec = cParams.yFiltBuffVec(keepIdx);
        if p.saveNoise
            cParams.yNFiltVec = cParams.yNFiltVec(keepIdx);
        end
    else
        cParams.yFiltVec = {};
        cParams.yFiltBuffVec = {};
        cParams.yNFiltVec = {};
    end
    
    fn_saveDets2mat(strrep(labelFile,'.c','.mat'),cParams,f,hdr,p);
end