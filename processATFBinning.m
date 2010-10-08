function atfData = processATFBinning( atfData, varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

def.atfBasePath = '/Users/djoshea/Documents/Research/dLab/dlab data/';
def.tBinOffset = 0.1; % sec, no inputs during the first 100 ms post trigger
def.tBinMax = 10.1;
def.tBinWidth = 0.125;
def.inRateBinMin = -1e-5; % Hz, input rate (offset to include 0)
def.inRateBinMax = 500;
def.inRateBinWidth = 500/10;
def.outRateBinMin = -1e-5; % Hz, output rate
% minimum "meaningful" bin width, given time bin width, i.e. one spike separates each bin from its neighbors
def.outRateBinWidth = floor(1/def.tBinWidth); 
def.outRateBinMax = 85;

def.plotIODist = 0;
assignargs(def,varargin);

% time and rate bin parameters for input and output rate computation
timebins = tBinOffset:tBinWidth:tBinMax;          % sec
timebinsMS = timebins * 1000;

% bounds of the input and output bins
inRateBinBoundsHz = inRateBinMin:inRateBinWidth:inRateBinMax;
inRateBinBoundsPerTimeBin = inRateBinBoundsHz * tBinWidth;

outRateBinBoundsHz = outRateBinMin:outRateBinWidth:outRateBinMax;
outRateBinBoundsPerTimeBin = outRateBinBoundsHz * tBinWidth;

% center of each rate bin (make the first 0 Hz since rates can't be negative)
rb = inRateBinBoundsHz;
% rb(1) = 0;
inRateBinCenters = (rb(2:end) + rb(1:end-1)) / 2;

orb = outRateBinBoundsHz;
% orb(1) = 0;
outRateBinCenters = (orb(1:end-1) + orb(2:end)) / 2;

% list of bin ids used (probably not necessary, easy to reconstruct)
inRateBinsList = 1:length(inRateBinCenters);
outRateBinsList = 1:length(outRateBinCenters);

if(plotIODist)
    pdistfig = 34;
    figure(pdistfig); clf; set(pdistfig, 'Color', [1 1 1]);
end

for cm = 1:length(atfData)
    atf = atfData(cm);
    
%     fprintf('Processing %02d / %d: %s\n', cm, length(atfData), atf.fnameshort);
    
    atfData(cm).inRateBinCenters = inRateBinCenters;
    atfData(cm).outRateBinCenters = outRateBinCenters;
    
%     for i = 1:length(atf.spiketimes)
%         atf.inputTimesBySweep{i} = atf.inputtimes(1,atf.inputtimes(2,:) == i) / 1000;
%         atf.spikeTimesBySweep{i} = atf.spiketimes{i}';
%     end
%     atfData(cm).inputTimesBySweep = atf.inputTimesBySweep;
%     atfData(cm).spikeTimesBySweep = atf.spikeTimesBySweep;
        
    % bin input rates in time and rate
    [inRateBin inRateHz] = convertevents(atf.inputTimesBySweep, inRateBinBoundsPerTimeBin, timebins);
    totalSweeps = size(inRateBin,1);
    
    % bin output rates in time and rate
%     [outCount outRateHz]  = calcFiringRate( atf.spiketimeslumped, timebinsMS );
    [outRateBin outRateHz] = convertevents(atf.spikeTimesBySweep, outRateBinBoundsPerTimeBin, timebins);
    actualSweeps = size(outRateBin,1);
    
    if(actualSweeps < totalSweeps)
        if(atfData(cm).include)
            fprintf('Warning: File %s contains only %d / %d traces but is marked for inclusion\n',...
                atf.fnameshort, actualSweeps, totalSweeps);
        end
        useSweeps = totalSweeps-actualSweeps+1:totalSweeps;
        inRateBin = inRateBin(useSweeps,:);
        inRateHz = inRateHz(useSweeps,:);
%         atfData(cm).include = 0;
    end
    
    atfData(cm).timebins = timebins;
    atfData(cm).inRateBin = inRateBin;
    atfData(cm).inRateHz = inRateHz;
    atfData(cm).outRateBin = outRateBin;
    atfData(cm).outRateHz = outRateHz;
    
    % include bin bounds for reference
    atfData(cm).inRateBinsList = inRateBinsList;
    atfData(cm).outRateBinsList = outRateBinsList;
    atfData(cm).inRateBinBoundsHz = inRateBinBoundsHz;
    atfData(cm).inRateBinBoundsPerTimeBin = inRateBinBoundsPerTimeBin;
    atfData(cm).outRateBinBoundsHz = outRateBinBoundsHz;
    atfData(cm).outRateBinBoundsPerTimeBin = outRateBinBoundsPerTimeBin;
    
    ioDist = zeros(length(inRateBinCenters), length(outRateBinCenters));
    for inBin = 1:length(inRateBinCenters)
        for outBin = 1:length(outRateBinCenters)
            ioDist(inBin, outBin) = nnz(inRateBin == inBin & outRateBin == outBin);
        end
    end     
    atfData(cm).ioDist = ioDist;
    
    % compute cell IO curve: epsc rate --> firing rate
    [meanhz, stdhz, semhz] = dcIOcurve(outRateHz, inRateBin, inRateBinsList);
    atfData(cm).meanhz = meanhz;
    atfData(cm).stdhz = stdhz;
    atfData(cm).semhz = semhz;

%     % compute MI between inrate and outrate
%     [MI, nspikes, Hresponse, Hnoise, Hstim, ioDist] = ...
%         minf2(outcount, stims, timebinsMS, outrateBinsPerTimeBin, usestims);
% %     fprintf('\tResponse Entropy: \t%0.2f bits\n\tNoise Entropy: \t\t%.2f bits\n\tMutual Information: \t%0.2f bits\n', ...
% %         Hresponse, Hnoise, MI);
%     
%     atfData(cm).nspikes = nspikes;
%     atfData(cm).MI = MI;
%     atfData(cm).Hresponse = Hresponse;
%     atfData(cm).Hstim = Hstim;
%     atfData(cm).ioDist = ioDist;

    if(plotIODist)
        clf;
        [INRATE OUTRATE] = meshgrid(inRateBinCenters, outRateBinCenters);
        h = pcolor(INRATE, OUTRATE, ioDist');
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


end

