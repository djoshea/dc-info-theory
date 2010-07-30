function [out figs] = calcDynClampInfo(protocolDescriptor, dsDescriptor, varargin) 
% protocolDescriptor should be a struct containing:
%   eventTimeName: fully qualified file name of dyn clamp input times
%   name : plain text name of protocol
%   nsweeps : number of sweeps given in the event time file
%
% dsDescriptor should be a struct array with each element containing:
%   fname : fully qualified file name of the axon text file containing the traces
%   name : plain text name for reference in plots
%   color : how to color this trace in summary plots
% 
% out is a struct containing

pr = protocolDescriptor;
ds = dsDescriptor;
out = ds;

eventfname = pr.fname;
nsweeps = pr.nsweeps;

% time and rate binning for input and output rate computation
ratebins = (-12.5:25:500)*125/1000;
timebinwidth = 0.125;
ratebinsHz = ratebins / (timebinwidth);
timebins = 100:timebinwidth*1000:10100;

% center of each rate bin (make the first 0 Hz since rates can't be negative)
rb = ratebinsHz;
rb(1) = 0;
inRateBinCenters = (rb(2:end) + rb(1:end-1)) / 2;

%% Load input event times

% times0hz is 2 x nevents: first row is time in ms, second row is sweep
% number associated with that event. Add 100 ms to event times to make the timing
% line up. (see traces to verify this)
fprintf('Loading event times from %s...\n', eventfname);
times0hz = geteventtimes(eventfname, nsweeps);

shift = 0.1; % offset inputs by finite amount of time relative to output?
times0hz(1,:) = times0hz(1,:) + shift*1000;

% stims0hz and epscRates are nsweeps x length(timebins) each referring to a
% particular time bin
% stims0hz is what rate bin it gets put in
% epscRates was the actual rate in that time window
[stims0hz epscRates] = convertevents(times0hz, ratebins, timebins);

%% Find output spike times in each file

traces = cell(length(ds),1);
stims = cell(length(ds),1);
spiketimes = cell(length(ds),1);
spiketimescell = cell(length(ds),1);

for cm = 1:length(ds)
    fprintf('Processing %s:\n', ds(cm).name);
    
    if(isfield(ds(cm), 'spiketimes'))
        fprintf('\tSpike times already loaded\n');
        continue;
    end
    
    % load the CC traces from the axon text file
    [traces{cm}, ~, ~, si] = loadinfoatf(ds(cm).fname);
    out(cm).traces = traces{cm};
    
    skip = nsweeps - size(traces{cm},2); % some files don't have the first couple sweeps, so skip them
    if(skip > 0)
        warning('calcDynClampInfo:MissingTraces',...
            '\tData file %s contains only %d / %d traces', ds(cm).fname, size(traces{cm},2), nsweeps);
    end
    stims{cm} = stims0hz(skip+1:end,:);
    out(cm).stims = stims{cm};

    % detect spike times using Schmitt trigger
    fprintf('\tDetecting spike times in %d traces...\n', size(traces{cm},2));
    thresh = 0;
    [spiketimeslumped{cm}, spiketimes{cm}] = detectabfspikes(traces{cm}, si, 'spikethreshold', thresh, 'minrepol', -30); 
    out(cm).spiketimes = spiketimes{cm};
    out(cm).spiketimeslumped = spiketimeslumped{cm};
    
     % plot CC traces with spike times indicated at threshold height
%     figure(14+cm), clf, set(14+cm, 'Color', [1 1 1]);
%     plottraces(traces{cm}, si, 'events', spiketimes{cm}, 'eventheight', thresh);
%     title(sprintf('Spike Detection Current Clamp Traces: %s', ds(cm).name));
%     ylabel('Voltage (normalized)');
%     set(14+cm, 'Position', [132 127 1016 848]);
end

%% Mutual information calculations

MI = zeros(length(ds),1);
nspikes = zeros(length(ds),1);
Hresponse = zeros(length(ds),1);
Hnoise = zeros(length(ds),1);
Hstim = zeros(length(ds),1);

hfIO = figure();
set(hfIO, 'Color', [1 1 1]);
hold on
maxy = 0;

for cm = 1:length(ds)
    % compute cell output firing rate
    [outcount outrateHz]  = calcFiringRate( out(cm).spiketimeslumped, timebins );

    % compute cell IO curve: epsc rate --> firing rate
    usestims = unique(stims0hz);
    usestims = usestims(usestims > 0);
    [meanhz,stdhz] = dcIOcurve(outrateHz, out(cm).stims, timebins, usestims);
    sem = stdhz' / sqrt(size(traces{cm},2));
    out(cm).meanhz = meanhz;
    out(cm).stdhz = meanhz;
    out(cm).timebins = timebins;
    
    % plot mean IO curve with SEM
    disp('Plotting I/O Curve...');
    errorbar(inRateBinCenters, meanhz, sem, '-','Color',ds(cm).color,'LineWidth', 2);
    xlim([min(ratebinsHz) max(ratebinsHz)]);
    maxy = max(maxy, max(meanhz + sem));
    box off
    ylabel('Firing Rate (Hz)');
    xlabel('EPSC Rate (Hz)');
    title('Input/Output Transfer Functions with SEM');

    % compute MI between inrate (stims0hz) and outrate
    disp('Computing Mutual Information...');
    outcountbins = -0.5:10.5; % binning along firing rate axis (output) as spikes / timebin
    outRateBins = outcountbins / timebinwidth;
    outRateBinCenters = (outRateBins(1:end-1) + outRateBins(2:end)) / 2;
    [MI(cm), nspikes(cm), Hresponse(cm), Hnoise(cm), Hstim(cm), Pdist{cm}] = ...
        minf2(outcount, out(cm).stims, timebins, outcountbins, usestims);
    fprintf('\n\tResponse Entropy: \t%0.2f bits\n\tNoise Entropy: \t\t%.2f bits\n\tMutual Information: \t%0.2f bits\n', ...
        Hresponse(cm), Hnoise(cm), MI(cm));
    
    out(cm).nspikes = nspikes(cm);
    out(cm).MI = MI(cm);
    out(cm).Hresponse = Hresponse(cm);
    out(cm).Hstim = Hstim(cm);
    out(cm).pDist = Pdist{cm};

%     figure(34), set(34, 'Color', [1 1 1]);
%     subplot(1,length(ds), cm);
%     Pdist{cm} = Pdist{cm}(:,1:end-1)'; % throw away last catch-all column
%     [INRATE OUTRATE] = meshgrid(inRateBinCenters, outRateBinCenters);
%     h = pcolor(INRATE, OUTRATE, Pdist{cm});
%     set(h,'EdgeColor', 'none');
%     xlabel('Input EPSC Rate (Hz)');
%     ylabel('Output Firing Rate (Hz)');
%     title(sprintf('I/O Probability Distribution: %s', ds(cm).name));
%     colorbar;
end

ylim([0 maxy]);
title(['Input-Output Curves: ' pr.name]);
legend({ds.name}, 'Location', 'Best');
legendboxoff


figs.hfIO = hfIO;

%% plot dynamic clamp demo graph
% figure(54), clf, set(54, 'Color', [1 1 1]);
% im = epscs(:,1);
% vm = traces{1}(:,1);
% vtm = spiketimescell{1}{1};
% itm = times0hz(1,times0hz(2,:) == 1) / 1000;

% plottraces([im vm], si, 'events', {itm, vtm}, 'eventheight', 0);
% xlim([4 6]);
% set(gca, 'YTickLabel', {'Current Command', 'Cell Voltage'})
% ylabel('');

% for i = 1:size(epscs,2)
%     etm{i} = times0hz(1,times0hz(2,:) == i) / 1000;
% end
% 
% plottraces(epscs, si, 'events', etm, 'eventheight', 0);
% ylabel('Current Command');
% xlim([4 4.5]);


%% plot info bar graph

hfInfo = figure(); clf, set(hfInfo,'Color', [1 1 1]);
h = bar([MI Hnoise], 'stacked');
set(gca, 'XTickLabel', {ds.name});
box off
ylabel('Bits');
ylim([0 ceil(max(MI+Hnoise))]);

for i = 1:length(ds)
    h = text(i-0.2, (MI(i)) / 2, sprintf('%.2f bits', MI(i)));
    set(h, 'Color', [1 1 1], 'FontSize', 14);
    h = text(i-0.2, (2*MI(i) + Hnoise(i)) / 2, sprintf('%.2f bits', Hnoise(i)));
    set(h, 'Color', [1 1 1], 'FontSize', 14);
end

title(['Information Analysis: ' pr.name]);
legend({'Mutual Information', 'Noise Entropy'}, 'Location', 'EastOutside')
legendboxoff
set(hfInfo, 'Position', [680   451   815   463]);

figs.hfInfo = hfInfo;

