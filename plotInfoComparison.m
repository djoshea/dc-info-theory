function [data groupNames] = plotInfoComparison(atfData)
% template describes fields that must match values in the datatable

%% This should be factored out
groupfield = 'cellid';

t = struct();
t.include = 1;
t.celltype = 'Pyramidal';
% t.expressing = 0;
t.opsinState = 0;
t.gAMPA = 1;
t.freqMod = 0;
t.currentInjType = 'Normal';
templates = t;

t.opsinState = 1;
templates(2) = t;

% t.opsinState = 1;
% t.currentInjType = 'Hyperpolarized';
% templates(3) = t;

templateNames = {'Baseline', 'sSFO'};
% templateNames = {'Baseline', 'sSFO', 'Depolarized'};
% templateNames = {'Baseline', 'sSFO', 'Hyperpolarized', 'Depolarized'};

compareString = [templateNames{1}];
for i = 2:length(templateNames)
    compareString = [compareString ' vs ' templateNames{i}];
end

ttl = sprintf('%s Cells, %d Hz Modulation', t.celltype, t.freqMod);
if(isfield(t,'gAMPA'))
    ttl = sprintf('%s, gAMPA = %d nS', ttl, t.gAMPA);
end
%% End factor out

compareData = [];
compareDataGroupNames = {};
groupids = unique({atfData.(groupfield)}); % typically each cell

for g = 1:length(groupids)
    includeGroup = 1;
    fromGroup = [];
    for ti = 1:length(templates) % grab one row for each template
        glist = atfData(strcmp(groupids{g}, {atfData.(groupfield)}));
        t = templates(ti);
        flds = fieldnames(t);
        for fld = 1:length(flds) % match each of the fields in the template
            if(ischar(t.(flds{fld})))
                glist = glist( strcmp({glist.(flds{fld})}, t.(flds{fld})) );
            else
                glist = glist( [glist.(flds{fld})] == t.(flds{fld}) );
            end
            
            if(isempty(glist))
                break;
            end
        end
        
        if(isempty(glist)) % couldn't find a match in this group
            includeGroup = 0;
            break;
        else % found a match, take the first and move to the next template
            if(isempty(fromGroup))
                fromGroup = glist(1);
            else
                fromGroup(ti) = glist(1);
            end
        end
    end
    
    if(includeGroup)
        if(isempty(compareData))
            compareData = fromGroup;
            compareDataGroupNames{1} = groupids{g};
        else
            compareData = [compareData; fromGroup];
            compareDataGroupNames{end+1} = groupids{g};
        end
    end
    
end

N = size(compareData,1);

% MI Summary Plot
fMISummary = 11;
figure(fMISummary), clf, set(fMISummary, 'Color', [1 1 1]);
cmap = hsv(size(compareData,1));
hold on
for i = 1:N
    plot(1:length(templates), [compareData(i,:).MI], 's-', 'LineWidth', 2, 'Color', cmap(i,:));
end

figure(fMISummary);
legend(compareDataGroupNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
set(gca, 'XTick', 1:length(templates), 'XTickLabel', templateNames);
ylabel('MI (bits)');
xlim([0.5 length(templates)+0.5]);
title(['MI Comparison: ' ttl]);
set(gcf, 'Position', [ 357    52   740   617]);
fMISummaryName = ['MI Comparison - ' compareString ' - ' ttl ' (n = ' num2str(N) ').png'];
print(fMISummary, '-dpng', '-r300', fMISummaryName);
