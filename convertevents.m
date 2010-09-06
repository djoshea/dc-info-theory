function [rateBin rateHz] = convertevents(eventCountsBySweep, rateBinBoundsPerTimeBin, timebins)
  % rateBin(sweepno, timebinno) = rate bin number for number of events in this bin
  % rateHz(sweepno, timebinno) = actual rate of events in this bin
  % timebins must be in seconds for Hz to be valid
  
nsweeps = length(eventCountsBySweep);
rateHz = zeros(nsweeps, length(timebins)-1);
rateBin = zeros(nsweeps, length(timebins)-1);

for iSweep=1:nsweeps,
  % first find EPSCs corresponding to this sweep
  eventtimes = eventCountsBySweep{iSweep};
 
  for iTimeBin=2:length(timebins),
    % next count the number of events in this timebin
    eventsInThisBin = sum(eventtimes >= timebins(iTimeBin-1) & eventtimes < timebins(iTimeBin));
    
    % next convert rates to symbols using the ratebins
    rateBin(iSweep,iTimeBin-1) = -1;
    for iRateBin=2:length(rateBinBoundsPerTimeBin),
        if(eventsInThisBin >= rateBinBoundsPerTimeBin(iRateBin-1) && eventsInThisBin < rateBinBoundsPerTimeBin(iRateBin))
            rateBin(iSweep,iTimeBin-1) = iRateBin-1;
            break;
        end
    end
    if eventsInThisBin >= rateBinBoundsPerTimeBin(length(rateBinBoundsPerTimeBin))
        % more than the maximal bin, throw it away
        rateBin(iSweep,iTimeBin-1) = NaN;
    end
    
    rateHz(iSweep, iTimeBin-1) = eventsInThisBin / (timebins(iTimeBin) - timebins(iTimeBin-1));
  end
end


  