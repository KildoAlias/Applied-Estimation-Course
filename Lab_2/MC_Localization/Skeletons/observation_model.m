% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           S(t)                           4XM
%           j                              1X1
% Outputs:  
%           h                              2XM
function z_j = observation_model(S, j)

    global map % map including the coordinates of all landmarks | shape 2Xn for n landmarks
    global M % number of particles

    % YOUR IMPLEMENTATION
    h1=sqrt(((map(1,j)-S(1,:)).^2)+(map(2,j)-S(2,:)).^2);
    angle=atan2(map(2,j)-S(2,:),map(1,j)-S(1,:))-S(3,:);
    h2=mod(angle+pi,2*pi)-pi; % To set in range of -pi to pi
    z_j=[h1;h2];

end