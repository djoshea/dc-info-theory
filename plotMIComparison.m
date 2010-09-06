function hfig = plotMIComparison(data, conditionNames, groupNames, varargin)
% plots MI information for each condition, each cell as connected colored line
% data as in gatherComparison returns

def.hfig = [];
def.plotTitle = 'MI Comparison';
def.useCorrected = 0;
def.includeLegend = 1;
def.rainbow = 1;
assignargs(def,varargin);

if(isempty(hfig))
    hfig = figure();
end

Ncells = size(data,1);
Nconditions = size(data,2);

figure(hfig), clf, set(hfig, 'Color', [1 1 1]);
if(rainbow)
    cmap = hsv(Ncells);
else
    cmap = repmat([0 0 0], Ncells, 1);
end
hold on

for i = 1:Ncells
    if(useCorrected)
        miData = [data(i,:).miCorrected];
        miData = [data(i,:).hResponseCorrected];
        miData = [data(i,:).hNoiseCorrected];
        
    else
        miData = [data(i,:).mi];
    end
    
    plot(1:length(conditionNames), miData, 's-', 'LineWidth', 2, 'Color', cmap(i,:));
end

if(includeLegend)
    legend(groupNames, 'Location', 'EastOutside', 'Interpreter', 'none');
    legendboxoff;
end
set(gca, 'XTick', 1:Nconditions, 'XTickLabel', conditionNames);
ylabel('MI (bits)');
xlim([0.5 Nconditions+0.5]);
% title(plotTitle);
set(gcf, 'Position', [ 357    52   740   617]);

end

