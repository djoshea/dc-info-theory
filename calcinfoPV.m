eventfname = 'exc0hzscript2';
nsweeps = 10;
ratebins = (-12.5:25:500)*125/1000;

timebinwidth = 0.125;
ratebinsHz = ratebins / (timebinwidth);
timebins = 100:timebinwidth*1000:10100;

% center of each rate bin (make the first 0 Hz since rates can't be negative)
rb = ratebinsHz;
rb(1) = 0;
inRateBinCenters = (rb(2:end) + rb(1:end-1)) / 2;

shift = 0.1;

fprintf('Loading event times from %s...\n', eventfname);
times0hz = geteventtimes(eventfname, nsweeps);
times0hz(1,:) = times0hz(1,:) + shift*1000;

% nsweeps x length(timebins): indicates which ratebin 
[stims0hz epscRates] = convertevents(times0hz, ratebins, timebins);

compare = [];
compare(1).fnum = '15';
compare(1).name = 'Pre';
compare(1).color = [0 0 0];

compare(2).fnum = '16';
compare(2).name = 'SFO';
compare(2).color = [0  0  0.99];

traces = {};
for cm = 1:length(compare)
    fprintf('Probe %s:\n', compare(cm).name);
    
    % load the CC traces
    fname = sprintf('/Users/djoshea/Documents/Research/dLab/dlab data/ofer pv ssfo/098130%s.abf', compare(cm).fnum);
    [d si h] = abfload(fname);
    
    traces{cm} = squeeze(d(:,1,:));
    
%     skip = nsweeps - size(traces{cm},2); % some files don't have the first couple sweeps!
    stims{cm} = stims0hz;

    % detect spike times using Schmitt trigger
    fprintf('Detecting spike times in %d traces...\n', size(traces{cm},2));
    thresh = -10;
    [spiketimes{cm} spiketimescell{cm}] = detectabfspikes(traces{cm}, si, 'spikethreshold', thresh, 'minrepol', -30); 

     % plot CC traces with spike times indicated at threshold height
    figure(14+cm), clf, set(14+cm, 'Color', [1 1 1]);
    plottraces(traces{cm}, si, 'events', spiketimescell{cm}, 'eventheight', thresh);
    title(sprintf('Spike Detection Current Clamp Traces: %s', compare(cm).name));
    ylabel('Voltage (normalized)');
    set(14+cm, 'Position', [132         127        1016         848]);
end

%%
for cm = 1:length(compare)
    % compute cell output firing rate
    [outcount outrateHz]  = calcFiringRate( spiketimes{cm}, timebins );

    % compute cell epsc rate --> firing rate IO curve
    usestims = unique(stims0hz);
    usestims = usestims(usestims > 0);
    [meanhz,stdhz] = dcIOcurve(outrateHz, stims{cm}, timebins, usestims);
    sem = stdhz' / sqrt(size(traces{cm},2));

    % plot mean IO curve with SEM
    disp('Plotting I/O Curve...');
    figure(24);
    if(cm == 1)
        clf(24);
        hold on
    end
    set(24, 'Color', [1 1 1]);
    errorbar(inRateBinCenters, meanhz, sem, '-','Color',compare(cm).color,'LineWidth', 2);
    xlim([min(ratebinsHz) max(ratebinsHz)]);
    ylim([0 max(meanhz + sem)]);
    box off
    ylabel('Firing Rate (Hz)');
    xlabel('EPSC Rate (Hz)');
    title('Input/Output Transfer Functions with SEM');

    % compute MI between inrate (stims0hz) and outrate
    disp('Computing Mutual Information...');
    outcountbins = -0.5:25.5; % binning along firing rate axis (output) as spikes / timebin
    outRateBins = outcountbins / timebinwidth;
    outRateBinCenters = (outRateBins(1:end-1) + outRateBins(2:end)) / 2;
    [MI(cm), nspikes(cm), Hresponse(cm), Hnoise(cm), Hstim(cm), Pdist{cm}] = ...
        minf2(outcount, stims{cm}, timebins, outcountbins, usestims);
    fprintf('\nResponse Entropy: \t%0.2f bits\nNoise Entropy: \t\t%.2f bits\nMutual Information: \t%0.2f bits\n', ...
        Hresponse(cm), Hnoise(cm), MI(cm));

    figure(34+cm), set(34+cm, 'Color', [1 1 1]);
    Pdist{cm} = Pdist{cm}(:,1:end-1)'; % throw away last catch-all column
    [INRATE OUTRATE] = meshgrid(inRateBinCenters, outRateBinCenters);
    h = pcolor(INRATE, OUTRATE, Pdist{cm});
    set(h,'EdgeColor', 'none');
    xlabel('Input EPSC Rate (Hz)');
    ylabel('Output Firing Rate (Hz)');
    title(sprintf('I/O Probability Distribution: %s', compare(cm).name));
    colorbar;
end

figure(24)
legend({compare.name}, 'Location', 'NorthWest');
legendboxoff

%% plot dynamic clamp demo graph
figure(54), clf, set(54, 'Color', [1 1 1]);
% im = epscs(:,1);
% vm = traces{1}(:,1);
% vtm = spiketimescell{1}{1};
% itm = times0hz(1,times0hz(2,:) == 1) / 1000;

% plottraces([im vm], si, 'events', {itm, vtm}, 'eventheight', 0);
% xlim([4 6]);
% set(gca, 'YTickLabel', {'Current Command', 'Cell Voltage'})
% ylabel('');

for i = 1:size(epscs,2)
    etm{i} = times0hz(1,times0hz(2,:) == i) / 1000;
end

plottraces(epscs, si, 'events', etm, 'eventheight', 0);
ylabel('Current Command');
xlim([4 4.5]);


%% plot info bar graph

figure(44), clf, set(44,'Color', [1 1 1]);
h = bar([Hnoise' MI'], 'stacked');
set(gca, 'XTickLabel', {compare.name});
box off
ylabel('Bits');
ylim([0 5]);

for i = 1:length(compare)
    h = text(i-0.2, (2*Hnoise(i) + MI(i)) / 2, sprintf('%.2f bits', MI(i)));
    set(h, 'Color', [1 1 1], 'FontSize', 14);
    h = text(i-0.2, Hnoise(i) / 2, sprintf('%.2f bits', Hnoise(i)));
    set(h, 'Color', [1 1 1], 'FontSize', 14);
end

legend({'Noise Entropy', 'Mutual Information'}, 'Location', 'NorthOutside')
legendboxoff



