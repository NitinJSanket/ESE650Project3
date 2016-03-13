clc
clear all
close all

count = 1;
for N = 5:1:20
    clearvars -except count N MinConf
    disp('------------------------------------------------');
    disp(['Trying with ', num2str(N), ' states']);
    %% Initialize Stuff
    InitHMM;
    
    %% Train HMM
    HMMModel = TrainHMM(TrainData, KMeansC, NIter, M, N, NumClasses, NumSamplesPerClassTrain);
    
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
        [Score{i}, GuessedClass{i}, Confidence(i)] = TestHMM(TestData{i}(:,2:end), KMeansC, HMMModel, Names{i}, NamesOrg, NumClasses, M, N);
        if(strcmp(GuessedClass{i},Names{i}))
            Accuracy = Accuracy + 1;
        end
    end
    
    Accuracy = (Accuracy./length(TestDirs)).*100;
    disp(['Total Accuracy ', num2str(Accuracy)]);
    
    MinConf(count) = min(Confidence);
    count = count + 1;
end
