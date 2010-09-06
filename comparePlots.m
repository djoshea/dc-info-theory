% Baseline vs sSSFO comparison
t = struct();
t.include = 1;
t.celltype = 'Pyramidal';
% 
t.mousetype = 'CaMKII-SSFO';
t.expressing = 1;
% 
% t.mousetype = 'DIO-SSFO';
% t.expressing = 0;

t.opsinState = 0;
t.gAMPA = 3;
t.freqMod = 0;
t.currentInjType = 'Normal';
templates = t;
templateNames = {'Baseline'};

t.opsinState = 1;
templates(end+1) = t;
templateNames{end+1} = 'sSFO';

% 
% t.opsinState = -1;
% templates(end+1) = t;
% templateNames{end+1} = 'Yellow Hold';

% t.opsinState = 0;
% t.freqMod = 40;
% templates(end+1) = t;
% templateNames{end+1} = 'Gamma';
% 
% t.opsinState = 1;
% t.freqMod = 40;
% templates(end+1) = t;
% templateNames{end+1} = 'Gamma sSFO';

% t.opsinState = 1;
% t.currentInjType = 'Hyperpolarized';
% templates(end+1) = t;
% templateNames{end+1} = 'Hyperpolarized';
% 
% t.opsinState = 0;
% t.currentInjType = 'Depolarized';
% templates(end+1) = t;
% templateNames{end+1} = 'Depolarized';

compare = gatherComparison(atfFinal, templates, 'includeFilenamesInLegend', 1);

% build comparison string
compareString = [templateNames{1}];
for i = 2:length(templateNames)
    compareString = [compareString ' vs ' templateNames{i}];
end

% build title for comparison
ttl = sprintf('%s Cells, %d Hz Modulation', t.celltype, t.freqMod);
if(isfield(t,'gAMPA'))
    ttl = sprintf('%s, gAMPA = %d nS', ttl, t.gAMPA*3);
end

if(isempty(compare.data))
    disp('No cells match this comparison');
    return
end

hfigMI = plotMIComparison(compare.data, templateNames, compare.groupNames, ...
    'plotTitle', ['MI Comparison' ttl],'includeLegend', 1, 'rainbow', 1, 'useCorrected', 1);

figure(hfigMI)
% ylim([0 1.4]);
% set(gcf, 'Position', [941   -70   367   619]);
set(gca, 'YTick', 0:0.2:1.4);

% hfigIO = plotIOTransferComparison(compare.data, templateNames, compare.groupNames, ...
%     'plotTitle', ['MI Comparison' ttl]);

fMISummaryName = ['MI Comparison - ' compareString ' - ' ttl ' (n = ' num2str(compare.N) ').png'];
% print(hfig, '-dpng', '-r300', fMISummaryName);

%% Run statistics

s = size(compare.data);
Ncells = s(1);
Ncond = s(2);

fieldname = 'mi';
fieldname = 'miCorrected';
fieldname = 'hResponseCorrected';
fieldname = 'hNoiseCorrected';

MI = reshape([compare.data.(fieldname)], size(compare.data));

MIbase = MI(:,1);
MIssfo = MI(:,2);

deltaMI = MIssfo - MIbase;
[MIbase MIssfo deltaMI]

fprintf('Mean Baseline: %.3f +- %.3f bits\n', mean(MIbase), std(MIbase));
fprintf('Mean sSFO:     %.3f +- %.3f bits\n', mean(MIssfo), std(MIssfo));

[hpaired, ppaired] = ttest(MIbase, MIssfo);
fprintf('Ppaired = %.4f\n',ppaired);

[honesided, ponesided] = ttest(MIssfo - MIbase, 0, 0.1, 'left');
fprintf('Ponesided = %.4f\n',ponesided);

% return;

%% Sample DC curve

% sample cell = 2010_06_09 (files 0024 and 0025)

% demo cells:
% cell 2 for CK-SSFO


cdata = compare.data(4,:);
cname = compare.groupNames{1};

cdataRebinned = processATFBinning(cdata, 'inRateBinMin', 0, 'inRateBinWidth', 50, 'inRateBinMax', 550);
d = cdataRebinned;

figure(55), clf, set(55, 'Color', [1 1 1]);
cmap = [0.3 0.3 0.3; ...
        0   0   1  ; ...
        0.6 0.6 0.6
        0.3 0.3 0.8];

cmap = [ 0.3 0.3 0.3; ...
         0   0   1  ; ...
         0.98 0.77 0.27 ];
    
hold on
for c = 1:length(templateNames)
    errorbar(d(c).inRateBinCenters, d(c).meanhz, d(c).semhz, ...
        '-','Color',cmap(c,:),'LineWidth', 2);
end

legend(templateNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
xlabel('Input EPSC Rate (Hz)');
ylabel('Firing Rate (Hz)');
% title(sprintf('Representative Cell, gAMPA = %d nS', t(1).gAMPA * 3));
% ylim([-1 20]);
xlim([0 705]);
% ylim([0 40]);
set(gcf, 'Position', [ 357    52   740   617]);

