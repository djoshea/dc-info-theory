function atfData = processATFTimes( atfs, inputProtocols, varargin )
% for each ATF file in the list (see loadATFList), find the spike times, grab the
% appropriate input protocol file, calculate input and output rates by binning in time and rate

nATF = length(atfs);

def.atfBasePath = '/Users/djoshea/Documents/Research/dLab/dlab data/';
def.nsweeps = 10;
def.thresh = 0; % spike detection (mV)
def.minrepol = -30; % (mV)
def.maxspikewidth = 6; % ms
def.refractory = 2; % ms
def.match = [];
def.ignoreSavedTraces = 0;
def.plotTraces = 0;
def.overwriteSavedTimes = 1; % override existing .times.mat? file
def.saveTimesFile = 0;
assignargs(def, varargin);

spikedetect.spikethreshold = thresh;
spikedetect.minrepol = minrepol;
spikedetect.maxspikewidth = maxspikewidth;
spikedetect.refractory = refractory;

% atfData = atfs;

if(plotTraces)
    figure(14);
    set(14, 'Position', [82 -33 1229 787]);
    set(14, 'Color', [1 1 1]);
end

for cm = 1:length(atfs)
    atf = orderfields(atfs(cm));
    
%     if(~isfield(atf, 'mousetype')) % some older files don't have this
%         atf.mousetype = 'CaMKII-SSFO';
%         atf = orderfields(atf);
%     end
    
    % check for and use an existing mat file to load the times in?
    matfnamePart = sprintf('%s_%04d.times.mat', atf.path(1:end-1), atf.filenum);
    matfname = [atfBasePath atf.path matfnamePart];
    if(~overwriteSavedTimes && exist(matfname, 'file'))
        % use the existing file and then we're done
        fprintf('Loading existing %s file...\n', matfnamePart);
        loaded = load(matfname, 'atf');
        atf = loaded.atf;
        
%         if(~isfield(atf, 'mousetype')) % some older files don't have this
%             atf.mousetype = 'CaMKII-SSFO';
%             atf = orderfields(atf);
%             save(matfname, 'atf');
%         end
        
        atfData(cm) = orderfields(atf); % in case things have changed order since saving
        continue;
    end
    
    % find the right input file
    [~, ip] = find([inputProtocols.freqmod] == atf.freqMod);
    if(isempty(ip))
        error('DCINFO:atfFreqModError', 'Could not find input protocol for freqMod = %d', atf.freqMod);
    end
    
    % first try to find .traces.mat file and load that since it's faster than reloading the atf
    atf.fnameTraces = sprintf('%s_%04d.traces.mat', atf.path(1:end-1), atf.filenum);
    atfTracesName = [atfBasePath atf.path, atf.fnameTraces];
    
    % generate fully-qualified file name from parts
    atf.fnameshort = sprintf('%s_%04d.atf', atf.path(1:end-1), atf.filenum);
    atfname = [atfBasePath atf.path atf.fnameshort];
    atf.fname = atfname;
    atf.atfBasePath = atfBasePath;
    
    % matches input search term? this is for processing specific rows from the full atf table...
    if(isempty(match))
        isMatch = 1;
    else
        isMatch = strncmp(atf.fnameshort, match, length(match));
    end
    if(~isMatch)
        % this row isn't a match, just ignore it
        continue;
    end
    
    % check for existing .traces.mat file (faster than reloading the raw ATF file)
    if(~ignoreSavedTraces && exist(atfTracesName, 'file'))
        % .traces.mat file exists, load it
        loaded = load(atfTracesName, 'traces', 'si');
        traces = loaded.traces;
        si = loaded.si;
        
        fprintf('Loading %2d / %2d: %s...\n', cm, length(atfs), atf.fnameTraces);  
    else
        % .traces.mat doesn't exist, load the raw atf file
        fprintf('Loading %2d / %2d: %s...\n', cm, length(atfs), atf.fnameshort);

        fid = fopen(atfname);
        if(fid == -1)
            error('ATF File missing: %s', atfname)
        end
        fclose(fid);

        % load the CC traces from the axon text file
        [traces, ~, ~, si] = loadinfoatf(atfname);
        
        % now save to a .traces.mat file
        save(atfTracesName, 'traces', 'si');
    end
    
    % save input times with protocol
    atf.inputTimesBySweep = inputProtocols(ip).timesBySweep;
    
    % detect spike times using Schmitt trigger
    %     fprintf('\tDetecting spike times in %d traces...\n', size(traces{cm},2));
    [spiketimeslumped atf.spikeTimesBySweep] = detectabfspikes(traces, si, spikedetect);
    if(isempty(spiketimeslumped))
        warning('No spikes detected in %s!', atfname);
    end
    
     % plot CC traces with spike times indicated at threshold height
    if(plotTraces)
        clf;
        plottraces(traces, si, 'events', atf.spikeTimesBySweep, 'eventheight', thresh);
        title(sprintf('Spike Detection Current Clamp Traces: %s', atf.fnameshort), 'Interpreter', 'none');
        ylabel('Voltage (normalized)');
        
        plotfname = sprintf('%s%s%s_%04d.traces.', ...
            atfBasePath, atf.path, atf.path(1:end-1), atf.filenum);
        print(14,'-dpng','-r300', [plotfname 'png']);
        
        saveas(14, [plotfname 'fig'], 'fig');
    end
    
    atfData(cm) = orderfields(atf);
    
    % save the data to a .times struct to .times.mat file for quick reprocessing
    if(saveTimesFile)
        save(matfname, 'atf');
    end
end





end

