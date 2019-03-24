# 2019 IEEE Video and Image Processing (VIP) Cup
## Office Activity Recognition in First-person Vision 

Girmaw Abebe and Andrea Cavallaro

Date: March  2019


Requested citation acknowledgement when using this software: 

Girmaw Abebe, Andrea Cavallaro and Xavier Parra, "Robust multi-dimensional motion features for first-person vision activity recognition", Computer Vision and Image Understanding, Vol. 149,  2016, pp. 229-248.

Girmaw Abebe and Andrea Cavallaro, "Hierarchical modeling for first-person vision activity recognition",    Neurocomputing, Vol. 267, 2017, pp. 362-377 . 


**1. Introduction**

The increasing availability of wearable cameras, such as Google Glass and GoPro, en-
ables the collection of first-person vision (FPV) data for the recognition of activities
at home, in the office and during sport activities. Ego-centric activity recognition
has several important applications, which include life-logging and summarization,
assisted living and activity tracking. The main challenges of FPV activity recogni-
tion are motion blur, rapid illumination changes and outlier motions (for example
due to other people captured by the camera). Moreover, the mounting position
of the camera itself might cause self-occlusions (chest-mounted camera) or spuri-
ous motions (head-mounted camera). In addition to spatial (appearance), temporal
(motion) information is crucial to discriminate activities of the camera wearer.
The 2019 VIP-CUP challenge is on the recognition of office activities in FPV. Office
activities include person-to-person interactions, such as chatting and handshaking,
person-to-object interactions, such as using a computer or a whiteboard, as well
as generic activities such as walking. A dataset of office activities from several
subjects is provided with the annotation for training and validation purposes (http:
//www.eecs.qmul.ac.uk/~andrea/fpvo). The evaluation will be performed based
on test sets provided closer to the submission deadline.


The source code contains MATLAB files  and clear instructions are given below to run these scripts. These MATLAB scripts are necessary to compute optical flow and centroid velocity, extract motion features and train and test classifiers. 

**2. How to run the MATLAB software?**

The software has been tested on MATLAB 8.4.0.150421 (R2014b) on a PC (UBUNTU 14.04 LTS) with specifications: Intel (R) Core (TM) i7-4770 CPU @ 3.40 GHz, 16.0 GB RAM,64-bit).  The Bioinformatics, Computer Vision and Neural Network Toolbox  must be installed and licensed. Set path of MATLAB to <./PATH TO CODE>.
Download the supporting_data and unzip it in ./PATH/ directory to replicate the results and use input examples,

**3. MATLAB files:**

**office_activities_classification_March_2019.m** –  Main script that extracts/load two types of motion features from first-person videos of office activities.

NB: Running the software clears the MATLAB workspace and closes the already opened figure(s). 
<!--- Warning: You might run out of memory if you do not have at least 8GB RAM.-->
	     
**GOF_computation_office.m** – Function that computes grid optical flow vectors from videos

**goff_feature_extraction.m** – Function that extract multiple optical-flow based features, both in time and frequency domains

**centroid_computation_office.m** – Function that compute the intensity centroid per each frame 

**image_moments.m** – Function that computes the first-order image moments that are necessary to find the intensity centroid per each frame. 

**virtual_inertial_feature_extraction.m** – Function that extracts virtual inertial features from the displacement of intensity centroid across frames in a video

**arrange_train_test_office.m** – Function that takes the available data, apply train-test split, train  and test two classifiers (SVM and KNN), and return the results



**4. License**
This software is provided under the terms and conditions of the creative commons public license. Please refer to the file 
<./ License.doc> for more information.

**5.  Contact**
If you have any queries, please contact girmawabebe@gmail.com


Thanks for your interest,


Girmaw Abebe and Andrea Cavallaro
