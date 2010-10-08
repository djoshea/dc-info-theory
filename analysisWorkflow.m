% pretty much the whole analysis proceeds in this fashion

atfs = loadATFList('/Users/djoshea/Documents/Research/dLab/dcinfo/dLab Info Theory ATF Log Reduced.csv');
% load atfFinal;
% atfs = atfFinal;
% inputProtocols = loadInputTimes();
load inputProtocols;

atfTimes = processATFTimes(atfs, inputProtocols, 'overwriteSavedTimes', 0, 'saveTimesFile', 1, 'plotTraces', 0);

%%
% atfBinned = processATFBinning(atfTimes);
% 
% atfFinal = processATFInformation(atfBinned);

% return
