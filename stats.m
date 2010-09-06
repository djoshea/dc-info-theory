% Baseline vs sSSFO comparison
t = struct();
t.include = 1;
t.celltype = 'Pyramidal';
t.expressing = 1;
t.opsinState = 0;
t.gAMPA = 2;
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

compare = gatherComparison(atfFinal, templates, 'includeFilenamesInLegend', 1);

s = size(compare.data);
Ncells = s(1);
Ncond = s(2);

MI = reshape([compare.data.MI], size(compare.data))

MIbase = MI(:,1);
MIssfo = MI(:,2);

deltaMI = MIssfo - MIbase;

fprintf('Mean Baseline: %.3f +- %.3f bits\n', mean(MIbase), std(MIbase));
fprintf('Mean sSFO:     %.3f +- %.3f bits\n', mean(MIssfo), std(MIssfo));

[h, ppaired] = ttest(MIbase, MIssfo);
fprintf('Ppaired = %.4f\n',ppaired);

[h, ponesided] = ttest(MIssfo - MIbase, 0, 0.1, 'left');
fprintf('Ponesided = %.4f\n',ponesided);

%% Sample DC curve

% sample cell = 2010_06_09 (files 0024 and 0025)
cdata = compare.data(2,:);
cname = compare.groupNames{1};

cdataRebinned = processATFBinning(cdata, 'rateBinMin', -10, 'rateBinWidth', 50);
d = cdataRebinned;

figure(5), clf, set(5, 'Color', [1 1 1]);
cmap = [0.3 0.3 0.3; 0 0 1];
hold on
for c = 1:length(templateNames)
    errorbar(d(c).inRateBinCenters, d(c).meanhz, d(c).semhz, ...
        '-','Color',cmap(c,:),'LineWidth', 2);
end

legend(templateNames, 'Location', 'EastOutside', 'Interpreter', 'none');
legendboxoff;
xlabel('Input EPSC Rate (Hz)');
ylabel('Firing Rate (Hz)');
title(sprintf('Representative Cell, gAMPA = %d nS', t(1).gAMPA));
% ylim([-1 20]);
xlim([-5 505]);
set(gcf, 'Position', [ 357    52   740   617]);

