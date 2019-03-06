function [M]= image_moments(I)
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


    % This code computes image moments for a frame from its intensity values
I=double(I);
[r c]=size(I); 
m=zeros(r,c); 
% geometric moments 
for i=0:1 
    for j=0:1 
        for x=1:r 
            for y=1:c 
                m(i+1,j+1)=m(i+1,j+1)+(x^i*y^j*I(x,y)); 
            end
        end
    end
end
xb=m(2,1)/m(1,1); 
yb=m(1,2)/m(1,1);
%Centroid-GIRMAW
M=[xb,yb];
