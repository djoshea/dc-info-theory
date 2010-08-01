% Baseline vs sSSFO comparison
t = struct();
t.include = 1;
t.celltype = 'Pyramidal';
t.expressing = 1;
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

compare = gatherComparison(atfFinal, templates);

% build comparison string
compareString = [templateNames{1}];
for i = 2:length(templateNames)
    compareString = [compareString ' vs ' templateNames{i}];
end

% build title for comparison
ttl = sprintf('%s Cells, %d Hz Modulation', t.celltype, t.freqMod);
if(isfield(t,'gAMPA'))
    ttl = sprintf('%s, gAMPA = %d nS', ttl, t.gAMPA);
end

% hfigMI = plotMIComparison(compare.data, templateNames, compare.groupNames, ...
%     'plotTitle', ['MI Comparison' ttl]);

hfigIO = plotIOTransferComparison(compare.data, templateNames, compare.groupNames, ...
    'plotTitle', ['MI Comparison' ttl]);

fMISummaryName = ['MI Comparison - ' compareString ' - ' ttl ' (n = ' num2str(compare.N) ').png'];
% print(hfig, '-dpng', '-r300', fMISummaryName);
