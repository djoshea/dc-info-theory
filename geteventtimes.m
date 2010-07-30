function [eventtimes] = geteventtimes(filename, nsweeps)

  eventtimes = [];
  N = 0;
  fid = fopen(filename);

  for i=1:nsweeps,
    fscanf(fid, '%s', [1]);
    fscanf(fid, '%d', [1]);
    nevents = fscanf(fid, '%*s%d', [1]);
%     nevents;
    for j=1:nevents,
      [time] = fscanf(fid, '%d', [1]);
      fscanf(fid, '%s', [1]);
      [amp] = fscanf(fid, '%d', [1]);
      if amp,
	N = N+1;
	eventtimes(1,N) = [time/1000];
	eventtimes(2,N) = [i];
      end
    end
    eventtimes(1,N);
    eventtimes(1,N-1);
    fscanf(fid, '%s', [1]);
    fscanf(fid, '%s', [1]);
    fscanf(fid, '%d', [1]);
  end
  
  fclose(fid);
  
  fprintf('\tLoaded %d events from %d sweeps.\n', size(eventtimes,2), nsweeps);
  
  