function [mutinf, p, Hr, Hrs, nstims] = computemutinf6(responses, bins, stimtrain, usestims)

% computes the mutual information, but assumes that all stimuli are
% equally likely
  
  nstims = 0;
  N = size(responses);

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
  ptmp = sum(p(:,j));
  if ptmp,
    Hr = Hr - ptmp * log2(ptmp);
  end
end