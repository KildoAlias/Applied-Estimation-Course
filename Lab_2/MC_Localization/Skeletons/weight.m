% This function calcultes the weights for each particle based on the
% observation likelihood
%           S_bar(t)            4XM
%           outlier             1Xn
%           Psi(t)              1XnXM
% Outputs: 
%           S_bar(t)            4XM
function S_bar = weight(S_bar, Psi, outlier)
    % YOUR IMPLEMENTATION
    
    weight=prod(Psi(1,outlier==0,:),2);
    S_bar(4,:)=weight/sum(weight);
end
