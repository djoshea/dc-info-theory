function [meanhz, stdhz] = dcIOcurve(outrate, stimtrain, timebins, usestims)

meanhz = zeros(size(usestims));
varhz = zeros(size(usestims));

for i=1:length(usestims),
  resp = outrate(stimtrain == usestims(i));
  meanhz(i) = mean(resp);
  stdhz(i) = std(resp);
end
