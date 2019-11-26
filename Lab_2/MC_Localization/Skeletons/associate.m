% This function performs the ML data association
%           S_bar(t)                 4XM
%           z(t)                     2Xn
%           association_ground_truth 1Xn | ground truth landmark ID for
%           every measurement
% Outputs: 
%           outlier                  1Xn
%           Psi(t)                   1XnXM

% Matrix pre-def

function [outlier, Psi, c] = associate(S_bar, z, association_ground_truth)
    if nargin < 3
        association_ground_truth = [];
    end

    global DATA_ASSOCIATION % wheter to perform data association or use ground truth
    global lambda_psi % threshold on average likelihood for outlier detection
    global Q % covariance matrix of the measurement model
    global M % number of particles
    global N % number of landmarks
    global landmark_ids % unique landmark IDs
    
    % YOUR IMPLEMENTATION
    
    
    sz=size(z);
    Psi=zeros(1,sz(2),M);
    psi_k=zeros(M,N);
    z(2)=mod(z(2)+pi,2*pi)-pi;
    outlier=zeros(1,sz(2));
    c=zeros(1,sz(2),M);
    for i=1:sz(2)
            for k=1:N
                z_t=observation_model(S_bar,k);
                nu_t= z(:,i)-z_t;
                nu_t(2,:)=mod(nu_t(2,:)+pi,2*pi)-pi;
                psi=(1/(2*pi*det(Q)^(0.5)))*exp(-(1/2)*nu_t'/(Q)*nu_t);
                psi=diag(psi);
                psi_k(:,k)=psi;
            end
        [maximum_k,index]=max(psi_k,[],2);
        c(1,i,:)=index;
        Psi(1,i,:)=maximum_k;
        outlier(1,i)=(1/M)*sum(maximum_k) <= lambda_psi;
    end
    if DATA_ASSOCIATION=="Off"
        c(1,:,1)=association_ground_truth;
    end
end

