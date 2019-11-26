% This function performs multinomial re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = multinomial_resample(S_bar)

    global M % number of particles
    % YOUR IMPLEMENTATION
    S=zeros(4,M);
    CDF=cumsum(S_bar(4,:)); 
    r=rand(1,M);

    for m=1:M
        CDF_temp=CDF;
        CDF_temp(CDF_temp<r(m))=inf;
        [~,i]=min(CDF_temp);
        S(1:3,m)=S_bar(1:3,i);
    end
    
    S(4,:)=(1/M)*ones(1,M);
end
