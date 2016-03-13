function Data = FilterData(Data, FilterName)
% Function that filter's the input data with one of the specified filters
% FilterName can be: 'Raw', 'Exp', 'Env', 'SG', 'Med'
% Code by: Nitin J. Sanket (nitinsan@seas.upenn.edu)

if(nargin<2)
    return;
end

switch FilterName
    case 'Raw'
        return;
    case 'Exp'
        for i = 1:size(Data,2)
            Wt = 0.1;
            Data(:,i) = filter(Wt, [1 Wt-1], Data(:,i));
        end
    case 'Env'
        for i = 1:size(Data,2)
            [envHigh, envLow] = envelope(Data(:,i),16,'peak');
            Data(:,i) = (envHigh+envLow)/2;
        end
    case 'SG'
        if(mod(length(Data(:,1)),2)==0)
            Data = Data(1:end-1,:);
        else
            for i = 1:size(Data,2)
                Data(:,i) = sgolayfilt(Data(:,i), 5, 9);
            end
        end
    case 'Med'
        for i = 1:size(Data,2)
            Data(:,i) = medfilt1(Data(:,i),10,'truncate');
        end
    otherwise
        return;
end

end