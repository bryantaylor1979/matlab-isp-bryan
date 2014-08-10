Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); Map(256,2:3) = [0, 0];

% This is the image with the 3 faces
fid = fopen('C:\Efrat\face-detection\FaceDetectionTrail\DrawRec_s_18'); %faces

%This is the image with the array of faces
%  fid = fopen('C:\Efrat\face-detection\FaceDetectionTrail\YUV422_1'); %faces1


Img = fread(fid, 240*320*2);
I = reshape(Img, [320*2,240]);
I=I';
I=I(:,1:2:end);
figure, image(uint8(I)), colormap(Map)


% fid = fopen('C:\Efrat\Matlab\face-detection\code\faces1_1')%
% fid = fopen('C:\Efrat\Matlab\face-detection\code\faces_1')%
