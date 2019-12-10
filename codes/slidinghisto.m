function [min_h,costmap,I] = slidinghisto(image,refhist_v,histwidth,histheight,weights)
% slidinghisto(image,refimage,histwidth,histheight)
%
% Input: Frame, reference frame, width of histogram window and height of
% histogram window
% Output: y,x coordinates in min_h where the best matching histogram is,
% costmap where all values of the difference of histograms are stored and
% I, an image of the same index as the best matching histogram.

[H,W,D]=size(image);
cost=ones(1,D);
costmap=ones(H-histheight,W-histwidth);
for i=1:H-histheight
   
    for j=1:W-histwidth
        partimage=(image(i:histheight+i,j:histwidth+j,:));
        costmap(i,j)=histogram_matching(partimage,refhist_v,weights);
    end
end
minimum_value=min(min(costmap));
[x,y]=find(costmap==minimum_value,1);

min_h(1)=x;
min_h(2)=y;
I=image(min_h(1):min_h(1)+histheight,min_h(2):min_h(2)+histwidth);               
end