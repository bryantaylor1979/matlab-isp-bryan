function ImgYCbCr = Jpeg2Yuv422( ImgName )

% ImgName = 'd:\DF_DNR\DNR_STK\Images\';
%Img = double(imread([ImgName 'DnrIn2.bmp'], 'bmp'));

Img = double( imread(ImgName , 'jpg') );
%Img = Img(1:2448, 1:3264, :);
%Img = Img(1:1944, 1:2592, :);

ImgYCbCr= rgb_2_ycbcr( Img );

% imwriteraw( uint8(ImgYCbCr(:,:,1)),           [ImgName 'YIn6.raw'] );
% imwriteraw( uint8(ImgYCbCr(:,1:2:end,2)+128), [ImgName 'UIn6.raw'] );
% imwriteraw( uint8(ImgYCbCr(:,1:2:end,3)+128), [ImgName 'VIn6.raw'] );

return;

% Img = double(imread([ImgName '.JPG'], 'jpg'));
% ImgYCbCr = rgb_2_ycbcr( Img );
% WriteYUV422( ImgYCbCrSht(:,:,1), ImgYCbCrSht(:,:,2), ImgYCbCrSht(:,:,3),
% [ImgName 'Out.JPG'], 0, 0 );

% ImgSht = imread('c:\Fujitsu_Mobile\Projects\Fujitsu_901\Images\050907_1745\Problem\DF01-013.jpg', 'jpg');
% ImgLng = imread('c:\Fujitsu_Mobile\Projects\Fujitsu_901\Images\050907_1745\Problem\DF01-014.jpg', 'jpg');
% 
% ImgSht = double(ImgSht);
% ImgLng = double(ImgLng);
% 
% ImgYCbCrSht = rgb_2_ycbcr( ImgSht );
% ImgYCbCrLng = rgb_2_ycbcr( ImgLng );
% 
% WriteYUV422( ImgYCbCrSht(:,:,1), ImgYCbCrSht(:,:,2), ImgYCbCrSht(:,:,3), 'c:\Fujitsu_Mobile\Projects\Fujitsu_901\Images\050907_1745\Problem\DF01-013.yuv', 0, 0 );
% WriteYUV422( ImgYCbCrLng(:,:,1), ImgYCbCrLng(:,CRIM0001:,2), ImgYCbCrLng(:,:,3), 'c:\Fujitsu_Mobile\Projects\Fujitsu_901\Images\050907_1745\Problem\DF01-014.yuv', 0, 0 );