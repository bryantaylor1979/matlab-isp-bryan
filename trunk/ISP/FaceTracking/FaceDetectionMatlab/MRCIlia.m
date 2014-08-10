Map = linspace( 0, 1, 256 )' * ones( 1, 3 );

% Set sizes
NImg = 2400;
N = 24;
Nx = 15; Ny = 15;

% Prepare Mask
Mask = ones( 12, 12 );
Mask(1:6,1) = 0;
Mask(1:3,2) = 0;
Mask(1:2,3) = 0;
Mask(1:1,4) = 0;
Mask(1:6,7:12) = fliplr( Mask(1:6,1:6) );
Mask(7:12,:) = flipud( Mask(1:6,:) );
Mask = imresize( Mask, [Ny, Nx], 'bilinear' );
Mask = Mask > 0.5;
Mask = ones( size( Mask ) );

% Prepare Light Normalization matrix
Idx = find( Mask == 1 );
[idxXFull, idxYFull] = meshgrid( 1:Nx, 1:Ny );
idxX = idxXFull(Idx);
idxY = idxYFull(Idx);
NPix = length( idxX );

X1 = zeros( NPix, 3 );
X1(:,1) = idxX(:);
X1(:,2) = idxY(:);
X1(:,3) = ones( NPix, 1 );

if(exist('NoMaskFacesImgLearn.mat', 'file'))
   load NoMaskFacesImgLearn
else
   FacesImgLearn = zeros( Nx*Ny, NImg );

   % Read Faces Vectors and normalize
   dirName = 'D:\face detection\FaceDetect_V1.3\data\';
   fid = fopen( [dirName, 'datasetMike.dat'] );
   fread( fid, 5, 'uchar' );

   for n = 1:NImg,
      fread( fid, 9, 'uchar' );
      Tmp = double( fread( fid, [N, N], 'uchar' )' );
      NewImg = imresize( Tmp, [Ny, Nx], 'bicubic' );
      a1 = inv(X1'*X1)*X1'*NewImg(Idx);
      Img1Ord = a1(1)*idxXFull(:) + a1(2)*idxYFull(:) + a1(3);
      NewImg1Ord = Mask .* (NewImg - reshape( Img1Ord, Ny, Nx ) + 128);
      FacesImgLearn(:,n) = NewImg1Ord(:);

      %    if( rem( n, 100 ) == 1 ), disp( n ); end
      %    subplot(231), image( NewImg ), axis( 'square' ), colormap( Map )
      %    subplot(233), image( NewImg1Ord ), axis( 'square' ), colormap( Map ), title( '1ord' );
      %    subplot(234), image( Mask*255 ), axis( 'square' ), colormap( Map )
      %    subplot(236), image( reshape( Img1Ord, Ny, Nx ) ), axis( 'square' ), colormap( Map ), title( '1ord' );
   end
   fclose( fid );
   save('NoMaskFacesImgLearn', 'FacesImgLearn');
   % save('NoMaskFacesImgTest', 'FacesImgTest');
end


%Read Non Faces Vectors%%%%%%%%%%%%%%%%%%%%%%%%
NonFacesLen = 100000;

if(exist('NoMaskNonFacesMat.mat', 'file'))
   load NoMaskNonFacesMat;
else
   NonFacesMat = zeros( Ny*Nx, NonFacesLen );
   dirName = 'C:\WuJX\SkinColor\non-skin-images';
   files = dir(strcat(dirName, '\*.jpg'));
   [nFiles,b] = size(files);

   exitFlag = 0;
   kk = 1;
   for imgFile = 1:nFiles,

      if(exitFlag)
         break;
      end

      ImgFileName = fullfile(dirName, files(imgFile).name);
      Img = imread(ImgFileName);
      [nn,mm,tt] = size(Img);

      if(tt == 3)
         Img = rgb2gray(Img);
      end

      nn = floor(nn/Ny);
      mm = floor(mm/Nx);
      ii = 1;
      jj = 1;
      for i=1:nn

         if(exitFlag)
            break;
         end
         jj = 1;

         for j=1:mm
            Tmp = Img(ii:ii+Ny-1, jj:jj+Nx-1);
            NonFacesMat(:,kk) = Tmp(:);
            kk = kk + 1;
            if(kk >= NonFacesLen)
               exitFlag = 1;
               break;
            end
            jj = jj + Nx;
         end
         ii = ii + Ny;
      end
   end
   save('NoMaskNonFacesMat', 'NonFacesMat');
end

%load FacesImgLearnSet_2400_15x15_1ord_NoMsk
FacesImgLearn(FacesImgLearn<0) = 0;
FacesImgLearn(FacesImgLearn>255) = 255;

%load NonFacesMat
NonFacesMat = NonFacesMat .* (Mask(:)*ones(1,NonFacesLen));

% Calculating Cascades
Mx = sum(FacesImgLearn')' / NImg;
A = FacesImgLearn-Mx*ones(1,NImg);
AAt = A * A';
Rxx = AAt;

nLoops = 15;
d1 = double(zeros(1,nLoops)); 
d2 = double(zeros(1,nLoops)); 
u = double(zeros(Ny*Nx,nLoops)); 

% figure( 2 ),
% subplot(211), image( uint8( reshape( Mx, 15, 15 ) ) ), axis( 'image' ), colormap( Map ), title( 'Mean of Faces' )

NonFaceSample = NonFacesMat(:,1);
for i = 1:nLoops,
   My = sum(NonFacesMat')' / NonFacesLen;
   B = NonFacesMat-My*ones(1,NonFacesLen);
   Ryy = B * B';
   Rxy = (My-Mx)*(My-Mx)';
   
   BBt = Rxx + Ryy + Rxy;
   [U, D] = eig( AAt, BBt );
   d = diag( D );
   [minD, indx] = min( d );
   u(:,i) = U(:,indx); %eigen vector the correspond to the smallest eigen value

   if( i == 1 | i == nLoops ),
      figure( 10*i+1 ), title( ['Iter = ', num2str(i)] );
      subplot(221), imagesc( Rxx ), colormap( Map ), title( 'Rxx == AAt' )
      subplot(222), imagesc( Ryy ), colormap( Map ), title( 'Ryy' )
      subplot(223), imagesc( Rxy ), colormap( Map ), title( 'Rxy' )
      subplot(224), imagesc( BBt ), colormap( Map ), title( 'BBt' )

      figure( 10*i+2 ),
      subplot(321), imagesc( reshape( U(:,1), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMin'] );
      subplot(322), imagesc( reshape( U(:,2), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMin+1'] );
      subplot(323), imagesc( reshape( U(:,end), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMax'] );
      subplot(324), imagesc( reshape( U(:,end-1), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMax-1'] );
      subplot(325), plot( d ), grid, title( 'd' );
   end
   InnerProdNonFaces = u(:,i)' * NonFacesMat;
   InnerProdFaces = u(:,i)' * FacesImgLearn;
   [InnerSorted, InnerIdx] = sort( InnerProdFaces );
   d1(i) = InnerSorted(3);
   d2(i) = InnerSorted(end-2);

   figure( 4 ), subplot(4,4,i),
   plot( InnerProdFaces, zeros( size(InnerProdFaces) ), '*r', InnerProdNonFaces, ones( size(InnerProdNonFaces) ) , '*b', d1(i), -1, '*g', d2(i), -1, '*g' ),
   grid, title( ['Iter = ', num2str( i )] ),
   axis( [min( [InnerProdFaces(:); InnerProdNonFaces(:)] ), max( [InnerProdFaces(:); InnerProdNonFaces(:)] ), -10, 11] );

   indices = find( (InnerProdNonFaces > d1(i)) &  (InnerProdNonFaces < d2(i)) ); %find all indicies of non-faces that intersect with faces cluster
   NonFacesLen = length(indices);
   NonFacesMat = NonFacesMat(:,indices);
end

%Classification Process%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Example Lets take the first Face Image and see 
%if all the cascade tests were successful  

%load NonFacesMat
NonFacesLen = length( NonFacesMat );
%load FacesImgTestSet_2400_15x15_1ord_NoMsk
Res = zeros( 1, NImg );
for n = 1:NImg,
   face = FacesImgLearn(:,n);
   %face = NonFacesMat(:,n);
   for i = 1:nLoops,
      proj = u(:,i)'* face;
      if( (d1(i)< proj) & (d2(i)> proj) ),
         %display( ['Cascade ', num2str(i), ' passed'] );
         Pass = 1;
      else
         %display( ['Cascade ', num2str(i), ' failed'] );
         Pass = 0;
         break;
      end
   end
   %disp( [n, proj, d1(i), d2(i)] );
   %figure(3), imagesc( reshape( face, 15, 15 ) ), colormap( Map ), axis( 'image' )
   %pause;
   Res(n) = Pass;
end

Img = imread('D:\face detection\pictures\2007-06-10-1224-45\DSCF0439.JPG');
YCBCR = rgb2ycbcr(Img);
grayImg = rgb2gray(Img);

xx =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16 -8];
yy =  [  7    12    20    27    31    28    22    16    12  7];

Cb = double(YCBCR(:,:,2));
Cr = double(YCBCR(:,:,3));
Y = double(YCBCR(:,:,1));
Cb_offset = Cb-128;
Cr_offset = Cr-128;

Indx = inpolygon(Cb_offset,Cr_offset,xx,yy);
Cb(Indx)=0;
Cr(Indx)=0;
Y(Indx)=0;

se = strel('square',3);
SkinImg = imerode(255*Indx, se);
h = fspecial( 'gaussian', [21 21], 10 );
SkinImg = conv2( SkinImg, h, 'same' );
SkinImg( SkinImg<50 ) = 0;
SkinImg = imdilate( SkinImg, se );
comp_mask = bwlabel(SkinImg,4);
N = length(unique(comp_mask))-1;

for i=1:N
   ObjIdx = find(comp_mask==i);
   ObjIdx = imclose(ObjIdx,se);
   [noR, noC] = size(grayImg);
   ObjImg = zeros(noR, noC);
   ObjImg(ObjIdx) = 1;
   [ObjX, ObjY] = ind2sub(size(comp_mask),ObjIdx);
   min_y = min(ObjY);
   max_y = max(ObjY);
   min_x = min(ObjX);
   max_x = max(ObjX);
   x_diameter = max_x-min_x;
   y_diameter = max_y-min_y;
   [B,L] = bwboundaries(ObjImg,8,'noholes');
   B = B{1};
   Y = B(:,1);
   X = B(:,2);
   %[X,Y] =GetBoundary(ObjImg);
   [yDim,xDim] = size(grayImg);
   [x,y] = meshgrid(1:xDim, 1:yDim);
   [Idx, ON] = inpolygon(x,y,X,Y);
   mask = zeros(size(grayImg));
   mask(Idx) = 1;
   mask(ON) = 0;
   ObjImg = zeros(noR, noC);
   ObjImg(Idx) = grayImg(Idx);
   ObjImg = ObjImg(min_x:max_x, min_y:max_y);
   [noR, noC] = size(ObjImg);
   mask = double(mask(min_x:max_x, min_y:max_y));
   
   I = ObjImg(:);
   [indxX, indxY] = meshgrid(1:noC,1:noR);
   X = zeros(noR*noC, 6);
   X(:,1) = indxX(:).^2;
   X(:,2) = indxY(:).^2;
   X(:,3) = indxX(:) .* indxY(:);
   X(:,4) = indxX(:);
   X(:,5) = indxY(:);
   X(:,6) = ones(noR*noC,1);
   a = inv(X'*X)*X'*I;
   evalY = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
   I = I - evalY;
   I = reshape(I, noR, noC);
end

