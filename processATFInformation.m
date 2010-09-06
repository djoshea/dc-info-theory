function atfData = processATFInformation( atfBinned, varargin )

fprintf('Computing MI for %d files...\n', length(atfBinned));
def.extrapolateMI = 1; % extrapolate out to the limit of infinite samples
def.invDataFractions = (1:5)';
def.nResample = 10;
def.showPlot = 1;
assignargs(def, varargin);

dataFractions = 1./invDataFractions;

atfData = atfBinned;

for cm = 1:length(atfBinned)
    atf = atfBinned(cm);
    cm
    % outcount is ntraces x ntimebins: the number of output spikes
    inRateBin = atf.inRateBin(:);
    outRateBin = atf.outRateBin(:);
    inRateBinsList = atf.inRateBinsList;
    outRateBinsList = atf.outRateBinsList;
    % compute MI between inrate and outrate
    
    [mi hResponse hNoise ioDist] = computeMI(inRateBin, outRateBin, inRateBinsList, outRateBinsList);
    
    atfData(cm).mi = mi;
    atfData(cm).hResponse = hResponse;
    atfData(cm).hNoise = hNoise;
    atfData(cm).ioDist = ioDist;
    
    if(extrapolateMI)
        miPartial = zeros(length(dataFractions), nResample);
        hResponsePartial = zeros(length(dataFractions), nResample);
        hNoisePartial = zeros(length(dataFractions), nResample);
        
        for iFraction = 1:length(dataFractions)
            % compute Mi with this fraction of the data
            for iSample = 1:nResample
                % reestimate at each fraction nResample times and average
                useTimeBins = rand(size(inRateBin)) <= dataFractions(iFraction);
                inRateBinPartial = inRateBin(useTimeBins);
                outRateBinPartial = outRateBin(useTimeBins);
                [miPartial(iFraction, iSample) hResponsePartial(iFraction, iSample) hNoisePartial(iFraction, iSample)] = ...
                    computeMI(inRateBinPartial, outRateBinPartial, inRateBinsList, outRateBinsList);
            end
        end
        
        miPartial = mean(miPartial, 2);
        hResponsePartial = mean(hResponsePartial, 2);
        hNoisePartial = mean(hNoisePartial, 2);
        
        atfData(cm).miPartial = miPartial;
        atfData(cm).hResponsePartial = hResponsePartial;
        atfData(cm).hNoisePartial = hNoisePartial;
        
        quadraticFitMI = polyfit(invDataFractions, miPartial,2);
        atfData(cm).miCorrected = polyval(quadraticFitMI, 0);
        atfData(cm).miCorrectionFactor = (mi - atfData(cm).miCorrected) / mi;
        
        quadraticFitHResponse = polyfit(invDataFractions, hResponsePartial,2);
        atfData(cm).hResponseCorrected = polyval(quadraticFitHResponse, 0);
        
        quadraticFitHNoise = polyfit(invDataFractions, hNoisePartial,2);
        atfData(cm).hNoiseCorrected = polyval(quadraticFitHNoise, 0);
        
        if(showPlot)
            figure(44), clf;
            plot(invDataFractions, miPartial, 'ks', 'MarkerFaceColor', 'k');
            hold on
            plot(invDataFractions, hResponsePartial, 'rs', 'MarkerFaceColor', 'r');
            plot(invDataFractions, hNoisePartial, 'bs', 'MarkerFaceColor', 'b');
            
            xvals = linspace(0, max(invDataFractions)+2, 100);
            plot(xvals, polyval(quadraticFitMI, xvals), '-', 'Color', [0.4 0.4 0.4]);
            plot(xvals, polyval(quadraticFitHResponse, xvals), '-', 'Color', [0.4 0.4 0.4]);
            plot(xvals, polyval(quadraticFitHNoise, xvals), '-', 'Color', [0.4 0.4 0.4]);
            
            
            xlim([-0.1 max(invDataFractions)+0.1]);
            xlabel('Inverse Data Fraction');
            ylabel('MI (bits)');
            title('MI Extrapolation');
            box off
        end
    end
        
        %     fprintf('\tResponse Entropy: \t%0.2f bits\n\tNoise Entropy: \t\t%.2f bits\n\tMutual Information: \t%0.2f bits\n', ...
%         Hresponse, Hnoise, MI);
    


end

