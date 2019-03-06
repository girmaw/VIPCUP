 function whole_basketball_hist_hog=proposed_overfeat(numLevels,whole_basketball_data,nframes,overlapR,pot,domain)       
       
       
%          
            numSubjects=length(whole_basketball_data);

            
               
            %Windowed data extraction
             fil2=fspecial('gaussian',3,0.5); %incase filtering is necessary
             whole_basketball_hist_hog=cell(1,numSubjects);
            for subject=1:numSubjects
                numSegments=length(whole_basketball_data{subject});%number of segments in a video
                %segmentHistCell=cell(1,numSegments);
             
                for segment=1:numSegments
                    c=1;%first column
                    numColumns=size(whole_basketball_data{subject}{segment},2);%num of cols of a segment
                    numColumns=numColumns-1;
                    for col=1:floor(nframes*overlapR):numColumns-1
                        if (((numColumns - col)> 0.5*nframes)||col==1)
                            initialBoundry=col;
                            
                            if (col+nframes>numColumns) 
                                
                                columnBoundry=numColumns;
                            else
                                columnBoundry=col+nframes-1;
                            end
                            temph=whole_basketball_data{subject}{segment}(:,initialBoundry:columnBoundry);                
                            if (pot)
                           %pooling
                            %max
                            %decompose into the number of smaller
                                      %bands
                              
                              numFrames= size(temph,2);       
                              bufferedSeq=buffer(1:numFrames,floor(numFrames/numLevels));
                              bufferedSeq=bufferedSeq(:,1:numLevels);
                              final_overfeat=[];
                                for level=1:numLevels
    %                                 for m=1:level
    %                                     temphDecimate=temph(:,1:2:end);
    %                                     
    %                                 end
%                                     %decimate for the number of levels
%                                     decimated=arrayfun(@(x) (decimateCalc(temph(x,:),2^(level-1))),1:size(temph,1),'UniformOutput',false);
%                                     temphDecimate=cell2mat(transpose(decimated));
                                        

                                     temphDecimate=temph(:,bufferedSeq(:,level));


    %                                 for feat=1:size(temph,1)
    %                                     temphDecimate(feat,:)=decimate(temph(feat,:),2^(level-1));
    %                                 end
                                    if (strcmp(domain,'frequency'))
                                        temphDecimate=transpose(fft(transpose(temphDecimate)));
                                        temphDecimate=abs(temphDecimate(:,1:floor(size(temphDecimate,2)/2)));
                                        %temphDecimate=temphDecimate(:,1:10);
                                    end
                                    maxTemp=max(temphDecimate,[],2);
                                    sumTemp=sum(temphDecimate,2);
                                    hisPool=zeros(size(temphDecimate,1),2);
                                    for tempr=1:size(temphDecimate,1)
                                        hisPool(tempr,:)=[sum(diff(temphDecimate(tempr,:))>0),sum(diff(temphDecimate(tempr,:))<0)];

                                    end
                                    sumPool=zeros(size(temphDecimate,1),2);
                                    for tempr=1:size(temphDecimate,1)
                                        difference=diff(temphDecimate(tempr,:));
                                        sumPool(tempr,:)=[sum(difference(difference>0)),sum(difference(difference<0))];

                                    end
                                   overfeat=[maxTemp;sumTemp;hisPool(:);sumPool(:)];%%sum(temph,2)/size(temph,2);
                                   final_overfeat=[final_overfeat;overfeat];
                                end

                               %hog_hist=bsxfun(@rdivide,temph,sum(temph));
                               %hog_hist=sum(temph,2)/size(temph,2);

                               whole_basketball_hist_hog{subject}{segment}(:,c)= final_overfeat;%hog_hist;
                            else
                                whole_basketball_hist_hog{subject}{segment}(:,c)=sum(temph,2)/size(temph,2);
                            end
 
                           c=c+1; % increase the number of columns
                        end
                    end%for each windowed column
                    

                end % for each segment
               
            end%for each subject
    end % end of proposed function