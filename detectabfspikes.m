function [spiketimes spiketimescell] = detectabfspikes(traces, si, varargin)
% filename = ABF file to open
% scalefactor converts to mV
% spikethreshold is the threshold for detecting a spike (in mV)
% refractory is the minimum refractory period between spikes (in
% timesteps)
% minrepol is the lower threshold for ending a spike that must be reached
% between spikes

par.spikethreshold = 0;
par.refractory = 2;
par.minrepol = -30;
par = structargs(par, varargin);
spikethreshold = par.spikethreshold;
refractory = par.refractory;
minrepol = par.minrepol;

nspikes = 0;
spiketimes = [];
spiketimescell = {};

% minrepol = minrepol;
% spikethreshold = spikethreshold;

nsweeps = size(traces,2);
for sweepno = 1:nsweeps,
%   [data,si] = abfload(filename, 'sweeps', sweepno);
  
  % assume data(:,1) = timepoints, data(:,2) = voltage trace  
  data = traces(:,sweepno);
  
  lastspiketime = -1000;
  reset = 1; % indicates whether the membrane potential has dipped
             % below minrepol
  
  spiketimescell{sweepno} = [];
             
  for n=2:length(data),
    if data(n) >= spikethreshold & data(n-1) < spikethreshold,
      if n*si*0.001 > lastspiketime + refractory,
        if reset,

          % found a spike
          nspikes = nspikes+1;
          lastspiketime = n*0.001*si;
          spiketimes(1, nspikes) = sweepno;
          spiketimes(2, nspikes) = lastspiketime / 1000;
          
          spiketimescell{sweepno}(end+1) = lastspiketime / 1000;
        end
      end
    elseif ~reset && data(n) <= minrepol,
      reset = 1;
    end
  end
end

