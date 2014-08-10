function ImgRGB = YUV4222RGB(Img)

outImage = zeros(size(Img,1), size(Img,2)/2);
Y = Img(:,1:2:end);
U = Img(:,2:4:end);
V = Img(:,4:4:end);

U = imresize(U, [size(U,1), size(U,2)*2]);
V = imresize(V, [size(U,1), size(V,2)*2]);

YUV = zeros(size(Img,1), size(Img,2)/2);
YUV(:,:,1) = Y;
YUV(:,:,2) = U;
YUV(:,:,3) = V;

ImgRGB= uint8(ycbcr_2_rgb( YUV ));

return;