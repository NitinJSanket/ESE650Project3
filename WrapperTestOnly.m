% Initializes all HMM parameters
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)
clc
clear all
close all

%% Load the model
load('HMMModelM90N10Med.mat');

%% Add all paths
addpath(genpath('./'));

%% Generate Testing and Training Paths
TestPath = '../SingleSequence/';

%% Get the names
TestDirs = dir([TestPath,'*.txt']);

%% Load  Testing Data
disp(['Filtering using ', HMMModel.FilterName]);
TestData = cell(1,length(TestDirs));
for i = 1:length(TestDirs)
    TestData{i} = FilterData(load([TestPath,TestDirs(i).name]), HMMModel.FilterName);
end
disp('Loading Testing data Complete....');

%% Initialize other parameters
% Initialize Variables
M = 90; % Number of clusters/unique possible observation samples
N =  10; % Number of states
NIter = 25; % Number of iterations of EM
NumClasses = 6;% Number of classes
NumSamplesPerClassTest = length(TestDirs)/NumClasses; % Number of samples in every class of testing set, assumes same number of samples in every class

disp('--------------------------------------------------------------------');
disp(['Using ', num2str(M), ' clusters....']);
disp(['Using ', num2str(N), ' states....']);
disp('--------------------------------------------------------------------');


%% Test HMM
NamesOrg = {'beat3','beat4','circle','eight','inf','wave'};
Names = [repmat({'beat3'},1,NumSamplesPerClassTest),repmat({'beat4'},1,NumSamplesPerClassTest),...
    repmat({'circle'},1,NumSamplesPerClassTest),repmat({'eight'},1,NumSamplesPerClassTest),...
    repmat({'inf'},1,NumSamplesPerClassTest),repmat({'wave'},1,NumSamplesPerClassTest)];

Score = cell(length(TestDirs),1);
GuessedClass = cell(length(TestDirs),1);
Confidence = zeros(length(TestDirs),1);

Accuracy = 0;
for i = 1:length(TestDirs)
    [Score{i}, GuessedClass{i}, Confidence(i)] = TestHMM(TestData{i}(:,2:end), HMMModel, Names{i}, NamesOrg, NumClasses, N);
    if(strcmp(GuessedClass{i},Names{i}))
        Accuracy = Accuracy + 1;
    end
    bar(Score{i});
    title(['Actual ',Names{i}, ' Guessed ', GuessedClass{i}, ' with Confidence ', num2str(Confidence(i))]);
    set(gca,'XTickLabel',NamesOrg);
    ylabel('Confidence');
    saveas(gcf, ['./Outputs/',num2str(i),'.jpg']);
end

Accuracy = (Accuracy./length(TestDirs)).*100;
disp(['Total Accuracy ', num2str(Accuracy)]);
