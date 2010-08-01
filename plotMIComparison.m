function hfig = plotMIComparison(data, conditionNames, groupNames, varargin)
% plots MI information for each condition, each cell as connected colored line
% data as in gatherComparison returns

def.hfig = [];
def.plotTitle = 'MI Comparison';
assignargs(def,varargin);

if(isempty(hfig))
    hfig = figure();
end

Ncells = size(data,1);
Nconditions = size(data,2);

figure(hfig), clf, set(hfig, 'Color', [1 1 1]);
cmap = hsv(Ncells);
hold on
for i = 1:Ncells
    plot(1:length(conditionNames), [data(i,:).MI], 's-', 'LineWidth', 2, 'Color', cmap(i,:));
end

legend(groupNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
set(gca, 'XTick', 1:Nconditions, 'XTickLabel', conditionNames);
ylabel('MI (bits)');
xlim([0.5 Nconditions+0.5]);
title(plotTitle);
set(gcf, 'Position', [ 357    52   740   617]);

end

