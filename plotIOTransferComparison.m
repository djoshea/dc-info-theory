function hfig = plotIOTransferComparison( data, conditionNames, groupNames, varargin )

Ncells = size(data,1);
Nconditions = size(data,2);

def.hfig = [];
def.plotTitle = 'IO Transfer Function Comparison';
def.cmap = 0.9*hsv(Ncells);
assignargs(def,varargin);

if(isempty(hfig))
    hfig = figure();
end

lineStyleOrder = {'-','--',':'};

figure(hfig), clf, set(hfig, 'Color', [1 1 1]);
hold on
for i = 1:Ncells
    for c = 1:Nconditions  
        norm = max(max([data(i,:).meanhz]));
        plot(data(i,c).inRateBinCenters, data(i,c).meanhz, ...
            lineStyleOrder{c}, 'LineWidth', 2, 'Color', cmap(i,:));
    end
end

legend(groupNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
xlabel('Input EPSC Rate (Hz)');
ylabel('Firing Rate (Normalized Per Cell)');
title(plotTitle);
set(gcf, 'Position', [ 357    52   740   617]);

end
