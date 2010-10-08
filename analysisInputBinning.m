%% Test timebin size

inRateBinWidths = 500 ./ [5 10 20 25 50]';

fn_matName = @(nBins) sprintf('atfFinal_inRateBinWidth%02d.mat', nBins);

tBinWidth = 0.125;

% do info analysis and save to disk
% for i = 1:length(inRateBinWidths)
%     matName = fn_matName(inRateBinWidths(i))
%     
%     atfBinned = processATFBinning(atfTimes, 'inRateBinWidth', inRateBinWidths(i), 'tBinWidth', tBinWidth, 'outRateBinWidth', floor(1/tBinWidth));
%     atfFinal = processATFInformation(atfBinned);
%     
%     save(matName, 'atfFinal');
% end

% setup comparison
t = struct();
t.include = 1;
t.celltype = 'Pyramidal';
t.opsinState = 0;
t.gAMPA = 3;
t.freqMod = 0;
t.currentInjType = 'Normal';
templates = t;
templateNames = {'Baseline'};
    
t.opsinState = 1;
templates(end+1) = t;
templateNames{end+1} = 'sSFO';

mouseTypes = {'CaMKII-SSFO', 'DIO-SSFO'};

meanMIbase = zeros(length(inRateBinWidths), length(mouseTypes));
semMIbase = zeros(length(inRateBinWidths), length(mouseTypes));
meanMIssfo = zeros(length(inRateBinWidths), length(mouseTypes));
semMIssfo = zeros(length(inRateBinWidths), length(mouseTypes));
pvalues    = zeros(length(inRateBinWidths), length(mouseTypes)); % for baseline vs. ssfo comparison

meanMIdelta    = zeros(length(inRateBinWidths), length(mouseTypes));
semMIdelta   = zeros(length(inRateBinWidths), length(mouseTypes));

deltaMIByMouse = cell(length(mouseTypes), 1);
pByMouse = zeros(length(inRateBinWidths), 1); % for CK vs. DIO comparison

for iBin = 1:length(inRateBinWidths)
    matName = fn_matName(inRateBinWidths(iBin));
    d = load(matName, 'atfFinal');
    atfFinal = d.atfFinal;
    
    % Baseline vs sSSFO comparison
    for type = 1:2
        [templates.mousetype] = deal(mouseTypes{type});
        compare = gatherComparison(atfFinal, templates);
        
        mi = reshape([compare.data.miCorrected], size(compare.data));
        MIbase = mi(:,1);
        MIssfo = mi(:,2);
        deltaMI = MIssfo - MIbase;
        deltaMIByMouse{type} = deltaMI;
        meanMIbase(iBin, type) = mean(MIbase);
        semMIbase(iBin, type) = std(MIbase) / sqrt(size(MIbase,1));
        meanMIssfo(iBin, type) = mean(MIssfo);
        semMIssfo(iBin, type) = std(MIssfo) / sqrt(size(MIssfo,1));
        meanMIdelta(iBin, type) = mean(deltaMI);
        semMIdelta(iBin, type) = std(deltaMI) / sqrt(size(deltaMI,1));
        
        [hpaired, pvalues(iBin,type)] = ttest(MIbase, MIssfo);
    end
    
    [htwosample pByMouse(iBin)] = ttest2(deltaMIByMouse{1}, deltaMIByMouse{2}, 0.95, 'both', 'unequal');
end

%% plot MI means vs. time bin for both conditions and indicate p values above

for type = 1:2
    figure(22+type), clf
    h(1) = errorbar(inRateBinWidths, meanMIbase(:, type), semMIbase(:, type), 'ks-', 'MarkerFaceColor', 'k');
    hold on
    h(2) = errorbar(inRateBinWidths, meanMIssfo(:, type), semMIssfo(:, type), 'bs-', 'MarkerFaceColor', 'b');
    
    set(h(1), 'LineWidth', 2);
    set(h(2), 'LineWidth', 2);
    
    for iBin = 1:length(inRateBinWidths)
        if(pvalues(iBin,type) < 0.01)
            text(inRateBinWidths(iBin)-1, 0.08+meanMIbase(iBin, type)+semMIbase(iBin, type), 'p < 0.01');
        elseif(pvalues(iBin,type) < 0.05)
            text(inRateBinWidths(iBin)-1, 0.08+meanMIbase(iBin, type)+semMIbase(iBin, type), 'p < 0.05');
        end
    end
    box off
    xlim([0 110]);
    ylim([0 1.4]);
    xlabel('Input Rate Bin Width (Hz)');
    ylabel('Mean Mutual Information (bits)');
    legend({'Baseline', '10s 470 nm'}, 'Location', 'Best');
    legendboxoff
    title(mouseTypes{type});
    set(gcf,'Position',[ 184   280   713   349]);
    movegui(gcf,'center')
end

%% plot mean drop in MI to show CK >> DIO
mouseCmap = [0.4 1 0.4; 0.6 0.47 1];

figure(33), clf
for type = [2 1]
    h = errorbar(inRateBinWidths, meanMIdelta(:, type), semMIdelta(:, type), 's-', 'Color', mouseCmap(type,:),'MarkerFaceColor', mouseCmap(type,:));
    set(h, 'LineWidth', 2);
    hold on
end

for iTBin = 1:length(inRateBinWidths)
    if(pByMouse(iTBin) < 0.005)
        text(inRateBinWidths(iTBin)-1, -0.04+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.005');
    elseif(pByMouse(iTBin) < 0.01)
        text(inRateBinWidths(iTBin)-1, -0.04+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.01');
    elseif(pByMouse(iTBin) < 0.05)
        text(inRateBinWidths(iTBin)-1, -0.04+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.05');
    end
end

box off
xlim([0 110]);
ylim([-1 0]);
xlabel('Input Rate Bin Width (Hz)');
ylabel('Mean Change in Mutual Information (bits)');
legend(fliplr(mouseTypes), 'Location', 'Best');
legendboxoff
title(mouseTypes{type});
set(gcf,'Position', [ 184   280   713   349]);
movegui(gcf,'center')


