function OutImg = JpegScaleAndConv2YUV422(ImgName, rows, cols)% jpeg

Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); Map(256,2:3) = [0, 0];
Img = double( imread(ImgName , 'jpg') );

ImgT(:,:,1) = imresize(Img(:,:,1), [rows, cols]);
ImgT(:,:,2) = imresize(Img(:,:,2), [rows, cols]);
ImgT(:,:,3) = imresize(Img(:,:,3), [rows, cols]);

ImgYCbCr= rgb_2_ycbcr( ImgT );
OutImg = zeros(size(ImgYCbCr,1), 2*size(ImgYCbCr,2));

Y = ImgYCbCr(:,:,1);
U = ImgYCbCr(:,:,2);
V = ImgYCbCr(:,:,3);


U = imresize(U, [size(U,1), size(U,2)/2]);
V = imresize(V, [size(U,1), size(V,2)/2]);

OutImg(:,1:2:end) = Y;
OutImg(:,2:4:end) = U;
OutImg(:,4:4:end) = V;

fid = fopen( [ImgName(1:end-4), '_1'], 'w');
fwrite(fid, OutImg');
fclose(fid);

return;