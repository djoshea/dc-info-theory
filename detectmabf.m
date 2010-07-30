function [] = detectmabf(filename, spikethreshold, minrepol, ...
                         nsweeps)
% e.g. detectmabf('f:/axon data/', 'filelist', 0, -30, 20)

% detects spikes in each of the files listed in 'infilelist'
% uses spikethreshold, and min threshold for repolarization as
% specified by user
% nsweeps is the number of sweeps to analyze

% assumes timestep = 50 microsec, and refractory period = 2 msec

% filelist = sprintf('%s%s', directory, infilelist);
% 
% fid = fopen(filelist);
% 
% filename = fscanf(fid, '%s', 1);

for i=1:9,
  months(i) = sprintf('%d', i);
end

months(10) = 'o';
months(11) = 'n';
months(12) = 'd';

fprintf('Detecting spikes in %s...\n', filename);
A = detectabfspikes(filename, spikethreshold, 2, minrepol, nsweeps);
year = sscanf(filename, '%d', 1);
month = sscanf(filename, '%*d_%d', 1);
day = sscanf(filename, '%*d_%*d_%d', 1);
fileno = sscanf(filename, '%*d_%*d_%*d_%d', 1);

outfilename = sprintf('%s%02d%c%02d%03dspikes', directory, ...
                    mod(year,100), months(month), day, fileno);

fid2 = fopen(outfilename, 'w');
fprintf(fid2, '%d\t%f\n', A);
fclose(fid2);
