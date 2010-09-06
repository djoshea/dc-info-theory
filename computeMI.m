function [mi Hresponse Hnoise ioDist] = computeMI(inRateBin, outRateBin, inRateBinsList, outRateBinsList)

% computes the mutual information, but assumes that all stimuli are
% equally likely
  
% p(i,j) is the pdf at input rate bin i and output rate bin j
% sum(p(:,j)) is prob of out rate bin j
% 1 / nstims is prob of in rate bin i
% nstims * p(i,j) / sum(p(:,j)) is p(i,j) / (p(i)*p(j)) essentially

% convert inRateBin and outRateBin into bins that index into the binLists
[validInBin inRateBin] = ismember(inRateBin(:), inRateBinsList);
[validOutBin outRateBin] = ismember(outRateBin(:), outRateBinsList);

inRateBin = inRateBin(validInBin & validOutBin);
outRateBin = outRateBin(validInBin & validOutBin);
nInBins = length(inRateBinsList);
nOutBins = length(outRateBinsList);
N = numel(inRateBin);

% compute the joint distribution
nInBinsOccupied = 0;
ioDist = zeros(nInBins, nOutBins);
for inBin = 1:nInBins
    if(nnz(inRateBin == inBin))
        nInBinsOccupied = nInBinsOccupied + 1;
    end
    for outBin = 1:nOutBins
        ioDist(inBin, outBin) = nnz(inRateBin == inBin & outRateBin == outBin) / N;
%           ioDist(inBin, outBin) = nnz(inRateBin == inBin & outRateBin == outBin) / nnz(inRateBin == inBin);
    end
end

ioDist(isnan(ioDist)) = 0;
% ioDist = ioDist / nInBinsOccupied;

% compute the marginals
iDist = sum(ioDist, 2);
oDist = sum(ioDist, 1);

% mi = sum_i sum_o p(i,o)*log2(p(i,o) / (p(i) * p(o)))
% Hnoise = - sum_i sum_o p(i,o) * log2( p(i,o) / p(i) )
% Hresponse = - sum_o p(o) * log2(p(o))

mi = 0;
Hresponse = 0;
Hnoise = 0;

for outBin = 1:nOutBins
    if(oDist(outBin))
        Hresponse = Hresponse - oDist(outBin)*log2(oDist(outBin));
    end
    
    for inBin = 1:nInBins
        if(ioDist(inBin, outBin)) % ignore 0 elements
            mi = mi + ioDist(inBin, outBin) * log2(ioDist(inBin, outBin) / (iDist(inBin) * oDist(outBin)));
            Hnoise = Hnoise - ioDist(inBin, outBin) * log2(ioDist(inBin, outBin) / iDist(inBin));
        end
    end
end

return

%%
  % compute the probabilities
  for i=1:length(usestims),
    p(i,:) = histc(responses(stimtrain == usestims(i)), bins);
    if (sum(sum(stimtrain ==usestims(i)))),
      p(i,:) = p(i,:) / (sum(sum(stimtrain == usestims(i))));
      nstims = nstims + 1;
    end
  end

  p = p / nstims;
  
% compute the mutual information
mutinf = 0;
Hrs = 0;

for i=1:length(usestims),
  for j=1:(length(bins)-1),
    if p(i,j),
      mutinf = mutinf + p(i,j) * log2(nstims * p(i,j) / sum(p(:,j)));
      prs = p(i,j)/sum(p(i,:));
      Hrs = Hrs - p(i,j) * log2(prs);
    end
  end
end

Hr = 0;
for j=1:(length(bins)-1),
  ptmp =  sum(p(:,j));
  if ptmp,
    Hr = Hr - ptmp * log2(ptmp);
  end
end

