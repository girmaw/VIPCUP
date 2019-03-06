function [meanPerf,final_svm_conf_matrix, final_knn_conf_matrix]=arrange_train_test_result(whole_basketball_hist_window,whole_basketball_data_label, classes,numIt,ovo)
      %Prepare the label for the windowed samples, if a segment was
                %initially class x, its windowed samples also labelled as class
                %x.
                numSubjects=length(whole_basketball_hist_window);
                numClasses=length(classes);
                whole_basketball_hist_window_final=whole_basketball_hist_window;
                whole_basketball_hist_window_final_label=cell(1,numSubjects);
                for subject=1:numSubjects
                    numSegments=length(whole_basketball_hist_window_final{subject});%number of segments in a video
                    segmentWindowLabelCell=cell(1,numSegments);             
                    for segment=1:numSegments
                        segmentLabel=whole_basketball_data_label{subject}{segment};
                        segmentWindowLabelCell{segment}=repmat({segmentLabel},[1, size(whole_basketball_hist_window_final{subject}{segment},2)]);
                    end
                    whole_basketball_hist_window_final_label{subject}=segmentWindowLabelCell;
                end

             datasetCombination=1:numSubjects;
             performance_matrix=cell(1,length(datasetCombination));
             performance=zeros(numSubjects,6);%becomes 6 when knn is included
             svm_conf_matrix=cell(1,length(datasetCombination));
             knn_conf_matrix=cell(1,length(datasetCombination));
             leaveOneOut_finalResult=zeros(length(datasetCombination),6);% 6 are normacc, pr, rec, spec,fscore,and knn
            for testDataset=1:length(datasetCombination); % select the test dataset
                sprintf('Subject : %d',testDataset)
                performanceMSum=zeros(numClasses,4);%norm acc, pr, rec, spe,
                svmConfSum=zeros(numClasses);
                knnConfSum=zeros(numClasses);

                for ite=1:numIt

                    %Train the models            
                     [svmModels,knnModels,testDataPerClass,trainDataPerClass,trainData] = train_office_overfeat(testDataset,whole_basketball_hist_window_final,...
                                        whole_basketball_hist_window_final_label,classes);

                    %groundTruth
                    train_groundTruth=[];
                    for cl=1:numClasses
                       train_groundTruth=[train_groundTruth; cl*ones(size(trainDataPerClass{cl},2),1)];
                    end   
                    
                    %test
                    display('testing...........')
                    [probMatrix,test_groundTruth,testData,knnResult]=test_svm_knn_overfeat(testDataPerClass,svmModels, knnModels,numClasses);         

                    [~,svm_class_label]=max(transpose(probMatrix));
                    
                    knn_class_label=knnResult';
                    
                    if(ovo)
                        %OVO
                        limitedFeatures=1:size(whole_basketball_hist_window_final{1}{1},1);%1:243;
                        ovoClCell=cell(numClasses,numClasses);
                        for svmC=1:numClasses

                            for confC=setdiff(1:numClasses,svmC)
                                svmClData=trainData(train_groundTruth==svmC,:);
                                knnClData=trainData(train_groundTruth==confC,:);
                                tempData=[svmClData;knnClData];
                                tempLabel=[ones(1,size(svmClData,1)),zeros(1,size(knnClData,1))];
%                                 ovoClCell{svmC,confC}=fitcsvm(tempData,tempLabel,'KernelFunction','polynomial',...
%                                 'KernelScale','auto');
                                ovoClCell{svmC,confC}=fitcdiscr(tempData(:,limitedFeatures),tempLabel,'discrimType', 'pseudoLinear');

                            end

                        end
                        [svm_class_label_new,knn_class_label_new]=ovoClassify(ovoClCell,testData(:,limitedFeatures),svm_class_label,knn_class_label);  

                        knn_class_label=knn_class_label_new;
                        svm_class_label=svm_class_label_new;

                    end

                    %-----------------------------------------------------------------

                    knnConf=confusionmat(knn_class_label,test_groundTruth);
                    svmConf=confusionmat(svm_class_label,test_groundTruth);
                     %------------------------------------------------------------------              

                     %performanceMSum=performanceMSum+performanceM;
                     svmConfSum=svmConfSum+svmConf;
                     knnConfSum=knnConfSum+knnConf;
                     prec=zeros(numClasses,1);
                     rec=zeros(numClasses,1);
                     spec=zeros(numClasses,1);
                     normAcc=zeros(numClasses,1);
                     fscore=zeros(numClasses,1);
                     for ncl=1:numClasses
                         clI=find(test_groundTruth==ncl);
                         tpAfn=length(clI);
                         tp=sum(svm_class_label(clI)==ncl);
                         if(tp==0)
                             tp=0.001;
                         end
                         fn=tpAfn-tp;
                         fpI=setdiff(1:length(svm_class_label),clI);
                         fp=sum(svm_class_label(fpI)==ncl);
                         prec(ncl)=tp/(tp+fp);
                         rec(ncl)=tp/(tpAfn);
                         tn=length(test_groundTruth)-tpAfn-fp;
                         spec(ncl)=tn/(tn+fp);
                         normAcc(ncl)=(tp+tn)/(tp+tn+fp+fn);
                         fscore(ncl)=2*prec(ncl)*rec(ncl)/(prec(ncl)+rec(ncl));
                     end
    %                  save(strcat('probMatrix_test_',num2str(testDataset),'.mat'),'probMatrix');%save for hmm test later
    %                  save(strcat('test_groundTruth_',num2str(testDataset),'.mat'),'test_groundTruth');%save for hmm test later
    %                  save(strcat('testData_',num2str(testDataset),'.mat'),'testData');

                end
                performance(testDataset,:)=[mean(normAcc),mean(prec),mean(rec),mean(spec), mean(fscore),sum(diag(knnConf))/sum(knnConf(:))];
    %              performance_matrix{testDataset}=performanceMSum/numIt;f
                 svm_conf_matrix{testDataset}=svmConfSum/numIt;
                 knn_conf_matrix{testDataset}=knnConfSum/numIt;
    %              knnAcc=round(100*(sum(diag(knn_conf_matrix{testDataset}))/sum(knn_conf_matrix{testDataset}(:))));

            end % end of testDataset in the leaveOneOut experiment


        disp('Per each subject')
        performance

        meanPerf=mean(performance);
        meanPerf(5)=2*meanPerf(2)*meanPerf(3)/(meanPerf(2)+meanPerf(3));

         final_svm_conf_matrix=zeros(numClasses);
         final_knn_conf_matrix=zeros(numClasses);
         for subject=1:numSubjects
             final_svm_conf_matrix=final_svm_conf_matrix+svm_conf_matrix{subject};%+svm_conf_matrix{2}+svm_conf_matrix{3}+svm_conf_matrix{4})/4);
             %display('knn confmatrix')
             final_knn_conf_matrix=final_knn_conf_matrix+knn_conf_matrix{subject};%+knn_conf_matrix{2}+knn_conf_matrix{3}+knn_conf_matrix{4})/4);
         end
        final_svm_conf_matrix=round(final_svm_conf_matrix/numSubjects);
        final_knn_conf_matrix=round(final_knn_conf_matrix/numSubjects);
         disp('Confusion matrix accuracy')
        final_knn_conf_matrix;
        meanPerf(5)=2*meanPerf(2)*meanPerf(3)/(meanPerf(2)+meanPerf(3))
        (diag(final_knn_conf_matrix)'./sum(final_knn_conf_matrix))
        sum(diag(final_knn_conf_matrix)'./sum(final_knn_conf_matrix(:)))

end