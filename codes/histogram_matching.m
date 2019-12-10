function [costvalue,costs]=histogram_matching(partim,refhist3D,weights) 
% histogram_matching(hist,refhist,thresholdfunction,threshold)
%
% Performes histogram matching by taking the minimum sliding difference
% between a histogram ("hist") and a reference histogram ("refhist").
% Returns a costvalue that represents the correlation (0 for identical histograms, 1 for completely different)
%
    [~,~,D]=size(partim);
    cost=ones(1,D)*inf;
    for d=1:D
        hist=imhist(partim(:,:,d));
        refhist=(refhist3D(:,:,d));

        
        % Normalize histograms
        refhist=refhist/sum(refhist);
        hist=hist/sum(hist);
    
        % Initilizing costs vector
        costs=ones(1,(length(hist)-1))*inf;
        diff=abs(hist-refhist);
        % divide by 2 to get normalization (two histograms)
        cost(d)=(sum(diff)/2)./weights(d);
        
        % Returns minimum cost value of histograms (least difference between histograms)
        
    end
    costvalue=sum(cost);%*colorweight;
end