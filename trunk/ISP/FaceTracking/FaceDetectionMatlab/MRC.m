
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
% Set sizes
NImg = 2400;
N = 24;
Nx = 15; Ny = 15;

% Prepare Mask
quartMask = ones(floor(Nx/2), floor(Ny/2));
quartMask(1, 1:4)=0;
quartMask(2, 1:3)=0;
quartMask(3:4, 1:2)=0;
quartMask(5:6, 1)=0;
halfMask = [quartMask ones(floor(Nx/2),1) fliplr(quartMask)];
Mask = [halfMask; ones(1,Nx); flipud(halfMask)];

% Prepare Light Normalization matrix
Mask = ones(Nx, Ny);
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
   load NoMaskFacesImgLearn;
   load NoMaskFacesImgTest;
else
   % Read Faces Vectors and normalize
   FacesImgLearn = zeros( NPix, NImg );
   FacesImgTest = zeros( NPix, NImg );
   dirName = 'D:\face detection\FaceDetect_V1.3\data\';
   fid = fopen( [dirName, 'datasetMike.dat'] );
   fread( fid, 5, 'uchar' );

   for n = 1:2*NImg,
      fread( fid, 9, 'uchar' );
      NewImg = double( fread( fid, [N, N], 'uchar' )' );
      NewImg = imresize( NewImg, [Ny, Nx], 'bicubic' );
      NewImg = NewImg(:);
      %       NewImg = Mask .* NewImg;
      %       IdX = find(NewImg);
      %       NewImg = NewImg(IdX);

      a1 = inv(X1'*X1)*X1'*NewImg;
      Img1Ord = a1(1)*idxXFull(:) + a1(2)*idxYFull(:) + a1(3);
      NewImg1Ord = NewImg - Img1Ord + 128;
      if(n<=NImg)
         FacesImgLearn(:,n) = NewImg1Ord;
      else
         FacesImgTest(:,n-NImg) = NewImg1Ord;
      end
   end
   fclose( fid );
   save('NoMaskFacesImgLearn', 'FacesImgLearn');
   save('NoMaskFacesImgTest', 'FacesImgTest');
end

if(exist('NoMaskNonFacesImg.mat', 'file'))
   load NoMaskNonFacesImg;
else
   %Read Non Faces Vectors%%%%%%%%%%%%%%%%%%%%%%%%
   NonFacesLen = 100000;
   NonFacesImg = zeros( NPix, NonFacesLen );
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
            Tmp = double(Tmp);
            Tmp = Tmp(:);
            %             Tmp  = Mask .* Tmp;
            %             Tmp = Tmp(:);
            %             IdX = find(Tmp);
            %             Tmp = Tmp(IdX);
            %             a1 = inv(X1'*X1)*X1'*Tmp;
            %             Img1Ord = a1(1)*idxX(:) + a1(2)*idxY(:) + a1(3);
            %             Tmp = Tmp - Img1Ord + 128;
            NonFacesImg(:,kk) = Tmp;
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
   save('NoMaskNonFacesImg', 'NonFacesImg');
end

FacesImgLearn(FacesImgLearn<0) = 0;
FacesImgLearn(FacesImgLearn>255) = 255;
FacesImgTest(FacesImgLearn<0) = 0;
FacesImgTest(FacesImgLearn>255) = 255;
NonFacesLen = length(NonFacesImg);



% Calculating Cascades%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mx = sum(FacesImgLearn')' / NImg;
A = FacesImgLearn-Mx*ones(1,NImg);
AAt = A * A';
Rxx = AAt;

nLoops = 15;
d1 = double(zeros(1,nLoops)); 
d2 = double(zeros(1,nLoops)); 
u = double(zeros(NPix,nLoops)); 

for i = 1:nLoops,
   My = sum(NonFacesImg')' / NonFacesLen;
   B = NonFacesImg-My*ones(1,NonFacesLen);
   Ryy = B * B';
   Rxy = (My-Mx)*(My-Mx)';
   
   BBt = Rxx + Ryy + Rxy;
   [U, D] = eig( AAt, BBt );
   d = diag( D );
   [minD, indx] = min( d );
   u(:,i) = U(:,indx); %eigen vector the correspond to the smallest eigen value

%    if( i == 1 | i == nLoops ),
%       figure( 10*i+1 ), title( ['Iter = ', num2str(i)] );
%       subplot(221), imagesc( Rxx ), colormap( Map ), title( 'Rxx == AAt' )
%       subplot(222), imagesc( Ryy ), colormap( Map ), title( 'Ryy' )
%       subplot(223), imagesc( Rxy ), colormap( Map ), title( 'Rxy' )
%       subplot(224), imagesc( BBt ), colormap( Map ), title( 'BBt' )
% 
%       figure( 10*i+2 ),
%       subplot(321), imagesc( reshape( U(:,1), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMin'] );
%       subplot(322), imagesc( reshape( U(:,2), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMin+1'] );
%       subplot(323), imagesc( reshape( U(:,end), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMax'] );
%       subplot(324), imagesc( reshape( U(:,end-1), 15, 15 ) ), colormap( Map ), axis( 'image' ), title( ['Iter = ', num2str(i), 'EigMax-1'] );
%       subplot(325), plot( d ), grid, title( 'd' );
%    end
   InnerProdNonFaces = u(:,i)' * NonFacesImg;
   InnerProdFaces = u(:,i)' * FacesImgLearn;
   [InnerSorted, InnerIdx] = sort( InnerProdFaces );
   d1(i) = InnerSorted(3);
   d2(i) = InnerSorted(end-2);

   e1(i) = min( InnerProdNonFaces );
   e2(i) = max( InnerProdNonFaces );

   if((d1(i) <= e1(i)) & (d2(i) >= e2(i)))
      nLoops = i;
      break;
   end
   
   figure( 4 ), subplot(4,4,i),
   plot( InnerProdFaces, zeros( size(InnerProdFaces) ), '*r', InnerProdNonFaces, ones( size(InnerProdNonFaces) ) , '*b', d1(i), -1, '*g', d2(i), -1, '*g' ),
   grid, title( ['Iter = ', num2str( i )] ),
   axis( [min( [InnerProdFaces(:); InnerProdNonFaces(:)] ), max( [InnerProdFaces(:); InnerProdNonFaces(:)] ), -10, 11] );

   indices = find( (InnerProdNonFaces > d1(i)) &  (InnerProdNonFaces < d2(i)) ); %find all indicies of non-faces that intersect with faces cluster
   NonFacesLen = length(indices);
   NonFacesImg = NonFacesImg(:,indices);
   
   if(NonFacesLen == 0)
      nLoops = i;
      break;
   end   
end

%Classification Process%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Example Lets take the first Face Image and see 
%if all the cascade tests were successful  
load NoMaskNonFacesImg
load NoMaskFacesImgTest

Res = zeros( 1, NImg );
for n = 1:NImg,
   %        face = FacesImgLearn(:,n);
   %         face = FacesImgTest(:,n);
   face = NonFacesImg(:,n);
   Pass = 1;
   for i = 1:nLoops,
      proj = u(:,i)'* face;
      if( (d1(i)< proj) & (d2(i)> proj) )
         continue;
      else
         Pass = 0;
         break;
      end
   end
   Res(n) = Pass;
end

Img = imread('D:\face detection\pictures\2007-06-10-1224-45\DSCF0439.JPG');
grayImg = rgb2gray(Img);

%Trail 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScaledgrayImg=imresize(grayImg,[40,85] , 'bicubic');
figure, imshow(ScaledgrayImg), hold on;
[m,n] = size(ScaledgrayImg);

halfHSize = floor(Ny/2);
halfVSize = floor(Nx/2);
for i = halfHSize+1:m-halfHSize;
   for j = halfVSize+1:n-halfVSize
      PartImg = ScaledgrayImg(i-halfHSize:i+halfHSize,j-halfVSize:j+halfVSize)+1;
      PartImg = double(PartImg);
%       PartImg = Mask .* PartImg; 
%       IdX = find(PartImg);
%       PartImg = PartImg(IdX);
      PartImg = PartImg(:);
      %       a = inv(X'*X)*X'*PartImg;
      %       evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 +
      %       a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
      %       evalY1Order = a(4)*indxX(:) + a(5)*indxY(:) + a(6);
      %       PartImg = PartImg - evalY1Order;
      a1 = inv(X1'*X1)*X1'*PartImg;
      Img1Ord = a1(1)*idxXFull(:) + a1(2)*idxYFull(:) + a1(3);
      PartImg = PartImg - Img1Ord;
      PartImg = PartImg(:)+128;
      passFlag = 1;
      for k=1:nLoops,
         proj = u(:,k)'* PartImg;
         if ((d1(k)<= proj) & (d2(k)>= proj))
            continue;
         else
            passFlag = 0;
            break;
         end
      end

      if(passFlag)
         plot(j,i, '*r');
%       else
%          plot(j,i, '*b');
      end

   end
 end


%Detect connected component using skin color%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
YCBCR = rgb2ycbcr(Img);

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

% figure, image(comp_mask*80), colormap(Map)
for i=1:N
   %    %Get Component Bounderies%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ObjIdx = find(comp_mask==i);
   ObjIdx = imclose(ObjIdx,se);
   [noR, noC] = size(grayImg);
   ObjImg = zeros(noR, noC);
   ObjImg(ObjIdx) = 1;
   [ObjX, ObjY] = ind2sub(size(comp_mask),ObjIdx);
   min_y = min(ObjY);
   max_y = max(ObjY);
   min_x = min(ObjX);
   max_x = floor(1.2*(max_y-min_y) + min_x);
   ObjImg = grayImg(min_x:max_x, min_y:max_y)+1;
   [noR, noC] = size(ObjImg);
   %Scale The Image%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   scaledObjImg = imresize(ObjImg,[Ny, Nx], 'bicubic');
   scaledObjImg = double(scaledObjImg);
%    scaledObjImg = Mask .* scaledObjImg;
%    IdX = find(scaledObjImg);
%    scaledObjImg = scaledObjImg(IdX);
   scaledObjImg = scaledObjImg(:);
   %Calculate 2 Order Polynomial of the Image%%%%%%%%%%%%%%%%%%%%%
   %and reduce it from the Original Image%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   a1 = inv(X1'*X1)*X1'*scaledObjImg;
   Img1Ord = a1(1)*idxXFull(:) + a1(2)*idxYFull(:) + a1(3);
   scaledObjImg = scaledObjImg - Img1Ord+128;
   
   %    a = inv(X'*X)*X'*scaledObjImg;
   %    evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
   %    scaledObjImg = scaledObjImg - evalY2Order;
   %
   %Classification Process%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Example Lets take the first Face Image and see
   %if all the cascade tests were successful
   passFlag=1;
   for j=1:nLoops,
      proj = u(:,j)'* scaledObjImg;
      if ((d1(j)< proj) & (d2(j)> proj))
         %          display( ['Cascade ' ,num2str(j) ,' passed'] );
         continue;
      else
         %          display( ['Cascade ' ,num2str(j) ,' failed'] );
         passFlag = 0;
         break;
      end
   end
   
   if(passFlag)
      display( ['Obj ' ,num2str(i) ,' passed'] );
   else
      display( ['Obj ' ,num2str(i) ,' failed in cascade - ', num2str(j)] );
   end
   
end


% function a = chess(pic, dim1, dim2)
% 
% TmpPic = zeros(dim1/2*dim2,1);
% k=1;
% 
% for i=1:dim1,
%    for j=1:dim2
%       if((mod(j,2)==1) & (mod(i,2)==1))
%         TmpPic(k) = pic(i,j);
%         k = k+1;
%       elseif (mod(j,2)==0) & (mod(i,2)==0)
%          TmpPic(k) = pic(i,j);
%          k = k+1;
%       end
%    end
% end
% a = TmpPic;
% end
% 
% 
% 
% 
% function [a, b] = calcBorders(Proj)
% 
% [h,x] = hist(Proj,64);
% 
% histSum = cumsum(h);
% minHistI = floor(x(1));
% maxHistI = floor(x(length(h)));
% maxHist = histSum(length(histSum));
% 
% Top = 0;
% Botton = 0;
% TopFlag = 1;
% BottomFlag = 1;
% 
% for i = 1:length(h)
%    if(((histSum(i)/maxHist)>0.05) & BottomFlag)
%       Bottom  = i;
%       BottomFlag = 0;
%    end
%    if(((histSum(i)/maxHist)>0.95) & TopFlag)
%       Top  = i;
%       TopFlag = 0;
%       break;
%    end
% end
% a = x(Bottom);
% b = x(Top);
% 
% end

