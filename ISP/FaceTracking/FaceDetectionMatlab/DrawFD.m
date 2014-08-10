function DrawFD(ImgCounter)

Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); 
Row1 = 240;
Col1 = 960;
Img = zeros(Row1,Col1*2);

fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\DrawRec_', num2str(ImgCounter)], 'rb'); %fid = fopen('D:\DF_STW\Zoran\L2_74\L274_0206\SL\Main\Sightic\FaceDetection\Img', 'rb'); 
   c = fread(fid, 2*Row1*Col1, 'uint8')';
   fclose(fid);
   
   k=1;
   for i=1:Row1
      Img(i,:)=c(k:k+2*Col1-1);
      k=k+2*Col1;
   end
   rgb=convYUV422(Img);
   figure, image(uint8(rgb)), colormap(Map), title('Img');
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
figure, image(img);
% imwrite(rgb,'D:\face detection\pictures\2007-06-10-1224-45\bmpPic.bmp','bmp');
return;
