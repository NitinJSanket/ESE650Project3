function Data = StandardizeData(Data)
% Function that standardize the input data, i.e., mean = 0, std = 1
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

Data = bsxfun(@times, Data, mean(Data));
Data = bsxfun(@rdivide, Data, std(Data));
end