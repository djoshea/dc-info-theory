function [infs, nspikes, Hresponse, Hnoise, Hstim, p] = minf2(outcount, stimtrain, timebins, outcountbins, usestims)

    r = outcount;

    nspikes = 0;

    for j=1:length(usestims);
      nspikes = nspikes + sum(r(stimtrain == usestims(j)));
    end
    
    [infs, p, Hresponse, Hnoise, nstims] = computemutinf6(r, outcountbins, stimtrain, usestims);
    Hstim = log2(nstims);
end