function centroid_computation_office() 
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

    %add videos file path
    videoPath='/home/nafkote/Desktop/Matlab_practice/data/office_activities/';
    addpath(videoPath)
    videos= dir(strcat(videoPath,'*.MP4'));
    videos={videos.name};
    numVideos=length(videos)
    load('gt_office.mat')
    numSubjects=numVideos;

    whole_data_centroid=cell(1,numSubjects);

    for sub=1:numSubjects

        numSegments=length(gt_office.(strcat('subject',num2str(sub))).start_time);
        whole_data_centroid{sub}=cell(1,numSegments);
        vidObj=VideoReader(videos{sub});
        frameRate=vidObj.FrameRate;

        for segm=1:numSegments
            sprintf('subjet %d, segment %d',sub, segm)
            startFrame=ceil(frameRate*gt_office.(strcat('subject',num2str(sub))).start_time(segm)/1000);
            stopFrame=floor(frameRate*gt_office.(strcat('subject',num2str(sub))).final_time(segm)/1000);
            numFrames=stopFrame-startFrame+1;

            centroidsVideo=zeros(2,numFrames); 
            ind=1;
            for frameNum=startFrame:stopFrame            
                videoFrame=read(vidObj,frameNum);
                centroidsVideo(:,ind)=image_moments(rgb2gray(videoFrame));
               ind=ind+1;

            end%end of frameNum
            whole_data_centroid{sub}{segm}=centroidsVideo;


        end

    end

    % %save the cell of histVideoCell
     save('whole_data_centroid.mat','whole_data_centroid');

 end
