 function goff_feature_extraction(whole_basketball_data,nframes,overlapR,numBins)       
 
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

    % This code extracts centroid-based features from video segments for office activity recognition in first-person vision 



    %% Histogram computation: compute for each frame in each segment of each subject  
    %Angle bins
    nbins=numBins;%72;
    bins=linspace(-pi,pi,nbins);
    %Magnitude bins
    nMbins=15;%30
    mbins=linspace(0,1,nMbins);
    numSubjects=length(whole_basketball_data);

    whole_basketball_hist=cell(1,numSubjects);
    whole_basketball_histAbs=cell(1,numSubjects);
    fil1=fspecial('gaussian',7,1); %incase filtering is necessary
    for subject=1:numSubjects
        numSegments=length(whole_basketball_data{subject});%number of segments in a video
        segmentHistCell=cell(1,numSegments);
        segmentHistCellAbs=cell(1,numSegments);
        for segment=1:numSegments
            %segmentAngle=angle(filter2(fil1,whole_basketball_data{subject}{segment},'same'));
            segmentAngle=angle(whole_basketball_data{subject}{segment});
            segmentAbs=abs(whole_basketball_data{subject}{segment});
            %tempAbs{subject}{segment}=segmentAbs;
            %tempAngle{subject}{segment}=segmentAngle;
            segmentHistCellAbs{segment}=hist(filter2(fil1,segmentAbs,'same'), mbins);
            segmentHistCell{segment}=hist(segmentAngle,bins);
           %UVtotalHistCell{vid}=[hist(UVtotalCellAngle,bins);min(UVtotalCell{vid});max(UVtotalCell{vid});mean(UVtotalCell{vid});std(UVtotalCell{vid});sqrt(sum(UVtotalCell{vid}.^2))];

        end
        whole_basketball_hist{subject}=segmentHistCell;
        whole_basketball_histAbs{subject}=segmentHistCellAbs;
    end

    %% Windowed data extraction
     fil2=fspecial('gaussian',3,0.5); %incase filtering is necessary
     whole_office_goff=cell(1,numSubjects);
    for subject=1:numSubjects
        numSegments=length(whole_basketball_hist{subject});%number of segments in a video
        %segmentHistCell=cell(1,numSegments);

        for segment=1:numSegments
            c=1;%first column
            numColumns=size(whole_basketball_hist{subject}{segment},2);%num of cols of a segment
            numColumns=numColumns-1;
            for col=1:floor(nframes*overlapR):numColumns-1
                if (col+nframes>numColumns) % check j+nframes is not above the number of columns already availab
                    columnBoundry=numColumns;%CellAverageSum{i}(:,c)=sum(UVtotalHistCell{i}(:,j:numColumns),2);
                    if (columnBoundry - nframes)>=1

                        initialBoundry=columnBoundry - nframes;       


                    elseif(((numColumns - col)> nframes/2)||col==1) %if it gets to negative when columnBoundry - nframes 
                       initialBoundry=col;      

                    end
                 temph=whole_basketball_hist{subject}{segment}(:,initialBoundry:columnBoundry);                
                 %replicate the available segment
                 temph=repmat(temph,1,ceil(nframes/(size(temph,2)-1)));
                 temph= temph(:,1:nframes+1); 


                else
                    columnBoundry=col+nframes;
                    initialBoundry=col;
                 %then
                temph=whole_basketball_hist{subject}{segment}(:,initialBoundry:columnBoundry);              
                end


                %tempfftTF:Compute fft of each bin across time
                tempf=temph;%on temph, %=whole_basketball_data{subject}{segment}(:,initialBoundry:columnBoundry);
                tempfftT = zeros(size(tempf));

                for tempL=1:size(tempf,1)
                    tempfftT(tempL,:)=filter2(fil2,log(abs(fft2(tempf(tempL,:)))),'same');
                end  
                %tempfftT=transpose(abs(fft(transpose(tempf))));
                nFbands=25;%15
                numRows=floor(size(tempfftT,2)/(2*nFbands));
                if (numRows<1)
                    numRows=1;
                end
                segmentedMat=buffer(1:floor(size(tempfftT,2)/2),numRows);
                if (nFbands>size(segmentedMat,2))
                    nFbands=size(segmentedMat,2);
                end
                tempfftPartialT=zeros(nFbands,size(tempfftT,1) );%12
                for band=1:nFbands
                    tempfftPartialT(band,:) = sum(tempfftT(:,segmentedMat(:,band)),2);

                end                         
                tempfftPartialTF=bsxfun(@rdivide,tempfftPartialT,sum(tempfftPartialT));
                tempfftPartialTF=sum(tempfftPartialTF,2);%/size(tempfftPartialTF,2);


               temphF=bsxfun(@rdivide,temph,sum(temph));
               temphF=[sum(temphF,2)];%;combinedStdTemph];%/size(temphF,2);


                 %Magnitude Hist
                 tempM=whole_basketball_histAbs{subject}{segment}(:,initialBoundry:columnBoundry);
                 tempMF=bsxfun(@rdivide,tempM,sum(tempM));
                 tempMF=sum(tempMF,2);%/size(tempMF,2);

                %Standard deviation
                tempstdF=transpose(std(transpose(temph)));%the standard deviation of each bin



              %Compute fourier transform of each frame motion 
                tempfD=whole_basketball_data{subject}{segment}(:,initialBoundry:columnBoundry);
                tempfftF=zeros(size(tempfD));
                for tempL=1:size(tempfD,2)
                     tempfftF(:,tempL)=filter2(fil2,log(abs(fft2(tempfD(:,tempL)))),'same');
                end 
                %tempfftF=abs(fft(tempfD));
                tempFF=bsxfun(@rdivide,tempfftF(1:25,:),sum(tempfftF));
                tempfftPartialFF=sum(tempFF,2);
%            

                 featureVector=[tempfftPartialTF;temphF;tempMF;tempstdF;tempfftPartialFF];
                 if(find(isnan(featureVector)))
                     featureVector(find(isnan(featureVector)))=0;
                 end

                 whole_office_goff{subject}{segment}(:,c)=featureVector;%[sum(temph,2);tempstd;sum(tempM,2);sum(tempfftPartialF,2)];%[sum(temph,2);tempstd;sum(tempfftPartialF,2);sum(tempM,2);sum(tempfftPartialT,2)];%[sum(temph,2);tempstd;sum(tempfftPartialT,2);sum(tempM,2);sum(tempfftPartialF,2)];
                 c=c+1; % increase the number of columns
            end%for each windowed column


        end % for each segment

    end%for each subject
    %% Save
    save('whole_office_goff.mat','whole_office_goff')
end % end of proposed function