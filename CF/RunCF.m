% Runs a Complementary Filter Code for attitude estimation
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

%% Allocate space for variables
GYROEULS = zeros(3,size(Acc,2));
ACCEULS = zeros(3,size(Acc,2));
CFEULS = zeros(3,size(Acc,2));
rotsGyro = zeros(3,3,size(Acc,2));
rotsAcc = zeros(3,3,size(Acc,2));
rotsCF = zeros(3,3,size(Acc,2));

%% Run the complementary filter
disp('CF Execution Started....');
NIter = size(Data,1);
h = waitbar(0,'CF Running....');
W = 0.5;
qcf = [1,0,0,0]';
for i = 1:NIter
    if(i==1)
        dt = 0.004;
    else
        dt = (Data(i,1)-Data(i-1,1))*1e-3; % Time is in ms
    end
    qq1 = rv2q(Gyro(:,i)*dt);
    qcf = qmult(qcf,qq1);
    rotsGyro(:,:,i) = quat2rotm(qcf');
    GYROEULS(:,i) = rotm2eul(rotsGyro(:,:,i));
    ACCEULS(:,i) = [0,atan2(-Acc(1,i),sqrt(Acc(2,i).^2+Acc(3,i).^2)),atan2(Acc(2,i),sqrt(Acc(1,i).^2+Acc(3,i).^2))];%atan2(sqrt(Acc(1,i).^2+Acc(2,i).^2),Acc(3,i))
    CFEULS(:,i) = W.*GYROEULS(:,i)+(1-W).*ACCEULS(:,i);
    rotsAcc(:,:,i) = eul2rotm(ACCEULS(:,i)');
    rotsCF(:,:,i) = eul2rotm(CFEULS(:,i)');
    waitbar(i/NIter);
end

close(h);

disp('CF Execution Completed....');
