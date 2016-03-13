function [Score, GuessedClass, Confidence] = TestHMMEarlyTermination(TestData, HMMModel, TrueName, AllNames, NumClasses, N)
% Function which predicts the class given the HMM Model and Test Query
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

T = length(TestData);

AAvg = HMMModel.A;
BAvg = HMMModel.B;
PiAvg = HMMModel.Pi;
KMeansC = HMMModel.KMeansC;

Ot = zeros(1,T);
for t = 1:T
    Ot(t) = AssignClusters(TestData(t,:),KMeansC);
end

% Score = zeros(1,NumClasses);
Normalization = zeros(T,NumClasses);

for Class = 1:NumClasses
    A = AAvg{Class};
    B = BAvg{Class};
    Pi = PiAvg{Class};
    
    Alpha = zeros(N,T);
    
    % Forward Procedure
    % Initialization
    Alpha(:,1) = Pi.*B(:,Ot(1));
    % Normalize Alpha
    Normalization(1,Class) = sum(Alpha(:,1));
    Alpha(:,1) = Alpha(:,1)./Normalization(1,Class);
    
    % Induction
    for t = 1:T-1
        Alpha(:,t+1) = sum(bsxfun(@times, Alpha(:,t),A),2).*B(:,Ot(t+1));
        Normalization(t+1,Class) = sum(Alpha(:,t+1));
        Alpha(:,t+1) = Alpha(:,t+1)./Normalization(t+1,Class);
    end
    
end


Count = 1;
MinSamples = 550;
for Time = min(T,MinSamples):50:T
    for Class = 1:NumClasses
        Score(Class) = -1./sum(log(Normalization(Time,Class)));
    end
    
    [~, MaxIdx] = max(Score);
    SortedScore = sort(Score,'ascend');
    %     Confidence = sum(max(Score)./Score);
    Confidence = (SortedScore(end)./SortedScore(end-1) - 1);
    GuessedClass = AllNames{MaxIdx};
    if(Time==T)
        disp(['Actual ',TrueName, ' Guessed ', GuessedClass, ' with Confidence ', num2str(Confidence)]);
        disp(['Used all the Samples....']);
        break;
    end
    if(Confidence>=Time/0.9/MinSamples)
        disp(['Actual ',TrueName, ' Guessed ', GuessedClass, ' with Confidence ', num2str(Confidence)]);
        disp(['Used ', num2str(Time), ' Samples....']);
        break;
    end
    Count = Count + 1;
end
end