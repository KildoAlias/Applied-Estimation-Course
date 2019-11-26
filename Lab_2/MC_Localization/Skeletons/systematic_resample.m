% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = systematic_resample(S_bar)
	
    global M % number of particles 
    
    % YOUR IMPLEMENTATION
     CDF=cumsum(S_bar(4,:)); 
     r0=rand()*(1/M);
     S=zeros(4,M);
     for m=1:M
         i=find(CDF>=r0+(m-1)/M, 1 );
         S(:,m)=S_bar(:,i);
     end
     S(4,:)=(1/M)*ones(1,M);
end