% This function performs the maximum likelihood association and outlier detection.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z(t)                2Xn
% Outputs: 
%           c(t)                1Xn
%           outlier             1Xn
%           nu_bar(t)           2nX1
%           H_bar(t)            2nX3
function [c, outlier, nu_bar, H_bar] = batch_associate(mu_bar, sigma_bar, z)

        mu_bar(3)=mod(mu_bar(3)+pi,2*pi)-pi;
        
        % YOUR IMPLEMENTATION %
        sz=size(z);
        n=sz(2);
        c=zeros(1,n);
        outlier=zeros(1,n);
        nu_bar=zeros(2,n);
        H_bar=zeros(1, 2*n*3);
        
        for i= 1:n
            j=(i*6)-5;
            
            z_i=z(:,i);
            [c_t,outlier_t, nu, S, H] = associate(mu_bar, sigma_bar, z_i);          
            H_t=H(:,:,c_t);
            
            
            nu_t=nu(:,c_t);
            
            c(:,i)=c_t;            
            outlier(:,i)=outlier_t;
            nu_bar(:,i)=nu_t;
            H_bar(j:j+5)=reshape(H_t',1,6);
   
            
        end
        nu_bar=nu_bar(:);
        H_bar=reshape(H_bar,3,2*n)';
            
end