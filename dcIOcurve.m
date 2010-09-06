function [meanhz, stdhz, semhz] = dcIOcurve(outRateHz, inRateBin, inRateBinsList)

meanhz = zeros(size(inRateBinsList));
varhz = zeros(size(inRateBinsList));

for i=1:length(inRateBinsList),
  resp = outRateHz(inRateBin == inRateBinsList(i));
  meanhz(i) = mean(resp);
  stdhz(i) = std(resp);
  semhz(i) = std(resp) / sqrt(length(resp));
end
