function [ outcount outrateHz ] = calcFiringRate( spiketimes, timebins )
% timebins and spiketimes both in s

nsweeps = max(spiketimes(1,:));
ntimebins = length(timebins)-1;
outcount = zeros(nsweeps, ntimebins);
outrateHz = zeros(nsweeps, ntimebins);

for i=1:nsweeps,
    spikes = spiketimes(2, spiketimes(1,:) == i);
    for j=2:length(timebins),
        outcount(i,j-1) = sum(spikes > timebins(j-1)/1000 & spikes <= timebins(j)/1000);
        outrateHz(i,j-1) = outcount(i,j-1) / ((timebins(j) - timebins(j-1)) / 1000);
    end
end

end

