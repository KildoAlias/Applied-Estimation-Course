% This function performs the update process (sequential update).
% You need to make sure that the output sigma_bar is symmetric.
% The last line makes sure that ouput sigma_bar is always symmetric.
% Inputs:
%           mu_bar(t)       3X1
%           sigma_bar(t)    3X3
%           H_bar(t)        2nX3
%           Q_bar(t)		2nX2n
%           nu_bar(t)       2nX1
% Outputs:
%           mu(t)           3X1
%           sigma(t)        3X3
function [mu, sigma] = batch_update(mu_bar, sigma_bar, H_bar, Q_bar, nu_bar)

        mu_bar(3)=mod(mu_bar(3)+pi,2*pi)-pi;

        % YOUR IMPLEMENTATION %
        K=(sigma_bar*H_bar')/(H_bar*sigma_bar*H_bar'+Q_bar);
        mu=mu_bar+K*nu_bar;

        KH=K*H_bar;
        sz=size(KH);
        I=eye(sz(1),sz(2));
        sigma=(I-KH)*sigma_bar;
end
