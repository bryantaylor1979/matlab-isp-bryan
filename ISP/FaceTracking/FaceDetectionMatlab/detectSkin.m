function [binImg, ImgYUYV] = detectSkin(ImgCounter)

Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); 

% ULims1 = [106    99   117   118   106];%first of 105

% ULims1 =[119   123   121   104    97    95   104   119];
% VLims1 =[129   136   147   162   159   152   133   129];
% ULims1 =[121   108    99    95   104   119   123   121];
% VLims1 =[147   165   165   152   133   129   136   147];
ULims1 =[108    96   104   112   122   121   108];
VLims1 =[165   152   133   132   141   147   165];
ULims1 =[96   108   121   122   120   116   115   112   104    96];
VLims1 =[152   165   147   141   139   140   135   132   133   152];
ULims1 =[96   108   121   109   104    96];
VLims1 =[152   165   147   133   133   152];
Row = 80;
Col = 80;
Row1 = 240;
Col1 = 960;
VJRes = 0;

UVFig = zeros(255,255);
Skin  = zeros(Row, Col);
ConvSkin = zeros(Row, Col);
ConComp = zeros(Row, Col);
SImgPrt = zeros(30);
EnSImgPrt = zeros(24);
Img = zeros(Row1,Col1*2);

%  for u=0:63
%       for v=0:63
%            inPoly = inpolygon(u*4, v*4, ULims1, VLims1);
%            SkinToneLutYUV(u*2^6+v+1) = inPoly; %SkinToneLutYUV(u*2^10+v*2^5+y+1) = inPoly;
%            UVFig(4*v+1,4*u+1) = 255*inPoly;
%          end
% end
%  figure, image(UVFig), colormap(Map)
%  line(ULims1, VLims1);

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
figure, subplot(3,3,1), image(rgb), colormap(Map), title('Img')
   
% fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\ScaledPic_', num2str(ImgCounter)], 'rb');
% %fid = fopen('D:\DF_STW\Zoran\L2_74\L274_0206\SL\Main\Sightic\FaceDetection\ORG0038.RAW', 'rb');
% c = fread(fid, 240*320*2, 'uint8')';
% fclose(fid);
% 
% k=1;
% for i=1:240
%    ImgYUYV(i,:)=c(k:k+2*320-1);
%    k=k+2*320;
% end
% rgb=convYUV422(ImgYUYV);
% subplot(3,3,3), image(rgb), colormap(Map), title('YUYV'), hold on;

%  subplot(3,3,1), image(uint8(rgb)), colormap(Map), title('RGB');

% fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\Skin_', num2str(ImgCounter)], 'rt'); 
% c = fscanf(fid, '%d');
% fclose(fid);
% 
% k=1;
% for i=1:Row
%   Skin(i, :)=c(k:k+Col-1);
%   k=k+Col;
% end
% subplot(3,3,3), image(8*uint8(Skin)), colormap(Map), title('Skin')

% fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\ConvSkin', 'rt');
% fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\LowPass_', num2str(ImgCounter)], 'rt'); 
% c = fscanf(fid, '%d');
% fclose(fid);
% 
% k=1;
% for i=1:Row
%   ConvSkin(i, :)=c(k:k+Col-1);
%   k=k+Col;
% end
% %image(255*uint8(ConvSkin)), colormap(Map), title('ConvSkin')
% subplot(3,3,4), image(8*uint8(ConvSkin)), colormap(Map), title('LowPass')

% fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\ConComp', 'rt'); 
% c = fscanf(fid, '%d');
% fclose(fid);
% 
% k=1;
% for i=1:Row
%   ConComp(i, :)=c(k:k+Col-1);
%   k=k+Col;
% end
% subplot(3,3,5), image(100*uint8(ConComp)), colormap(Map), title('ConComp')

% fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\SImgPrt_', num2str(ImgCounter)], 'rt');
% c = fscanf(fid, '%d');
% fclose(fid);
% 
% k=1;
% for i=1:30
%    SImgPrt(i,:)=c(k:k+30-1);
%    k=k+30;
% end
% subplot(3,3,3), image(uint8(SImgPrt)), colormap(Map), title('ScaledImgPrt');
% 
fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\EnSImgPrt_', num2str(ImgCounter)], 'rt');
c = fscanf(fid, '%d');
fclose(fid);

k=1;
for i=1:24
   EnSImgPrt(i,:)=c(k:k+24-1);
   k=k+24;
end
subplot(3,3,3), image(uint8(EnSImgPrt)), colormap(Map), title('EnScaledImgPrt');

%  VJRes=VJDrawImages(EnSImgPrt);
%  if(VJRes)

    fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\DrawRec_', num2str(ImgCounter)], 'rb'); %fid = fopen('D:\DF_STW\Zoran\L2_74\L274_0206\SL\Main\Sightic\FaceDetection\Img', 'rb'); 
   c = fread(fid, 2*Row1*Col1, 'uint8')';
   fclose(fid);
   
   k=1;
   for i=1:Row1
      Img(i,:)=c(k:k+2*Col1-1);
      k=k+2*Col1;
   end
   rgb=convYUV422(Img);
   figure(gcf), subplot(3,3,2), image(uint8(rgb)), colormap(Map), title('Detected Area')
% %  end

% fid = fopen(['D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\EnSImgPrt_', num2str(ImgCounter)], 'rt');
% c = fscanf(fid, '%d');
% fclose(fid);
% 
% k=1;
% for i=1:24
%    EnSImgPrt(i,:)=c(k:k+24-1);
%    k=k+24;
% end
% subplot(3,3,3), image(uint8(EnSImgPrt)), colormap(Map), title('EnScaledImgPrt');


return
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
%subplot(3,3,2), image(uint8(dest(:,:,1))), colormap(Map), title('GrayScale');
imwrite(rgb,'D:\face detection\pictures\2007-06-10-1224-45\bmpPic.bmp','bmp');
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function yuyv = convRGB(rgb)
% 
% Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); 
% [row,col, dim] = size(rgb);
% dest = zeros(row, col*2);
% l=1;
% for i=1:row
%    k=1;
%    for j=1:4:col
%       dest(l,k)=rgb(i,j,1);
%       dest(l,k+1)=rgb(i,j,2);
%       dest(l,k+1)=rgb(i,j,2);
%       dest(l,k+3)=yuv422(i,j,3);
%       k=k+1;
%       dest(l,k,1)=yuv422(i,j+2);
%       dest(l,k,2)=yuv422(i,j+1);
%       dest(l,k,3)=yuv422(i,j+3);
%       k=k+1;
%    end
%    l=l+1;
% end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pass=VJDrawImages(ImgPrt)

draw=0;
if draw
   Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
   VJ = zeros(24,24,16);
   fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\VJ', 'rt');
   c = fscanf(fid, '%d');
   fclose(fid);

   k=1;
   for i=1:16
      for j=1:24
         VJ(j,:,i) = c(k:k+24-1);
         k = k+24;
      end
   end
   figure
   for i=1:16
      subplot(4,4,i), image(VJ(:,:,i)), colormap(Map);
   end
end

[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'Cascade.txt' );
pass = ValidateFaceByVJ( ImgPrt, NCas, NFlt, StrongTresh, Alphas, Flt );
if(pass)
     title('VJ Pass');
else
   title('VJ Fail');
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( FileName )

   fid = fopen( FileName );

   tline = fgetl( fid );
   NCas = str2num( tline );
   for n = 1:NCas,
      tline = fgetl( fid );
      if( isempty( tline ) ),
         tline = fgetl( fid );
      end
      NFlt{n} = str2num( tline );
      tline = fgetl( fid );
      StrongTresh{n} = str2num( tline );
      tline = fgetl( fid );
      Alphas{n} = str2num( tline );
      for k = 1:NFlt{n},
         tline = fgetl( fid );
         Flt{n}{k} = str2num( tline );
      end
   end
   
   fclose( fid );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pass = ValidateFaceByVJ( ImgPrt, NCas, NFlt, StrongTresh, Alphas, Flt )

   Nvj = 25;
   Pass=0;
   MeanMin = 12348;
   MeanMax = 140065;
   SqMin = 591320;
   VarMin = 18.0123;
   paddedSize = 1/(Nvj*Nvj);
   NvjInc = size(ImgPrt,1);
   WinSize = NvjInc-Nvj+1;

   ImgPrt = [zeros(1,NvjInc); ImgPrt];
   ImgPrt = [zeros(NvjInc+1,1), ImgPrt];
   I  = cumsum( cumsum( ImgPrt' )' );
   II = cumsum( cumsum( (ImgPrt.^2)' )' );


   Pass = 1;
   I1 = I(s+Nvj,t+Nvj)+I(s+1,t+1)-I(Nvj+s,t+1)-I(s+1,Nvj+t);
   if( I1 < MeanMin | I1 > MeanMax ),
      Pass = 0;
      return;
   end

   I2 = II(s+Nvj,t+Nvj)+II(s+1,t+1)-II(Nvj+s,t+1)-II(s+1,Nvj+t);
   if( I2 < SqMin ),
      Pass = 0;
      return;
   end

   I1 = I1*paddedSize;
   I1 = I1*I1;
   I2 = I2*paddedSize;
   I3 = I2-I1;
   if(I3>0), I3 = sqrt(I3); else I3 = 1.0; end

   if( I3 < VarMin ),
      Pass = 0;
      return;
   end
   WinI = [I(s+1:end, :)];

   for n = 1:NCas,
      Val = 0;
      for k = 1:NFlt{n},
         x1 = Flt{n}{k}(4)+1;
         x2 = Flt{n}{k}(5)+1;
         x3 = Flt{n}{k}(6)+1;
         x4 = Flt{n}{k}(7)+1;
         y1 = Flt{n}{k}(8)+1;
         y2 = Flt{n}{k}(9)+1;
         y3 = Flt{n}{k}(10)+1;
         y4 = Flt{n}{k}(11)+1;

         switch( Flt{n}{k}(3) ), % Filter type
            case( 0 ),
               f1 = WinI(x1,y3) - WinI(x1,y1) + WinI(x3,y3) - WinI(x3,y1) + 2*(WinI(x2,y1) - WinI(x2,y3));
            case( 1 ),
               f1 = WinI(x3,y1) + WinI(x3,y3) - WinI(x1,y1) - WinI(x1,y3) + 2*(WinI(x1,y2) - WinI(x3,y2));
            case( 2 ),
               f1 = WinI(x1,y1) - WinI(x1,y3) + WinI(x4,y3) - WinI(x4,y1) + 3*(WinI(x2,y3) - WinI(x2,y1) + WinI(x3,y1) - WinI(x3,y3));
            case( 3 ),
               f1 = WinI(x1,y1) - WinI(x1,y4) + WinI(x3,y4) - WinI(x3,y1) + 3*(WinI(x3,y2) - WinI(x3,y3) + WinI(x1,y3) - WinI(x1,y2));
            case( 4 ),
               f1 = WinI(x1,y1) + WinI(x1,y3) + WinI(x3,y1) + WinI(x3,y3) - 2*(WinI(x2,y1) + WinI(x2,y3) + WinI(x1,y2) + WinI(x3,y2)) + 4*WinI(x2,y2);
         end

         if( Flt{n}{k}(2) ~=0 ), % Parity
            if( f1 < I3*Flt{n}{k}(1) ),   % Weak treshold
               Val = Val + Alphas{n}(k);
            end
         else
            if( f1 >= I3*Flt{n}{k}(1) ),
               Val = Val + Alphas{n}(k);
            end
         end
      end
      if( Val < StrongTresh{n} ),
         Pass = 0;
         break;
      end
   end
   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Mx, My] = calculateMoments(ConvSkin)

Mx=0;
My=0;

[Row,Col] = size(Skin);

   for i=1:Row
      for j=1:Col
         Mx = Mx+ConvSkin(i,j)*j;
         My = My+ConvSkin(i,j)*i;
      end
   end
Mx = Mx/sum(sum(Skin))
My = My/sum(sum(Skin))

return;
