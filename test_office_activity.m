function [probMatrix,testData,knnResult]=test_office_activity(testDataPerClass,svmModels, knnModels,numClasses,test_groundTruth)         
  %%
    % This code tests SVM and KNN models and returns the probMatrix, test Data and knn results
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
                errorRateTest=zeros(1,numClasses); 
                %gmmResultCell=cell(1,numClasses);   
                                           
                testData=cell2mat(testDataPerClass);
                testData=mapstd(testData);
                testData=transpose(testData);
                gTperClass=cell(1,numClasses);
                classTest=cell(1,numClasses);
                conMatTest=cell(1,numClasses);
                result=zeros(numClasses,1);
                probMatrix=zeros(size(testData,1),numClasses);
                for k=1:numClasses
                        %%%%  SVM TEST %%%%%%
                        %check if test observations for the following data
                        %exists, if not result=0, conmatest=zeros(2)
                     if((sum(test_groundTruth==k))==0)
                         conMatTest{k}=zeros(2);
                         result(k)=0;
                     else
                        gTperClass{k}=(test_groundTruth==k);
                        [~,prob] = predict(svmModels{k},testData); 
                        probMatrix(:,k)=prob(:,2);

                     end                    
                    
                     
                end % end of each class test
            
                    
                                            %%%%%%% KNN TEST %%%%%%%%%                                      
                       knnResult = predict(knnModels,testData); % testing of all data
                       knnConfusionMatrix=confusionmat(knnResult,test_groundTruth);

                    %find if there are nan in the prbMatrix and replace
                    %them with 0.
                     nanRows=(isnan(probMatrix(:,1)));
                     probMatrix(nanRows,:)=0.001;
                                          
%                      [~,maxfinalProbMatrix]=max(probMatrix,[],2);

          
       
end
        