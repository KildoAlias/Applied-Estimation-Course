clc
%clear all
%close all

%Parameters for CV
    scale_factor=0.2; %rescaling of video
    rate=2;  %sample rate of videos i.e each frame or i:th frame
    histheight=60; % Size of sliding histogram window
    histwidth=60;
    greyscale_threshold=110; %threshold for setting likely values
    
%Parameters for tracking
    M=1000; % Particles 
    Q=[200,0;0,200]; %Measurement noise
    R=[100,0;0,100]; %Process noise
    outlier_threshold= 0.00001; 
    Resample_mode=2; % 1 for multinomial, 2 for systematic
    

refimage=imread("refcola.jpg"); %ref image 
refimage=rgb2gray(refimage);                    % turn it grey
refimage=imresize(refimage, scale_factor); % resize


v = VideoReader("video-1575970356.mp4"); % read video


[H,W,videoframes,colorframes]=get_videoframes(v,scale_factor, rate); %get all videoframes

S_bar(1,:)=randi([1,H],1,M);    %Initializing S_bar
S_bar(2,:)=randi([1,W],1,M);
S_bar(3,:)=1/M;

%figure()
k=1;
disp('Starting object detection and tracking...')
for i=1:length(videoframes)   %For each videoframe
    
    
    [fullimageidx,~,best_image_histo]=slidinghisto(videoframes{i},refimage,histwidth,histheight); % Get best part of image that resulted in best match
    best_image=threshold_likely_pixels(best_image_histo,greyscale_threshold); %set likely pixels
    measurement=masscentre(best_image); % get masscentre
    measurement(1)=fullimageidx(1)+measurement(1);
    measurement(2)=fullimageidx(2)+measurement(2);
    
    
    disp(['Frame: ',num2str(i)])
    S_bar=predict(S_bar, R, M );
    S_bar=weight(S_bar, measurement',Q,outlier_threshold);
    
    switch Resample_mode
        case 1
            S_bar=multinomial_resample(S_bar,M);
            
        case 2
           S_bar= systematic_resample(S_bar,M);
    end
           
     Prediction=round(mean(S_bar(1:2,:),2));
     

     hold off
     imshow(colorframes{i})
     hold on
     scatter(S_bar(2,:),S_bar(1,:),5,"filled")
     plot(Prediction(2),Prediction(1),'g+','MarkerSize',15,'LineWidth',2)
    if isnan(measurement)~=1    
        x=measurement(1);
        y=measurement(2);
        pointer_pos{k}=[y,x];
        imagge{k}=videoframes{i};
        hold on
        plot(y,x,'r.','MarkerSize',15,'LineWidth',2)
        title('Object detected!, tracking...')
        k=k+1;
    else
        title('No object detected')
    end
    pause(0.0001)

end
title('No more frames, tracking done!')
disp('No more frames, tracking done!')


