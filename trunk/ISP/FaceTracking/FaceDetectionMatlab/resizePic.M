N = 20;
n = 24;
newSize = [15 15];
FacesImg = zeros( N*newSize(1), N*newSize(2) );
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
FacesMat = zeros(n^2,N^2); 


dirName = 'D:\face detection\FaceDetect_V1.3\data\';
fid = fopen([dirName, 'datasetMike.dat']); % fopen( 'D:\face detection\FaceDetect_V1.3\data\datasetTrainValid.dat' );
fread( fid, 5, 'uchar' );

ii = 1;
jj = 1;
for i = 1:N,
   jj = 1;
   for j = 1:N,
      fread( fid, 9, 'uchar' );
      Tmp = uint8( fread( fid, [n, n], 'uchar' )' );
      NewImg = imresize(Tmp, newSize, 'bicubic');
      FacesImg(ii:ii+newSize(1)-1,jj:jj+newSize(2)-1) = NewImg;
      jj = jj + newSize(1);
   end
   ii = ii + newSize(1);
end
 
figure(10),image(FacesImg), colormap(Map), title( 'Faces' )
imwrite( FacesImg,[dirName, 'faces15X15'], 'jpg' );


% dirName = 'C:\WuJX\SkinColor\non-skin-images';
% newSize = [15 15];
% files = dir(strcat(dirName, '\*.jpg'));
% [nFiles,b] = size(files);
% 
% ii = 1;
% jj = 1;
% N = 20;
% n = 24;
% 
% for imgFile = 1:nFiles,
%    
%    ImgFileName = fullfile(dirName, files(imgFile).name);
%    Img = imread(ImgFileName) ;
%    NewImg = imresize(Img, newSize, 'bicubic');
%    figure(10), image(uint8(NewImg)),  title( 'SkinImg' );
%    FacesImg(ii:ii+n-1,jj:jj+n-1) = NewImg;
%    jj = jj + n;
%    
%    if(jj == N)
%       ii = ii + 1;
%       jj = 1;
%    end
% 
% end
% 
% 
% newFileName = fullfile(dirName, 'Resized', files(imgFile).name);
% imwrite( FacesImg,[dirName, 'Non_faces'], 'jpg' );
