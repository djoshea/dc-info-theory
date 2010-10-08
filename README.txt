DC Info theory analysis, round 2

atfs = loadATFList()
	pick the appropriate csv file, see google doc
inputProtocols = loadInputTimes();
	to load the input times from the exc0hzscript2 type files

atfTimes = processATFTimes(atfs, inputProtocols);
    loads each atf in the atfs list, grabs input times from the right protocol
    and detects the spikes in the ATF file. Also saves .traces.mat cache of ATF
    data so the next load is quicker