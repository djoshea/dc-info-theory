%% Test timebin size

tBinWidth = [0.025 0.05 0.075 0.1 0.125 0.5/3 0.25 0.5];
iTBin = 5;
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

nConditions = length(templates);

miByType = cell(length(mouseTypes),1);
deltaMIByMouse = cell(length(mouseTypes), 1);
meanDeltaMI = zeros(length(mouseTypes),1);
semDeltaMI = zeros(length(mouseTypes),1);
meanMI = zeros(length(mouseTypes), nConditions);
semMI = zeros(length(mouseTypes), nConditions);
meanHResponse = zeros(length(mouseTypes), nConditions);
semHResponse = zeros(length(mouseTypes), nConditions);
meanHNoise = zeros(length(mouseTypes), nConditions);
semHNoise = zeros(length(mouseTypes), nConditions);
pvalues    = zeros(length(mouseTypes)); % for baseline vs. ssfo comparison

deltaMIByMouse = cell(length(mouseTypes), 1);
pByMouse = zeros(length(tBinWidth), 1); % for CK vs. DIO comparison

nCellsByType = zeros(length(mouseTypes),1);
% for iTBin = 1:length(tBinWidth)
matName = sprintf('atfFinal_binWidth%dms_MinSpikeBin.mat', round(tBinWidth(iTBin)*1000));
d = load(matName, 'atfFinal');
atfFinal = d.atfFinal;

% Baseline vs sSSFO comparison
useCells = [1 2 4 5 6];
for type = 1:length(mouseTypes)
    [templates.mousetype] = deal(mouseTypes{type});
    compare = gatherComparison(atfFinal, templates);

    mi = reshape([compare.data.miCorrected], size(compare.data));
    hResponse = reshape([compare.data.hResponse], size(compare.data));
%     hNoise = reshape([compare.data.hNoise], size(compare.data));
    % correction for undersampling can violate this equation, so trust the response entropy and the mi
    hNoise = hResponse - mi;
    
    ncells = size(compare.data,1);
    
    if(~isempty(useCells) && type==1)
        mi = mi(useCells, :);
        hResponse = hResponse(useCells, :);
        hNoise = hNoise(useCells, :);
        ncells = length(useCells);
    end
    
    nCellsByType(type) = ncells;
    
    miByType{type} = mi;
    hResponseByType{type} = hResponse;
    hNoiseByType{type} = hNoise;
    
    meanMI(type, :) = mean(mi);
    semMI(type, :) = std(mi) / sqrt(ncells);

    meanHResponse(type,:) = mean(hResponse);
    semHResponse(type,:) = std(hResponse) / sqrt(ncells);

    meanDeltaHResponse(type) = mean(hResponse(:,2) - hResponse(:,1));
    meanDeltaHNoise(type) = mean(hNoise(:,2) - hNoise(:,1));
    
    deltaHResponse{type} = hResponse(:,2) - hResponse(:,1);
    deltaHNoise{type} = hNoise(:,2) - hNoise(:,1);
    
    meanHNoise(type, :) = mean(hNoise);
    semHNoise(type,:) = std(hNoise) / sqrt(ncells);
    
    deltaMIByMouse{type} = mi(:,2) - mi(:,1);
    meanDeltaMI(type) = mean(mi(:,2) - mi(:,1));
    semDeltaMI(type) = std(mi(:,2) - mi(:,1)) / sqrt(ncells);

    [hpaired, pvalues(type)] = ttest(mi(:,1), mi(:,2));
end

[htwosample pByMouse] = ttest2(deltaMIByMouse{1}, deltaMIByMouse{2});
% end

%% plot Hresponse and Hnoise for each cell

for type = 1:2
    figure(22+type), clf
    
    ncells = nCellsByType(type);
    cmap = hsv(ncells);
    for c = 1:ncells
        plot(1:length(templateNames), hResponseByType{type}(c,:), 's-', 'LineWidth', 2, 'Color', cmap(c,:));
        plot(1:length(templateNames), hNoiseByType{type}(c,:), 's--', 'LineWidth', 2, 'Color', cmap(c,:));
        hold on
    end
    
    includeLegend = 0;
    if(includeLegend)
        legend(compare.groupNames, 'Location', 'EastOutside', 'Interpreter', 'none');
        legendboxoff;
    end
    box off
    ylabel('MI (bits)');
    xlim([0.5 length(templateNames)+0.5]);
    set(gca, 'XTickLabel', templateNames);
    title(mouseTypes{type});
    set(gcf,'Position', [ 684        -118        1062         467]);
    movegui(gcf,'center')
end

%% plot means in stacked bar graph

for type = 1:2
    figure(43+type), clf, set(44,'Color', [1 1 1]);
    h = bar([meanHNoise(type,:)' meanMI(type,:)'], 'stacked');
    set(gca, 'XTickLabel', templateNames);
    box off
    ylabel('Bits');
    ylim([0 3.5]);

    for i = 1:nConditions
        h = text(i-0.14, (2*meanHNoise(type,i) + meanMI(type,i)) / 2, sprintf('%.2f bits', meanMI(type,i)));
        set(h, 'Color', [1 1 1], 'FontSize', 14);
        h = text(i-0.14, meanHNoise(type,i) / 2, sprintf('%.2f bits', meanHNoise(type,i)));
        set(h, 'Color', [1 1 1], 'FontSize', 14);
    end

    legend({'Noise Entropy', 'Mutual Information'}, 'Location', 'NorthEastOutside')
    legendboxoff
    title(mouseTypes{type})

end

%% print interesting stats
fprintf('Mean delta HResponse:\t%.4f bits\n', meanDeltaHResponse(1));
fprintf('Mean delta HNoise   :\t%.4f bits\n', meanDeltaHNoise(1));
fprintf('Mean delta MI       :\t%.4f bits\n', meanDeltaMI(1));


