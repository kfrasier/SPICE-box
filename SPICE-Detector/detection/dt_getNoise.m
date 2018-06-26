function noise = dt_getNoise(candidatesRel,stop,p,hdr)
% Get noise

maxClickSamples = ceil(hdr.fs  /1e6 * p.maxClick_us);
noise = [];
candidatesRelwEnds = [1,candidatesRel,stop];
dCR = diff(candidatesRelwEnds);
[mC,mI] = max(dCR);
if mC > 2*maxClickSamples
    noiseStart = candidatesRelwEnds(mI)+maxClickSamples;
    noise = [noiseStart, noiseStart+maxClickSamples];
end

if isempty(noise) % if it didn't find any noise, grab some at random.
    noise = [1,maxClickSamples/2];
    %disp('Warning: No noise sample available')
end