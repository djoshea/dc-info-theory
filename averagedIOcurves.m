% run compare plots with the right settings first

ntemplates = size(compare.data,2);

for i = 1:compare.N
    if(i == 3)
        continue;
    end
    cdata = compare.data(i,:);
    cname = compare.groupNames{1};
    
    cdataRebinned = processATFBinning(cdata, 'rateBinMin', 0, 'rateBinWidth', 50, 'rateBinMax', 550);
    d = cdataRebinned;
    
    if(i == 1)
        nbins = length(d(1).meanhz);
        sumMeanHz = zeros(nbins, ntemplates);
    end
    for c = 1:ntemplates
%         normhz = d(c).meanhz' ./ max([d(:).meanhz]);
        normhz = d(c).meanhz';
        sumMeanHz(:,c) = sumMeanHz(:,c) + normhz;
    end
end

meanhz = sumMeanHz / (compare.N-1);

figure(55), clf, set(55, 'Color', [1 1 1]);
cmap = [0.3 0.3 0.3; ...
    0   0   1  ; ...
    0.6 0.6 0.6
    0.3 0.3 0.8];
hold on
for c = 1:length(templateNames)
    plot(d(c).inRateBinCenters, meanhz(:,c)', ...
        '-','Color',cmap(c,:),'LineWidth', 2);
end

legend(templateNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
xlabel('Input EPSC Rate (Hz)');
ylabel('Firing Rate (Hz)');
% ylabel('Normalized Firing Rate');
% title(sprintf('Representative Cell, gAMPA = %d nS', t(1).gAMPA * 3));
% ylim([-1 20]);
xlim([0 705]);
% ylim([0 40]);
set(gcf, 'Position', [ 357    52   740   617]);

