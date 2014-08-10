function DrawVJFrames()
Row1 = 240;
Col1 = 960;
ImgCounter = 1;

fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\Img_', num2str(ImgCounter)], 'rb'); %fid = fopen('D:\DF_STW\Zoran\L2_74\L274_0206\SL\Main\Sightic\FaceDetection\Img', 'rb'); 
c = fread(fid, 2*Row1*Col1, 'uint8')';
fclose(fid);

k=1;
for i=1:Row1
   Img(i,:)=c(k:k+2*Col1-1);
   k=k+2*Col1;
end
rgb=convYUV422(Img);

endXY = [60,54,48,42,36];
index = 1;

for diff=12:6:36
   figure, image(rgb), title(['diffX ', num2str(diff*12), 'diffY ', num2str(diff*3)]);
      for minX=6:2:endXY(index)
         line([minX*12, minX*12],[6*3,(endXY(index)+diff)*3]);
      end
      line([(minX+diff)*12, (minX+diff)*12],[6*3, (endXY(index)+diff)*3]);
      for minY=6:2:endXY(index)
         line([6*12,(minX+diff)*12], [minY*3,minY*3]);  
      end
      line([6*12,(minX+diff)*12], [(minY+diff)*3,(minY+diff)*3]);     
      %first frame 
      line([(6+diff)*12,(6+diff)*12],[6*3,(6+diff)*3], 'Color', 'r');
      line([6*12,(6+diff)*12],[(6+diff)*3,(6+diff)*3], 'Color', 'r' );
   index = index+1;   
end

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