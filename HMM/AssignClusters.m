function AssignedIdx = AssignClusters(NewSample, KMeansC)
% Assigns cluster number given a new data point and K-means cluster centers
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

[~, AssignedIdx] = min(sum(bsxfun(@minus, KMeansC, NewSample).^2,2)); 
end