
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
dirName = 'C:\Efrat\face-detection\FaceDetect_V1.3\data\';
fid = fopen([dirName, 'datasetMike12x12.dat'], 'r');
header = fread( fid, 5, 'uchar' );


%resize Faces images from 24*24 To 15*15
N = 100;
n = 12;

clear FacesImg;

ii = 1;
jj = 1;
for i = 1:N,
    jj = 1;
    for j = 1:N,
        header = fread( fid, 9, 'uchar' );
        NewImg = uint8( fread( fid, [n, n], 'uchar' )' );
        FacesImg(ii:ii+n-1, jj:jj+n-1) = NewImg;
        jj = jj + n;
        
    end
    ii = ii + n;
end

figure(17),image(FacesImg), colormap(Map), title( 'Dataset Mike 12x12' );
fclose(fid);