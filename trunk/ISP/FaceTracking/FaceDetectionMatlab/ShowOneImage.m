function ShowOneImage()
Row1=240;
Col1=960;

Row=240;
Col=320;

% fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\Img240x320_1', 'rb');
% c = fread(fid, 2*Row*Col, 'uint8')';
% fclose(fid);
% k=1;
% for i=1:Row1
%    SImg(i,:)=c(k:k+2*Col-1);
%    k=k+2*Col;
% end
% rgb=convYUV422(SImg);
% figure, image(rgb);

fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\DrawRec_5', 'rb');
c = fread(fid, 2*Row1*Col1, 'uint8')';
fclose(fid);

k=1;
for i=1:Row1
   Img(i,:)=c(k:k+2*Col1-1);
   k=k+2*Col1;
end
rgb=convYUV422(Img);
figure, image(rgb);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgb=convYUV422(yuv422)

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
[row,col]=size(yuv422);
dest = zeros(row,col/2,3);

l=1;
for i=1:row
   k=1;
   for j=1:4:col
      dest(l,k,1)=yuv422(i,j);
      dest(l,k,2)=yuv422(i,j+1);
      dest(l,k,3)=yuv422(i,j+3);
      k=k+1;
      dest(l,k,1)=yuv422(i,j+2);
      dest(l,k,2)=yuv422(i,j+1);
      dest(l,k,3)=yuv422(i,j+3);
      k=k+1;
   end
   l=l+1;
end

rgb = ycbcr2rgb(uint8(dest));
return;
