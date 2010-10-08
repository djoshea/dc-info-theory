%% Test timebin size

tBinWidth = [0.025 0.05 0.075 0.1 0.125 0.5/3 0.25 0.5];

fn_matName = @(width) sprintf('atfFinal_binWidth%dms_MinSpikeBin.mat', round(width*1000));

% do info analysis and save to disk
% for i = 1:length(tBinWidth)
%     matName = fn_matName(tBinWidth(i));
%     
%     atfBinned = processATFBinning(atfTimes, 'tBinWidth', tBinWidth(i), 'outRateBinWidth', floor(1/tBinWidth(i)));
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

meanMIbase = zeros(length(tBinWidth), length(mouseTypes));
semMIbase = zeros(length(tBinWidth), length(mouseTypes));
meanMIssfo = zeros(length(tBinWidth), length(mouseTypes));
semMIssfo = zeros(length(tBinWidth), length(mouseTypes));
pvalues    = zeros(length(tBinWidth), length(mouseTypes)); % for baseline vs. ssfo comparison

deltaMIByMouse = cell(length(mouseTypes), 1);
pByMouse = zeros(length(tBinWidth), 1); % for CK vs. DIO comparison

for iTBin = 1:length(tBinWidth)
    matName = sprintf('atfFinal_binWidth%dms_MinSpikeBin.mat', round(tBinWidth(iTBin)*1000));
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
        meanMIbase(iTBin, type) = mean(MIbase);
        semMIbase(iTBin, type) = std(MIbase) / sqrt(size(MIbase,1));
        meanMIssfo(iTBin, type) = mean(MIssfo);
        semMIssfo(iTBin, type) = std(MIssfo) / sqrt(size(MIssfo,1));
        meanMIdelta(iTBin, type) = mean(deltaMI);
        semMIdelta(iTBin, type) = std(deltaMI) / sqrt(size(deltaMI,1));
        
        [hpaired, pvalues(iTBin,type)] = ttest(MIbase, MIssfo);
    end
    
    [htwosample pByMouse(iTBin)] = ttest2(deltaMIByMouse{1}, deltaMIByMouse{2}, 0.95, 'both', 'unequal');
end

%% plot MI means vs. time bin for both conditions and indicate p values above

for type = 1:2
    figure(22+type), clf
    h(1) = errorbar(tBinWidth*1000, meanMIbase(:, type), semMIbase(:, type), 'ks-', 'MarkerFaceColor', 'k');
    hold on
    h(2) = errorbar(tBinWidth*1000, meanMIssfo(:, type), semMIssfo(:, type), 'bs-', 'MarkerFaceColor', 'b');
    
    set(h(1), 'LineWidth', 2);
    set(h(2), 'LineWidth', 2);
    
    for iTBin = 1:length(tBinWidth)
        if(pvalues(iTBin,type) < 0.01)
            text(tBinWidth(iTBin)*1000-15, 0.18+meanMIbase(iTBin, type)+semMIbase(iTBin, type), 'p < 0.01');
        elseif(pvalues(iTBin,type) < 0.05)
            text(tBinWidth(iTBin)*1000-15, 0.18+meanMIbase(iTBin, type)+semMIbase(iTBin, type), 'p < 0.05');
        end
    end
    box off
    xlim([0 510]);
    ylim([0 1.4]);
    xlabel('Time Bin Width (ms)');
    ylabel('Mean Mutual Information (bits)');
    legend({'Baseline', '10s 470 nm'}, 'Location', 'Best');
    legendboxoff
    title(mouseTypes{type});
    set(gcf,'Position', [184   280   713   349]);
    movegui(gcf,'center')
end

%% plot mean drop in MI to show CK >> DIO
mouseCmap = [0.4 1 0.4; 0.6 0.47 1];

figure(33), clf
for type = [2 1]
    h = errorbar(tBinWidth*1000, meanMIdelta(:, type), semMIdelta(:, type), 's-', 'Color', mouseCmap(type,:),'MarkerFaceColor', mouseCmap(type,:));
    set(h, 'LineWidth', 2);
    hold on
end

for iTBin = 1:length(tBinWidth)
    if(pByMouse(iTBin) < 0.005)
        text(tBinWidth(iTBin)*1000-15, -0.14+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.005');
    elseif(pByMouse(iTBin) < 0.01)
        text(tBinWidth(iTBin)*1000-15, -0.14+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.01');
    elseif(pByMouse(iTBin) < 0.05)
        text(tBinWidth(iTBin)*1000-15, -0.14+meanMIdelta(iTBin, 1)-semMIdelta(iTBin, 1), 'p < 0.05');
    end
end

box off
xlim([0 510]);
ylim([-1 0]);
xlabel('Time Bin Width (ms)');
ylabel('Mean Change in Mutual Information (bits)');
legend(fliplr(mouseTypes), 'Location', 'Best');
legendboxoff
title('Drop Magnitude Comparison');
set(gcf,'Position', [ 184   280   713   349]);
movegui(gcf,'center')


