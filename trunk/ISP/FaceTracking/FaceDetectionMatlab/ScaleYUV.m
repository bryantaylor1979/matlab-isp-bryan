function Scale()

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
[FileName,PathName] = uigetfile('PathName\*.jpg','Select a Picture');
FileName = [PathName ,FileName];
Img = imread(FileName);
figure,image(Img)
ycbcr = rgb2ycbcr(Img);
gray=ycbcr(:,:,1);
figure,image(gray),colormap(Map)
[row,col]=size(gray);
yuv422=zeros(row,col*2);
yuv422=conv2yuv422(Img);
size(yuv422)
newrow = row/6;
newcol=col/3;
dest=SIDirectScaleYUV(yuv422, newrow, newcol);
dest=convYUV422Gray( dest, newrow, 2*newcol);
figure, image(dest), colormap(Map);

return;

function dest=convYUV422Gray( yuv422, row, col)

dest = zeros(row,col/2);
l=1;
for i=1:row
   k=1;
   for j=1:2:col
      dest(l,k)=yuv422(i,j);
      k=k+1;
   end
   l=l+1;
end
return;

function dest=SIDirectScaleYUV(yuv422, puiDestHeight, puiDestWidth)

[ysize,xsize]=size(yuv422);
xsize=xsize/2;

WidthOffset = xsize/puiDestWidth;
HeightOffset = ysize/puiDestHeight;
UVOffset = 4*WidthOffset;
dest = zeros(puiDestHeight,2*puiDestWidth); 
Index=0;

k=1; l=1;
for j=1:HeightOffset:ysize
   l=1;
	for i=1:UVOffset:2*xsize
      dest(k,l) = yuv422(j,i);
      l=l+1;
		dest(k,l) = yuv422(j,i+1);
       l=l+1;
		dest(k,l) = yuv422(j,i+2);
      l=l+1;
		dest(k,l) = yuv422(j,i+3);
       l=l+1;
    end
    k=k+1;
end
return;
   