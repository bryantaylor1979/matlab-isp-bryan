N = 70;
n = 24;
Img = zeros( n*N, n*N );
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );

fid = fopen( 'D:\face detection\FaceDetect_V1.3\data\datasetMike.dat' ); % fopen( 'D:\face detection\FaceDetect_V1.3\data\datasetTrainValid.dat' );
fread( fid, 5, 'uchar' );

ii = 1;
jj = 1;
for i = 1:N,
   jj = 1;
   for j = 1:N,
      fread( fid, 9, 'uchar' );
      Tmp = uint8( fread( fid, [n, n], 'uchar' )' );
      Img(ii:ii+n-1,jj:jj+n-1) = Tmp;
      jj = jj + n;
   end
   ii = ii + n;
end
 
figure(10),image( Img ), colormap( Map ), title( 'datasetMike' )


      