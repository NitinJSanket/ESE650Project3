% Function which trains and tests HMM
% Written as a part of Project 3 for ESE 650: Learning in Robotics at
% University of Pennsylvania
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

clc
clear all
close all

%% Initialize Stuff
InitHMM;

%% Train HMM
HMMModel = TrainHMM(TrainData, KMeansC, NIter, M, N, NumClasses, NumSamplesPerClassTrain, FilterName);

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
    [Score{i}, GuessedClass{i}, Confidence(i)] = TestHMM(TestData{i}(:,2:end),HMMModel, Names{i}, NamesOrg, NumClasses, N);
    bar(Score{i});
    title(['Actual ',Names{i}, ' Guessed ', GuessedClass{i}, ' with Confidence ', num2str(Confidence(i))]);
    set(gca,'XTickLabel',NamesOrg);
    ylabel('Confidence');
    saveas(gcf, ['./Outputs/',num2str(i),'.jpg']);
    if(strcmp(GuessedClass{i},Names{i}))
        Accuracy = Accuracy + 1;
    end
end

Accuracy = (Accuracy./length(TestDirs)).*100;
disp(['Total Accuracy ', num2str(Accuracy)]);

