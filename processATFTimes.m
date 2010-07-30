function atfData = processATFTimes( atfs, inputProtocols, varargin )
% for each ATF file in the list (see loadATFList), find the spike times, grab the
% appropriate input protocol file, calculate input and output rates by binning in time and rate

nATF = length(atfs);

def.atfBasePath = '/Users/djoshea/Documents/Research/dLab/dlab data/';
def.nsweeps = 10;
def.thresh = -10; % spike detection (mV)
def.minrepol = -30; % (mV)
assignargs(def, varargin);

atfData = atfs;

figure(14);
set(14, 'Position', [82 -33 1229 787]);
set(14, 'Color', [1 1 1]);

for cm = 1:length(atfs)
    atf = atfs(cm);
    
    % find the right input file
    [~, ip] = find([inputProtocols.freqmod] == atf.freqMod);
    if(isempty(ip))
        error('DCINFO:atfFreqModError', 'Could not find input protocol for freqMod = %d', atf.freqMod);
    end
    
    % generate fully-qualified file name from parts
    atfData(cm).fnameshort = sprintf('%s_%04d.atf', atf.path(1:end-1), atf.filenum);
    atfname = [atfBasePath atf.path atfData(cm).fnameshort];
    atfData(cm).fname = atfname;
    atfData(cm).atfBasePath = atfBasePath;
    
    fprintf('Processing %2d / %2d: %s...\n', cm, length(atfs), atfData(cm).fnameshort);
    
    fid = fopen(atfname);
    if(fid == -1)
        error('not found!')
    end
    fclose(fid);
    
    % load the CC traces from the axon text file
    [traces, ~, ~, si] = loadinfoatf(atfname);
    
    atfData(cm).inputtimes = inputProtocols(ip).times;

    % detect spike times using Schmitt trigger
%     fprintf('\tDetecting spike times in %d traces...\n', size(traces{cm},2));
    [atfData(cm).spiketimeslumped, atfData(cm).spiketimes] = ...
        detectabfspikes(traces, si, 'spikethreshold', thresh, 'minrepol', minrepol); 
    
     % plot CC traces with spike times indicated at threshold height
    clf;
    plottraces(traces, si, 'events', atfData(cm).spiketimes, 'eventheight', thresh);
    title(sprintf('Spike Detection Current Clamp Traces: %s', atfData(cm).fnameshort), 'Interpreter', 'none');
    ylabel('Voltage (normalized)');
    
    plotfname = sprintf('%s%s%s_%04d.traces.png', ...
        atfBasePath, atf.path, atf.path(1:end-1), atf.filenum);
    print(14,'-dpng','-r300', plotfname);
    
    
    matfname = sprintf('%s%s%s_%04d.times.mat', ...
        atfBasePath, atf.path, atf.path(1:end-1), atf.filenum);
    atf = atfData(cm);
    save(matfname, 'atf');
    
end





end

