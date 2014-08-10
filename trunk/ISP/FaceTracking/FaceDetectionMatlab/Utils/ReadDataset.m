
Map = linspace(0, 1, 256)'*ones(1, 3);

MikeImgs = zeros(10000, 24*24);
TrainValidImgs = zeros(4832, 24*24);
char0 = 48;

f=fopen('c:\Projects\FaceTracking\FaceDetect_V1.3\data\datasetMike.dat');
a=fread(f,5);
imgCnt = a-char0;

 for i=1:1000
     Mark = fread(f,9);
     I = fread(f,24*24);
     Img = reshape(I,24,24);
     MikeImgs(i, :) = I;
     image(Img'); colormap(Map);
     sprintf('min : %d  max %d',min(I),max(I))
     t=1;
 end
fclose(f);
f=fopen('c:\Projects\FaceTracking\FaceDetect_V1.3\data\datasetTrainValid.dat');
a=fread(f,5);
imgCnt = a-char0;

for i=1:4832
    Mark = fread(f,9);
    I = fread(f,24*24);
    Img = reshape(I,24,24);
    image(Img'); colormap(Map), title( ['Img=', num2str(i)] );
    TrainValidImgs(i, :) = I;
    pause(0.01)
end
fclose(f);

[IntersectImg,IA,IB] = intersect(MikeImgs, TrainValidImgs, 'rows');

TrainValidImgsSort = sort(TrainValidImgs, 1, 'ascend');
MikeImgsSort = sort(MikeImgs, 1, 'ascend');

for i=1:1000  
    Img = reshape(MikeImgsSort(i,:),24,24);
    figure(1); image(Img'); colormap(Map);
    
    if( i < 4832 )
    Img = reshape(TrainValidImgsSort(i,:),24,24);
    figure(2); image(Img'); colormap(Map);
    
    pause(0.1);
    end
end
