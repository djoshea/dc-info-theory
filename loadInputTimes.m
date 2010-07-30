function list = loadInputTimes(varargin)
% list = loadInputTimes(...)
% processes a set of dynamic clamp input time scripts, bins in time and puts this in a usable format
% defaults, overridden through input args

def.freqmod = [0, 8, 40];
def.fnames = {'exc0hzscript2', 'exc8hzscript2', 'exc40hzscript2'};
def.nsweeps = 10;
def.shift = 0.1; % seconds, offset between dc timing and abf file timing (determined from traces)
assignargs(def,varargin);

nfiles = length(freqmod);
list = struct();

for j = 1:nfiles
    % times0hz is 2 x nevents: first row is time in ms, second row is sweep
    % number associated with that event. Add 100 ms to event times to make the timing
    % line up. (see traces to verify this)
    fprintf('Loading event times from %s...\n', fnames{j});
    times = geteventtimes(fnames{j}, nsweeps);
    
    shift = 0.1; % offset inputs by finite amount of time relative to output?
    times(1,:) = times(1,:) + shift*1000;
   
    list(j).fname = fnames{j};
    list(j).times = times;
    list(j).freqmod = freqmod(j);
end


