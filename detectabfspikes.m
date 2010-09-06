function [spiketimes spiketimescell] = detectabfspikes(traces, si, varargin)
% filename = ABF file to open
% scalefactor converts to mV
% spikethreshold is the threshold for detecting a spike (in mV)
% refractory is the minimum refractory period between spikes (in
% timesteps)
% minrepol is the lower threshold for ending a spike that must be reached
% between spikes

par.spikethreshold = 0;
par.refractory = 2; % ms
par.minrepol = -30;
par.maxspikewidth = 5; % ms
assignargs(par, varargin);

nspikes = 0;
nsweeps = size(traces,2);
spiketimes = [];
spiketimescell = {};

% minrepol = minrepol;
% spikethreshold = spikethreshold;

for sweepno = 1:nsweeps
  %   [data,si] = abfload(filename, 'sweeps', sweepno);
  
  % assume data(:,1) = timepoints, data(:,2) = voltage trace  
  data = traces(:,sweepno);
  
  lastspiketime = -1000;
  reset = 0; % indicates whether the membrane potential has dipped
             % below minrepol
  
  spiketimescell{sweepno} = [];
  
  % times when trace crosses the depol or repol thresholds in the correct direction
  threshUpCross = [0; diff(data >= spikethreshold)] == 1;
  threshDownCross = [0; diff(data > minrepol)] == -1;
  
  % find times of upward threshold crossings separated by at least a refractory period
  upTimes = find(threshUpCross) * si * 1e-6;
  if(~isempty(upTimes))
      upTimes = upTimes([true; diff(upTimes) > refractory/1000]);
      
      % reject spikes that don't cross repolarization threshold within maxspikewidth
      downTimes = find(threshDownCross) * si * 1e-6;
      nextDownTime = @(ut) min(downTimes(downTimes > ut) - ut) + ut;
      nextDownTimes = arrayfun(nextDownTime, upTimes);
      nextUpTimes = [upTimes(2:end); Inf];
      
      upTimesFiltered = upTimes(nextDownTimes < upTimes + maxspikewidth/1000 & ...
          nextDownTimes < nextUpTimes);
  else
      upTimesFiltered = [];
  end

  nspikesSweep = length(upTimesFiltered);
  if(~isempty(upTimesFiltered))
      spiketimes = cat(2, spiketimes, [sweepno*ones(1,nspikesSweep); upTimesFiltered']);
  end
  spiketimescell{sweepno} = upTimesFiltered;
  
%   for n=2:length(data),
%       % has the trace just crossed the upward threshold?
%       if data(n) >= spikethreshold && data(n-1) < spikethreshold
%           % has enough time elapsed since the last spike was detected?
%           if n*si*0.001 > lastspiketime + refractory
%               lastThreshCrossing = n*0.001*si;
%               
%               % have we dipped below the repolarization threshold yet?
%               if reset
%                   % found a spike
%                   nspikes = nspikes+1;
%                   lastspiketime = n*0.001*si;
%                   spiketimes(1, nspikes) = sweepno;
%                   spiketimes(2, nspikes) = lastspiketime / 1000;
%           
%           spiketimescell{sweepno}(end+1) = lastspiketime / 1000;
%         end
%       end
%     elseif ~reset && data(n) <= minrepol,
%       reset = 1;
%     end
%   end
end

