function [hdr] = dt_getHRinput(fullFile,p)
% figure out how to read header info


% Is it a wav or an xwav file?
[fileType, ~] = io_getFileType(fullFile);

% Retrieve header information for this file
if fileType == 1
    hdr = io_readWavHeader(fullFile, p.DateRE);
else
    hdr = io_readXWAVHeader(fullFile, p,'ftype', fileType);
end
