%Read textfile 
%Girmaw A, 
%August 13/2015
videoPath='./gt_office_eaf_label/';
addpath(videoPath)
videos= dir(strcat(videoPath,'*.txt'));
videos={videos.name};
numVideos=length(videos)

 for sub=1:numVideos
 
 fullfilename=videos{sub};
 filename=strtok(fullfilename,'.');
 % - Get structure from first line.
 fid  = fopen( fullfilename, 'r' ) ;
 line = fgetl( fid ) ;
 fclose( fid ) ;
 isStrCol = isnan( str2double( regexp( line, '[^\t]+', 'match' ))) ;
 % - Build formatSpec for TEXTSCAN.
 fmt = cell( 1, numel(isStrCol) ) ;
 fmt(isStrCol)  = {'%s'} ;
 fmt(~isStrCol) = {'%f'} ;
 fmt = [fmt{:}] ;
 % - Read full file.
 fid  = fopen( fullfilename, 'r' ) ;
 data = textscan( fid, fmt, Inf, 'Delimiter', '\t' ) ;
 fclose( fid ) ;
 % - Optional: aggregate columns into large cell array.
 for colId = find( ~isStrCol )
    data{colId} = num2cell( data{colId} ) ;
 end
 %data = [data{:}] ;
 gt_office.(filename).start_time=cell2mat(data{:,1});
 gt_office.(filename).final_time=cell2mat(data{:,3});
 gt_office.(filename).label=[data{:,6}];
 end%sub
 save('gt_office.mat','gt_office');