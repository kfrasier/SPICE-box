function [completeClicks, noise] = dt_HR(p,hdr,filteredData)

% Tyack & Clark 2000 cite Au (1993) in Hearing by Whales & Dolphins, Au
% (ed.) stating that dolphins can distinguish clicks separated by as
% little as 205 us.

minGapSamples = ceil(p.mergeThr*hdr.fs/1e6);
energy = filteredData.^2;
candidatesRel = find(energy > (p.countThresh^2));

completeClicks = [];
noise = [];
if ~ isempty(candidatesRel)
    if p.saveNoise
        noise = dt_getNoise(candidatesRel,length(energy),p,hdr);
    end
    [sStarts, sStops] = dt_getDurations(candidatesRel, minGapSamples,length(energy));

    [cStarts,cStops]= dt_HR_expandRegion(p,hdr,...
            sStarts,sStops,energy);
    
    completeClicks = [cStarts, cStops];

end
