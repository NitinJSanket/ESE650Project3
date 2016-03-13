% Initializes all HMM parameters
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

%% Add all paths
addpath(genpath('./'));

%% Generate Testing and Training Paths
TrainPath = '../Proj3_train_set/';
TestPath = '../SingleSequence/';
%  FilterName can be: 'Raw', 'Exp', 'Env', 'SG', 'Med'
FilterName = 'Med';

%% Get the names
TrainDirs = dir([TrainPath,'*.txt']);
TestDirs = dir([TestPath,'*.txt']);

%% Load Training and Testing Data
disp(['Filtering using ', FilterName]);

TrainData = cell(1,length(TrainDirs));
for i = 1:length(TrainDirs)
    TrainData{i} = FilterData(load([TrainPath,TrainDirs(i).name]), FilterName);
end
disp('Loading Training data Complete....');


TestData = cell(1,length(TestDirs));
for i = 1:length(TestDirs)
    TestData{i} = FilterData(load([TestPath,TestDirs(i).name]), FilterName);
end
disp('Loading Testing data Complete....');


%% Cluster Stuff to reduce dimentionality
StackedData = [];
for i = 1:length(TrainDirs)
    StackedData = [StackedData; TrainData{i}];
end

%% Initialize other parameters
% Initialize Variables
M = 90; % Number of clusters/unique possible observation samples
N =  10; % Number of states
NIter = 50; % Number of iterations of EM
NumClasses = 6;% Number of classes
NumSamplesPerClassTrain = length(TrainDirs)/NumClasses; % Number of samples in every class of training set, assumes same number of samples in every class
NumSamplesPerClassTest = length(TestDirs)/NumClasses; % Number of samples in every class of testing set, assumes same number of samples in every class

disp('--------------------------------------------------------------------');
disp(['Using ', num2str(M), ' clusters....']);
disp(['Using ', num2str(N), ' states....']);
disp(['Trying to converge in maximum of ', num2str(NIter), ' iterations....']);
disp('--------------------------------------------------------------------');

%% Run Vector Quantization
[KMeansIdxs, KMeansC] = kmeans(StackedData(:,2:end),M,'MaxIter',1000);
disp('Vector Quantization Complete....');



