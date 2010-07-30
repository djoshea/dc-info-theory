function summaryPlot(prs, res)

%% Summary plot of MI changes

conditionNames = {'Baseline', 'sSFO', 'Depolarized'};
Nconditions = length(conditionNames);
normMI = NaN(length(res), Nconditions);
Hresponse = normMI;
MI = normMI;
color =  hsv(length(res));

for i = 1:length(res)
    for j = 1:length(res{i})
       cname = res{i}(j).name;
       ci = strmatch(cname, conditionNames);
       if(isempty(ci))
           continue;
       else
           MI(i,ci) = res{i}(j).MI;
           Hresponse(i,ci) = res{i}(j).Hresponse;
           normMI(i,ci) = MI(i,j) / Hresponse(i,j);
       end
    end
end

% MI Summary Plot
fMISummary = 11;
figure(fMISummary), clf, set(gcf, 'Color', [1 1 1]);
hold on
for i = 1:length(res)
    plot(1:Nconditions, MI(i,:), 's-', 'LineWidth', 2, 'Color', color(i,:));
end

figure(fMISummary);
legend({prs.name}, 'Location', 'EastOutside');
legendboxoff;
set(gca, 'XTick', 1:3, 'XTickLabel', conditionNames);
ylabel('MI (bits)');
xlim([0.5 3.5]);
title('MI Summary');
set(gcf, 'Position', [ 1     1   834   365]);
fMISummaryName = 'MI Summary Plot.png';
print(fMISummary, '-dpng', '-r300', fMISummaryName);

% Normalized MI Summary Plot
fNormMISummary = 12;
figure(fNormMISummary), clf, set(gcf, 'Color', [1 1 1]);
hold on
for i = 1:length(res)
    plot(1:Nconditions, normMI(i,:), 's-', 'LineWidth', 2, 'Color', color(i,:));
end

figure(fNormMISummary);
legend({prs.name}, 'Location', 'EastOutside');
legendboxoff;
set(gca, 'XTick', 1:3, 'XTickLabel', conditionNames);
ylabel('MI Normalized by Response Entropy');
xlim([0.5 3.5]);
title('Normalized MI Summary');
set(gcf, 'Position', [ 1     1   834   365]);
fNormMISummaryName = 'Normalized MI Summary Plot.png';
print(fNormMISummary, '-dpng', '-r300', fNormMISummaryName);


% Summary Plot of Response Entropy
fHResponseSummary = 13;
figure(fHResponseSummary), clf, set(gcf, 'Color', [1 1 1]);
hold on
for i = 1:length(res)
    plot(1:Nconditions, Hresponse(i,:), 's-', 'LineWidth', 2, 'Color', color(i,:));
end

figure(fHResponseSummary);
legend({prs.name}, 'Location', 'EastOutside');
legendboxoff;
set(gca, 'XTick', 1:3, 'XTickLabel', conditionNames);
ylabel('Response Entropy (bits)');
% ylim([0 1]);
xlim([0.5 3.5]);
title('Response Entropy Summary');
set(gcf, 'Position', [ 1     1   834   365]);
fHResponseSummaryName = 'Response Entropy Summary Plot.png';
print(fHResponseSummary, '-dpng', '-r300', fHResponseSummaryName);

    
