function list = loadInputTimes(varargin)
% list = loadInputTimes(...)
% processes a set of dynamic clamp input time scripts, bins in time and puts this in a usable format
% defaults, overridden through input args
% returns times in seconds

def.freqmod = [0, 8, 40];
def.fnames = {'exc0hzscript2', 'exc8hzscript2', 'exc40hzscript2'};
def.nsweeps = 10;
def.shift = 0.1; % seconds, offset between dc timing and abf file timing (determined from traces)
assignargs(def,varargin);

nfiles = length(freqmod);
list = struct();

for j = 1:nfiles
    % times is 2 x nevents: first row is time in ms, second row is corresponding sweep num
    % number associated with that event. Add 100 ms to event times to make the timing
    % line up. (see traces to verify this)
    fprintf('Loading event times from %s...\n', fnames{j});
    times = geteventtimes(fnames{j}, nsweeps);
    
    shift = 0.1; % offset inputs by finite amount of time relative to output?
    times(1,:) = times(1,:)/1000 + shift; % must convert to seconds and apply shift
   
    % convert to by sweep representation
    timesBySweep = cell(nsweeps,1);
    for iSweep = 1:nsweeps
        timesBySweep{iSweep} = times(1, times(2,:) == iSweep);
    end
    
    list(j).fname = fnames{j};
    list(j).timesBySweep = timesBySweep;
    list(j).freqmod = freqmod(j);
end


