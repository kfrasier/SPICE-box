function noiseTimes = dt_getNoise(candidatesRel,dataLen,p,hdr)
% Get noise

maxClickSamples = ceil(hdr.fs  /1e6 * p.maxClick_us);
noiseTimes = [];
candidatesRelwEnds = [1,candidatesRel,dataLen];
dCR = diff(candidatesRelwEnds);
[mC,mI] = max(dCR);
% look for a stretch of data that has no detections
if dataLen - (candidatesRelwEnds(mI)+maxClickSamples/2) > maxClickSamples
    noiseStart = candidatesRelwEnds(mI)+maxClickSamples/2;
    noiseTimes = [noiseStart, noiseStart+maxClickSamples];
end