function atfData = processATFBinning( atfData, varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

def.atfBasePath = '/Users/djoshea/Documents/Research/dLab/dlab data/';
def.tBinOffset = 0.1; % sec, no inputs during the first 100 ms post trigger
def.tBinMax = 10.1;
def.tBinWidth = 0.125;
def.rateBinMin = -12.5; % Hz, input rate
def.rateBinMax = 500;
def.rateBinWidth = 25;
def.outrateBinMin = -4; % Hz, output rate
def.outrateBinWidth = 8;
def.outrateBinMax = 84; 
assignargs(def,varargin);

% time and rate bin parameters for input and output rate computation
timebins = tBinOffset:tBinWidth:tBinMax;          % sec
timebinsMS = timebins * 1000;

ratebinsHz = rateBinMin:rateBinWidth:rateBinMax;
ratebinsPerTimeBin = ratebinsHz * tBinWidth;

outrateBins = outrateBinMin:outrateBinWidth:outrateBinMax;
outrateBinsPerTimeBin = outrateBins * tBinWidth;

% center of each rate bin (make the first 0 Hz since rates can't be negative)
rb = ratebinsHz;
rb(1) = 0;
inRateBinCenters = (rb(2:end) + rb(1:end-1)) / 2;

orb = outrateBins;
orb(1) = 0;
outRateBinCenters = (orb(1:end-1) + orb(2:end)) / 2;

pdistfig = 34;
figure(pdistfig); clf; set(pdistfig, 'Color', [1 1 1]);


for cm = 1:length(atfData)
    atf = atfData(cm);
    
    fprintf('Processing %02d / %d: %s\n', cm, length(atfData), atf.fnameshort);
    
    atfData(cm).inRateBinCenters = inRateBinCenters;
    atfData(cm).outRateBinCenters = outRateBinCenters;
    
    % bin input rates in time and rate
    [stims epscRates] = convertevents(atf.inputtimes, ratebinsPerTimeBin, timebinsMS);
    totalSweeps = size(stims,1);
    
    % bin output rates in time and rate
    [outcount outrateHz]  = calcFiringRate( atf.spiketimeslumped, timebinsMS );
    actualSweeps = size(outcount,1);
    
    if(actualSweeps < totalSweeps)
        warning('calcDynClampInfo:MissingTraces',...
            '\tData file %s contains only %d / %d traces', atf.fnameshort, actualSweeps, totalSweeps);
        stims = stims(totalSweeps-actualSweeps+1:end,:);
        epscRates = epscRates(totalSweeps-actualSweeps+1:end,:);
    end
    
    atfData(cm).stims = stims;
    atfData(cm).epscRates = epscRates;
    atfData(cm).outcount = outcount;
    atfData(cm).outrateHz = outrateHz;
    
    % compute cell IO curve: epsc rate --> firing rate
    usestims = unique(stims);
    usestims = usestims(usestims > 0);
    [meanhz,stdhz] = dcIOcurve(outrateHz, stims, timebinsMS, usestims);
    sem = stdhz' / sqrt(length(atfData(cm).spiketimes));
    atfData(cm).meanhz = meanhz;
    atfData(cm).stdhz = meanhz;
    atfData(cm).semhz = sem;

    % compute MI between inrate and outrate
    [MI, nspikes, Hresponse, Hnoise, Hstim, ioDist] = ...
        minf2(outcount, stims, timebinsMS, outrateBinsPerTimeBin, usestims);
%     fprintf('\tResponse Entropy: \t%0.2f bits\n\tNoise Entropy: \t\t%.2f bits\n\tMutual Information: \t%0.2f bits\n', ...
%         Hresponse, Hnoise, MI);
    
    atfData(cm).nspikes = nspikes;
    atfData(cm).MI = MI;
    atfData(cm).Hresponse = Hresponse;
    atfData(cm).Hstim = Hstim;
    atfData(cm).ioDist = ioDist;

    clf;
    ioDist = ioDist(:,1:end-1)'; % throw away last catch-all column
    [INRATE OUTRATE] = meshgrid(inRateBinCenters, outRateBinCenters);
    h = pcolor(INRATE, OUTRATE, ioDist);
    set(h,'EdgeColor', 'none');
    xlabel('Input EPSC Rate (Hz)');
    ylabel('Output Firing Rate (Hz)');
    title(sprintf('I/O Probability Distribution: %s', atf.fnameshort), 'Interpreter', 'none');
    colorbar;
    
    plotfname = sprintf('%s%s%s_%04d.ioDist.png', ...
        atfBasePath, atf.path, atf.path(1:end-1), atf.filenum);
    print(pdistfig,'-dpng','-r300', plotfname);
    
end


end

