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

 
% This code loads (extracts) optical flow-based and centroid-based features from
% video segments and performd office activity recognition in first-person vision 

%% Clear
dbstop if error
clear all; close all; clc;


%%Add path
      
%%Load the ground truth      
load gt_office;
numSubjects=9;
whole_office_data_label=cell(1,numSubjects);
for sub=1:numSubjects
   whole_office_data_label{sub}=transpose(gt_office.(strcat('subject',num2str(sub))).label);
end

%Classes are in the order of activities
classes= unique([whole_office_data_label{:}]);
numClasses=length(classes); 

 numIt=1
 overlapR=0.5%0.1:0.1:0.9
 numBins=36 %number of quantisation bins
 gridL=20 %number of grids in each direction
 nFbands=5:5:50 ;
 nframes=95%wLength;
 feat={'mi','Ma','med','en', 'kur','zeroCrossing','meanVec','stdVec','tempWindowFFTF'};
 matFile=[];
%% Select feature types to use and 

goff=1
vif=1

numClusters=10;
maxIter=500;
numIte=1;
ovo=0

domain='time';
numLevels=2;


%% Extract (Load) grid optical flow-based features

%Grid optical flow computation/ load
if~exist('whole_data_grid_OF.mat')
    %Get the grid optical flow
    GOF_computation_office();
else
    load('whole_data_grid_OF.mat');
end



%Extract grid-based optical flow features
if~exist('whole_office_goff.mat')
    goff_feature_extraction(whole_data_grid_OF,nframes,overlapR,numBins);
end

load('whole_office_goff.mat');



%% Extract (Load) centroid-based virtual-inertial features

%Check if the centroid data exist else compute
if~exist('whole_data_centroid.mat')
    %Get the grid optical flow
    centroid_computation_office();
end
load('whole_data_centroid.mat');

%Extract the virtual inertial features from the centroid data
%centroid method
if ~exist('whole_office_vif.mat')
    virtual_inertial_feature_extraction(whole_data_centroid,nframes,overlapR);
end
load('whole_office_vif.mat');



%% Cocatenate grid-optical flow and centroid-based virtual inertial features
%merge centroid and grid OF
numSubjects=length(whole_office_vif);%alread
whole_office_all_features=cell(1,numSubjects);
for sub=1:9%numSubjects
    numSegments=length(whole_office_goff{sub});%number of segments in a video             
    whole_office_all_features{sub}=cell(1,numSegments);
    for seg=1:numSegments
        %synchrnoise when different samples exist per segment
        intColum=min(size(whole_office_goff{sub}{seg},2),...
            size(whole_office_vif{sub}{seg},2));
        whole_office_all_features{sub}{seg}=[whole_office_goff{sub}{seg}(:,1:intColum);...
            whole_office_vif{sub}{seg}(:,1:intColum)];
    end
end            


%% Train and test
[test_ground_result]=arrange_train_test_office(...
                    whole_office_all_features,whole_office_data_label, classes,numIt,ovo);

%SVM classificaiton results
svm_test_label=[];
for i=1:numSubjects
    svm_test_label=[svm_test_label,test_ground_result{i}(1,:)];
end

%KNN classificaiton results
knn_test_label=[];
for i=1:numSubjects
    knn_test_label=[knn_test_label,test_ground_result{i}(2,:)];
end

%Ground truth labels
gt_test_label=[];
for i=1:numSubjects
    gt_test_label=[gt_test_label,test_ground_result{i}(3,:)];
end
%% Accuracy per subject for both SVM and KNN classifiers
accuracyPerSubject=zeros(numSubjects,22);% numClases(20)+[svm,knn] for each subject
for i=1:numSubjects

    for c=1:numClasses

        t=find(test_ground_result{i}(1,:)==c);
        g=find(test_ground_result{i}(3,:)==c);
        if (~isempty(g))
            accuracyPerSubject(i,c)=round(length(intersect(t,g)*100/length(g)));
        else
            accuracyPerSubject(i,c)=nan;
        end

    end
    accuracyPerSubject(i,21:22)=round([sum(test_ground_result{i}(1,:)==test_ground_result{i}(3,:)),sum(test_ground_result{i}(2,:)==test_ground_result{i}(3,:))]*100/length(test_ground_result{i}(3,:)));
end

%% Compute confusion matrices
svmConf=confusionmat(svm_test_label,gt_test_label)
knnConf=confusionmat(knn_test_label,gt_test_label)
sum(diag(svmConf))/sum(svmConf(:))
bsxfun(@rdivide,diag(svmConf)',sum(svmConf))
mean(bsxfun(@rdivide,diag(svmConf)',sum(svmConf)))
sum(diag(knnConf))/sum(knnConf(:))
bsxfun(@rdivide,diag(knnConf)',sum(knnConf))
mean(bsxfun(@rdivide,diag(knnConf)',sum(knnConf)))

%% Display results
round(normc(svmConf)*100)
round(normc(knnConf)*100)
figure;imagesc(normc(svmConf))
c=colorbar
c.Label.String='Accuracy'
figure;imagesc(normc(knnConf))
colorbar('Ticks',[1:20],...
         'TickLabels',classes)
c=colorbar
c.Label.String='Accuracy'
