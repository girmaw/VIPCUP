
function GOF_computation_office()
    %% Author: Girmaw Abebe
    % Date: March, 2015
    % Go through ReadMe.doc and License.doc files before using the software.
    %
    % Requested citation acknowledgement when using this software:
    %
    % Girmaw Abebe, Andrea Cavallaro and Xavier Parra, "Robust multi-dimensional motion features for first-person vision activity recognition", 
    %    Computer Vision and Image Understanding, Vol. 149,  2016, pp. 229-248
    %
    % Girmaw Abebe and Andrea Cavallaro, "Hierarchical modeling for first-person vision activity recognition", 
    %    Neurocomputing, Vol. 267, 2017, pp. 362-377 


    % This code extracts Horn and schunk optical flow, particularly, grid
    % optical flow from video segments of office activity in the dataset


    %Begin parallel computing
    %matlabpool('open',4);
    %clear; clc; close all; 

    %Add videos file path, and get the list of videos
    videoPath='Path to videos ../office_activities/';
    addpath(videoPath)
    videos= dir(strcat(videoPath,'*.MP4'));
    videos={videos.name};
    numVideos=length(videos)
    load('gt_office.mat')
    numSubjects=numVideos;

    %Set the format of optical flow vector per pixel
    optical = vision.OpticalFlow(...
            'OutputValue', 'Horizontal and vertical components in complex form');
    %Set the number of grids per each axis
    gridL=20;

    whole_data_grid_OF=cell(1,numSubjects);

    for sub=1:numSubjects

        numSegments=length(gt_office.(strcat('subject',num2str(sub))).start_time);
        whole_data_grid_OF{sub}=cell(1,numSegments);
        vidObj=VideoReader(videos{sub});
        frameRate=vidObj.FrameRate;
        maxHeight=vidObj.Height;
        maxWidth=vidObj.Width;
        r = 1:floor(maxHeight/gridL):maxHeight;
        c = 1:floor(maxWidth/gridL):maxWidth; 

        %For each segment, get the start and stop times in the continous video
        for segm=1:numSegments
            sprintf('subjet %d, segment %d',sub, segm)
            startFrame=ceil(frameRate*gt_office.(strcat('subject',num2str(sub))).start_time(segm)/1000);
            stopFrame=floor(frameRate*gt_office.(strcat('subject',num2str(sub))).final_time(segm)/1000);
            numFrames=stopFrame-startFrame+1;
            %Compare the dense and grid optical flow for each frame
            gridOF=zeros(gridL^2,numFrames);
            ind=1;

            %Compute the optical flow per frame and take the grids
            for frameNum=startFrame:stopFrame            
                videoFrame=read(vidObj,frameNum);
                optFlow=step(optical,single(rgb2gray(videoFrame)));                  
                gridOF(:,ind) = reshape(optFlow(r,c),length(r)*length(c),1);
               ind=ind+1;

            end%end of frameNum
            whole_data_grid_OF{sub}{segm}=gridOF;          


        end

    end

    %Save the extracted grid optical flow for featur extraction
    save('whole_data_grid_OF.mat','whole_data_grid_OF');
end
