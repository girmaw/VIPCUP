
function [svmModels,knnModels,testDataPerClass,trainDataPerClass,trainData] = train_office_activity(testDataset,whole_office_hist_window,...
                                whole_office_hist_window_label,classes)
     
    %%
    % This code train SVM and KNN classifiers and returns the models.
    % Author: Girmaw Abebe
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


     
     %% Start      
           
            numSubjects=length(whole_office_hist_window);


            if (testDataset <=numSubjects)
                whole_train_data=cell2mat([whole_office_hist_window{setdiff(1:numSubjects,testDataset)}]);
                whole_test_data=cell2mat(whole_office_hist_window{testDataset});
                train_class_label={};
                for i=setdiff(1:numSubjects,testDataset)
                train_class_label=[train_class_label,[whole_office_hist_window_label{i}{:}]];
                end
                test_class_label=[whole_office_hist_window_label{testDataset}{:}];
   

            elseif (testDataset ==numSubjects+1) 
                display('--------------')
                display('All data used for training')
                display('----------------')
                
                
                whole_train_data=cell2mat([whole_office_hist_window{setdiff(1:numSubjects,testDataset)}]);
                whole_test_data= whole_train_data;
                train_class_label={};
                for i=setdiff(1:numSubjects,testDataset)
                train_class_label=[train_class_label,[whole_office_hist_window_label{i}{:}]];
                end
                test_class_label=train_class_label;
                   
            end
            
            
            numClasses=length(classes);            
            trainDataPerClass=cell(1,numClasses);
            testDataPerClass=cell(1,numClasses);
            
             %extract train and test data for each class              
             for k=1:numClasses
                classInd=find(strcmp(train_class_label, classes(k)));%indices of the given class
                trainDataPerClass{k}=whole_train_data(:,classInd); % get the right index in the whole mat file
                classInd=find(strcmp(test_class_label, classes(k)));%indices of the given class
                testDataPerClass{k}=whole_test_data(:,classInd);
             end
   
            %train data        
            trainData=cell2mat(trainDataPerClass); %whole data        
          
            %Whole normalizatoin
             [trainData,normSett]=mapstd(trainData);
             trainData=transpose(trainData);
          
%             pc=pca(trainData);
%             trainData=trainData*pc(:,1:50);
            display('training ...........')
            

            %groundTruth
            train_groundTruth=[];
            for cl=1:numClasses
               train_groundTruth=[train_groundTruth; cl*ones(size(trainDataPerClass{cl},2),1)];
            end


           % build models
                %initialize performance matrices
                %errorRateTrain=zeros(1,numClasses);
                gTperClass=cell(1,numClasses);
                %classTrain=cell(1,numClasses);
                %conMatTrain=cell(1,numClasses);
                svmModels=cell(1,numClasses);
                gmmModels=cell(1,numClasses);
                %P=cell(1,numClasses); % cross validation examples for test use later
                for k=1:numClasses
                    %Vectorized statement that binarizes Group
                    %where 1 is the current class and 0 is all other classes 
                    
                    %%%%%% SVM     %%%%%%%%%%%%%%%%%%%%%%%%%
                    gTperClass{k}=(train_groundTruth==k); %changes to discret and continuous dataset
                    svmModels{k} = fitcsvm(trainData,gTperClass{k},'KernelFunction','polynomial',...
                'KernelScale','auto');
            %svmtrain(double(data(P{k}.training,:)),gTperClass{k}(P{k}.training),'kernel_function',...
             %           'polynomial','polyorder',15,'method','ls');
             
                               
%                    %%%%%% GMM %%%%%%%%%%%%%%%%%%%%%%%%
%                    num_components=10;
%                    options = statset('MaxIter',200);            
%                    gmmModels{k}=gmdistribution.fit(transpose(trainDataPerClass{k}), num_components, ...
%                          'CovType', 'diagonal','Regularize', 1e-6, 'Options', options); % X= #samples X features   
                     
                   %KNN doesn't need to be insdie the loop as it requres only the
                   %whole data and the groundtruth                   


                end
                
                                    %%%%%%%%%%% KNN %%%%%%%%%%%%%%%%%%%%%%
                     
                     knnModels=fitcknn(trainData,train_groundTruth);
%                      knnModels=fitNaiveBayes(trainData,train_groundTruth,'dist',repmat({'kernel'},1,size(trainData,2)));
%                     knnModels=fitcknn(trainData,train_groundTruth,'NSMethod','exhaustive',...
%                       'Distance','cosine','NumNeighbors',1); %more advanced distance measure

%                    rloss = resubLoss(knnModels); %resubstitution loss, which, by default, is the fraction of misclassifications from the predictions of mdl
%                    %rng('default')
%                    %cvmdl = crossval(knnModel,'kfold',5);%Construct a cross-validated classifier from the model.
%                    cvmdl = crossval(knnModels);
%                    kloss = kfoldLoss(cvmdl); %cross-validation loss, which is the average loss of each cross-validation model when predicting on data that is not used for training.
end