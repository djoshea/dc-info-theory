function [z actualRates] = convertevents(x, ratebins, timebins)
  % z(sweepno, timebinno) = ratebinid for number of events in this bin
  % actualRates(sweepno, timebinno) = actual rate of events in this bin
nsweeps = max(x(2,:));

for i=1:nsweeps,
  % first find EPSCs corresponding to this sweep
  eventtimes = x(1, find(x(2,:) == i));
  
  % next count the number of EPSCs in each time bin
  for t=2:length(timebins),
    y = sum(eventtimes > timebins(t-1) & eventtimes <= ...
		   timebins(t));
    % next convert rates to symbols using the ratebins
    z(i,t-1) = -1;
    for j=2:length(ratebins),
      if y >= ratebins(j-1) & y < ratebins(j),
	z(i,t-1) = j-2;
	break;
      end
    end
    if y >= ratebins(length(ratebins)),
      z(i,t-1) = length(ratebins)-1;
    end
    
    actualRates(i, t-1) = y / (timebins(t) - timebins(t-1)) * 1000;
  end
end

  