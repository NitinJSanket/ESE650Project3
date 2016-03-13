function HMMModel = TrainHMMContinual(TrainData, KMeansC, NIter, M, N, NumClasses, NumSamplesPerClassTrain)
% Train a HMM given vector quantized training data and the corresponding
% cluster centers
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

%% Run HMM for all classes and all training samples
for Class = 1:NumClasses
    % Initialize Variables
    Pi = rand(N,1);
    Pi = Pi./norm(Pi);
    A = rand(N);
    A = bsxfun(@rdivide, A, sum(A,1));
    B = rand(N,M);
    B = bsxfun(@rdivide, B, sum(B,2));
    for Sample = 1:NumSamplesPerClassTrain
        disp(['Class: ',num2str(Class),' Sample: ', num2str(Sample)]);
        DataNow = TrainData{(Class-1)*NumSamplesPerClassTrain + Sample};
        DataNow = DataNow(:,2:end);
        T = size(DataNow,1);
        P = inf(NIter,1);
        Ot = zeros(1,T);
        for t = 1:T
            Ot(t) = AssignClusters(DataNow(t,:),KMeansC);
        end
        
        for iter = 1:NIter
            Normalization = zeros(T,1);
            Alpha = zeros(N,T);
            Beta = zeros(N,T);
            Xi = zeros(N,N,T-1);
            
            % Forward Procedure
            % Initialization
            Alpha(:,1) = Pi.*B(:,Ot(1));
            % Normalize Alpha
            Normalization(1) = sum(Alpha(:,1));
            Alpha(:,1) = Alpha(:,1)./Normalization(1);
            
            % Induction
            for t = 1:T-1
                Alpha(:,t+1) = sum(bsxfun(@times,Alpha(:,t),A),2).*B(:,Ot(t+1));
                Normalization(t+1) = sum(Alpha(:,t+1));
                Alpha(:,t+1) = Alpha(:,t+1)./Normalization(t+1);
            end
            
            
            % Backward Procedure
            % Initialization
            Beta(:,end) = ones(N,1);
            % Normalize Beta
            Beta(:,end) = Beta(:,end)./sum(Beta(:,end));
            
            % Induction
            for t = T-1:-1:1
                Beta(:,t) = sum(bsxfun(@times,bsxfun(@times, Beta(:,t+1),A),B(:,Ot(t+1))),1)';
                Beta(:,t) = Beta(:,t)./sum(Beta(:,t));
            end
            
            % Solution to problem 2
            Gamma = bsxfun(@rdivide,Alpha.*Beta,sum(Alpha.*Beta));
            
            % Solution to Problem 3
            for t = 1:T-1
                Xi(:,:,t) = bsxfun(@times,bsxfun(@times,bsxfun(@times, Alpha(:,t),A),B(:,Ot(t+1))),Beta(:,t+1));
                Xi(:,:,t) = Xi(:,:,t)./sum(sum(Xi(:,:,t)));
            end
            
            % Maximization
            Pi = Gamma(:,1);
            A = bsxfun(@rdivide, sum(Xi,3), sum(Gamma(:,1:end-1),2));
            
            for i = 1:M
                B(:,i) =  sum(Gamma(:,Ot==i),2);
            end
            B = bsxfun(@rdivide,B,sum(Gamma,2));
            
            % Laplace Smoothing! (Without this it just doesn't work)
            B(B<1e-12) = 1e-12;
            B = bsxfun(@rdivide, B, sum(B,2));
            
            P(iter) = -1./sum(log(Normalization));
            
            if(iter>1)
                Diff = abs(P(iter)-P(iter-1));
                if(Diff<=1e-7)
                    disp(['Convereged in ', num2str(iter), ' Iterations']);
                    break;
                end
                if(iter==NIter)
                    disp(['Reached Maximum iterations of ',num2str(NIter),' Terminating....']);
                end
            end
        end
    end
    AAll{Class} = A;
    BAll{Class} = B;
    PiAll{Class} = Pi;
end

%% Save the Model
HMMModel.A = AAll;
HMMModel.B = BAll;
HMMModel.Pi = PiAll;
% save(['HMMModelM',num2str(M),'N',num2str(N),'Continual.mat'],'HMMModel');

disp('HMM Training Complete....');
end