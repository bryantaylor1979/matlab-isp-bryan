
tstImg = zeros(48,48);

MikeImgs = zeros(10000, 24*24);
TrainValidImgs = zeros(4832, 24*24);
char0 = 48;


% f=fopen('c:\Broadcom\FaceTracking\FaceDetect_V1.3\data\datasetTrainValid.dat');
% a=fread(f,5);
% imgCnt = a-char0;
% for i=1:4832
%     Mark = fread(f,9);
%     I = fread(f,24*24);
%     Img = reshape(I,24,24);
%     tstImg(1:24,1:24) = Img';
%     imwrite(uint8(tstImg), ['c:\Broadcom\FaceTracking\ImagesDB\ValidationImages\ValidationFace' num2str(i) '.jpg'], 'jpg');
% %     image(Img'); colormap(Map), title( ['Img=', num2str(i)] );
% %     TrainValidImgs(i, :) = I;
% %     pause(0.01)
% end
% fclose(f);


f=fopen('c:\Broadcom\FaceTracking\FaceDetect_V1.3\data\datasetMike_Orig.dat');
a=fread(f,5);
imgCnt = a-char0;
for i=1:5000
    Mark = fread(f,9);
    I = fread(f,24*24);
    Img = reshape(I,24,24);
    tstImg(1:24,1:24) = Img';
    imwrite(uint8(tstImg), ['c:\Broadcom\FaceTracking\ImagesDB\MikeImages\Faces\DB\' num2str(i) '.jpg'], 'jpg');
%     image(Img'); colormap(Map), title( ['Img=', num2str(i)] );
%     TrainValidImgs(i, :) = I;
%     pause(0.01)
end
for i=1:5000
    Mark = fread(f,9);
    I = fread(f,24*24);
    Img = reshape(I,24,24);
    tstImg(1:24,1:24) = Img';
    imwrite(uint8(tstImg), ['c:\Broadcom\FaceTracking\ImagesDB\MikeImages\NonFaces\DB\' num2str(i) '.jpg'], 'jpg');
%     image(Img'); colormap(Map), title( ['Img=', num2str(i)] );
%     TrainValidImgs(i, :) = I;
%     pause(0.01)
end
fclose(f);