 function virtual_inertial_feature_extraction(whole_basketball_data_centroid,nframes,overlapR)   
%% 
% This code extracts centroid-based features from  video segments 
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
           numSubjects=length(whole_basketball_data_centroid);

            %centroid
        
            whole_basketball_centroid_velocity=cell(1,numSubjects);
            whole_basketball_centroid_acceleration=cell(1,numSubjects);

            fil1=fspecial('gaussian',7,1); %incase filtering is necessary
            for subject=1:numSubjects
                numSegments=length(whole_basketball_data_centroid{subject});%number of segments in a video
                velocityCell=cell(1,length(numSegments));
                accelerationCell=cell(1,length(numSegments));
           
     
    
                for segment=1:numSegments

                   temp=diff(whole_basketball_data_centroid{subject}{segment},1,2);
                   velocityCell{segment}=[filter2(fil1,temp(1,:),'same');filter2(fil1,temp(2,:),'same')];
                   temp=diff(velocityCell{segment},1,2);
                   accelerationCell{segment}=temp;%no more filtering[conv2(temp(1,:),fil1,'same');conv2(temp(2,:),fil1,'same')];
                   %acc2Cell{segment}=diff(accelerationCell{segment},1,2);


                end
                whole_basketball_centroid_velocity{subject}=velocityCell;
                whole_basketball_centroid_acceleration{subject}=accelerationCell;
            

            end


            


            %% Windowed data extraction
            whole_office_vif=cell(1,numSubjects);
            for subject=1:numSubjects
                numSegments=length(whole_basketball_centroid_acceleration{subject});%number of segments in a video
                
             
                for segment=1:numSegments
                    c=1;%first column
                    numColumns=size(whole_basketball_centroid_acceleration{subject}{segment},2);%num of cols of a segment
                    numColumns=numColumns-1; %incase of precaution not to run out of dimension, compared with projection
                    for col=1:floor(nframes*overlapR):numColumns-1
                        if (col+nframes>numColumns) % check j+nframes is not above the number of columns already availab
                            columnBoundry=numColumns;%CellAverageSum{i}(:,c)=sum(UVtotalHistCell{i}(:,j:numColumns),2);
                            if (columnBoundry - nframes)>=1

                                initialBoundry=columnBoundry - nframes;       


                            elseif(((numColumns - col)> nframes/2)||col==1) %if it gets to negative when columnBoundry - nframes 
                               initialBoundry=col;      

                            end
                         tempV=whole_basketball_centroid_velocity{subject}{segment}(:,initialBoundry:columnBoundry);                
                         tempA=whole_basketball_centroid_acceleration{subject}{segment}(:,initialBoundry:columnBoundry);                
                         %tempA2=whole_basketball_centroid_acc2{subject}{segment}(:,initialBoundry:columnBoundry);                
                        
                         %replicate the available segment
                         tempV=repmat(tempV,1,ceil(nframes/(size(tempV,2)-1)));
                         tempV= tempV(:,1:nframes+1);                          
                         %replicate the available segment
                         tempA=repmat(tempA,1,ceil(nframes/(size(tempA,2)-1)));
                         tempA= tempA(:,1:nframes+1); 
                         %            %replicate the available segment
                         %tempA2=repmat(tempA2,1,ceil(nframes/(size(tempA2,2)-1)));
                         %tempA2= tempA2(:,1:nframes+1); 



                        else
                            columnBoundry=col+nframes;
                            initialBoundry=col;
                         %then
                         tempV=whole_basketball_centroid_velocity{subject}{segment}(:,initialBoundry:columnBoundry);                
                         tempA=whole_basketball_centroid_acceleration{subject}{segment}(:,initialBoundry:columnBoundry);              
                         %tempA2=whole_basketball_centroid_acc2{subject}{segment}(:,initialBoundry:columnBoundry);              
                        end
                        tempWindow=[tempV;tempA];
                        %magnitueds of the 4 pairs (disp, velco,acce, centroi)
                        magnitudes=[sqrt(tempWindow(1,:).^2+tempWindow(2,:).^2);...
                                    sqrt(tempWindow(3,:).^2+tempWindow(4,:).^2)];
                        %Magnitude bins
                        mbin=15;
                        mbins=linspace(0,1,mbin);
                        magnHist=hist(filter2(fil1,magnitudes','same'), mbins);
                        %phase angle of these pairs
                        phaseAngles=[angle(tempWindow(1,:)+tempWindow(2,:)*1i);...
                                    angle(tempWindow(3,:)+tempWindow(4,:)*1i)];
                        nbins=36;
                        bins=linspace(-pi,pi,nbins);
                        phaseAngles_hist=hist(phaseAngles',bins);
                        %cascade these magnitued and phase angle to tempWindow
                        tempWindow=[tempWindow;magnitudes];
                        %compute the mean and std of each signal.
                        meanVec=mean(tempWindow,2);
                        stdVec=std(transpose(tempWindow));

                        %apply Fourier transfor
                        %Compute fft of each bin across time
                        tempf=tempWindow;%if the fft is performed on the temph
                        tempfftT = zeros(size(tempf));
                        fil2=fspecial('gaussian',3,0.5); %incase filtering is necessary
                        for tempL=1:size(tempf,1)
                            tempfftT(tempL,:)=filter2(fil2,log(abs(fft2(tempf(tempL,:)))),'same');
                        end 
                        tempWindowFFT=tempfftT;
                        %decompose the response in to bands and sum teh
                        %response in each band                       
      
                

                        %the first 8 coefficients only
                        %tempWindowFFTF=tempWindowFFT([3,4,6],1:20);
                        tempWindowFFTF=tempWindowFFT(:,1:10);
                        
                        %the number of zero crossings 
                        zeroCrossing=zeros(4,1);
                        for sig=1:4% only six are considered, centroid has a problem TO BE FIXED
                         zeroCrossing(sig)=length(find(diff(tempWindow(sig,:)>0)~=0)+1);
                        end
                        %additional featatures
                        mi=transpose(min(tempWindow')); 
                        Ma=transpose(max(tempWindow'));
                        med=transpose(mad(tempWindow'));%meadian absoulute deviation
                        en=sum(tempWindow.^2,2);%energy
                        kur=transpose(kurtosis(transpose(tempWindow)));%tempWindowFFT
                        
                             
                       whole_office_vif{subject}{segment}(:,c)=[mi;Ma;med;en; kur;zeroCrossing;meanVec;transpose(stdVec);tempWindowFFTF(:)];%];kur;sum(magnHist,2);tempWindowFFT
               
                         
                       c=c+1;
                    end
                end
                
            end
            
    %% Save
    save('whole_office_vif.mat','whole_office_vif')
 
 end