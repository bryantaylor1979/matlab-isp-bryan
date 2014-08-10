Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); 
for ImgCounter=125:150
   fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\EnSImgPrt_', num2str(ImgCounter)], 'rt');
   c = fscanf(fid, '%d');
   fclose(fid);

   k=1;
   for i=1:30
      EnSImgPrt(i,:)=c(k:k+30-1);
      k=k+30;
   end
   figure, image(uint8(EnSImgPrt)), colormap(Map), title('EnScaledImgPrt');
end
