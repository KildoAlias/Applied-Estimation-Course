% This function performs the maximum likelihood association and outlier detection given a single measurement.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z_i(t)              2X1
% Outputs: 
%           c(t)                1X1
%           outlier             1X1
%           nu^i(t)             2XN
%           S^i(t)              2X2XN
%           H^i(t)              2X3XN
function [c, outlier, nu, S, H] = associate(mu_bar, sigma_bar, z_i)

    % Import global variables
    global Q % measurement covariance matrix | 1X1
    global lambda_m % outlier detection threshold on mahalanobis distance | 1X1
    global map % map | 2Xn
    
    
    % YOUR IMPLEMENTATION %
    psi_max=0;
    d_min=999999;
    S=[];
    z_j=[];
    H=[];
    nu=[];
    outlier=0;
    psi=[];
    for j = 1:length(map)
        z_jt = observation_model(mu_bar, j);
        H_t = jacobian_observation_model(mu_bar, j, z_jt);
        S_t = H_t*sigma_bar*H_t' + Q;
        
        
        z_i(2)=mod(z_i(2)+pi,2*pi)-pi;
        z_jt(2)=mod(z_jt(2)+pi,2*pi)-pi;
        
        nu_t= z_i-z_jt;
        nu_t(2)=mod(nu_t(2)+pi,2*pi)-pi;
        temp=nu_t'/S_t;
        d=temp*nu_t;
        
        psi_t=(det(2*pi*S_t)^(-1/2)).*exp((-1/2*nu_t')*(S_t\nu_t));

        if d<d_min
            d_min=d;
        end
        
        
        if psi_t>psi_max
            psi_max=psi_t;
            c=j;
        end
        
        
        H(:,:,j)=H_t;
        S(:,:,j)=S_t;
        nu(:,j) = nu_t; 
%         psi=[psi,psi_t];
        
    end

    if d_min>lambda_m
        outlier=1;
    end
        

end