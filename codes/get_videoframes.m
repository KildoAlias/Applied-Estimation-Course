function [H,W,videoframes,videoframe_color] = get_videoframes(v, scale_factor, rate)
if nargin < 3
    rate=1;
end

numberofframes=v.NumberOfFrames-2;  
Totalframes=floor(numberofframes/rate);
mov=cell(Totalframes,1);

k=1;
for i=1:rate:numberofframes
    
    videoframe=read(v,i);
    videoframe_c=imresize(videoframe, scale_factor);
    videoframe_color{k}=videoframe_c;
    
    image=rgb2gray(videoframe_c); 
    mov{k}=image;
    
    k=k+1;
end

videoframes=mov;
[H,W]=size(videoframes{1});


end
