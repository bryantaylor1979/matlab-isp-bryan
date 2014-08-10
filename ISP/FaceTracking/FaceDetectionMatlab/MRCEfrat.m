function a = MRC()
%Read Faces Vectors%%%%%%%%%%%%%%%%%%%%%%%%
%resize Faces images from 24*24 To 15*15
N = 40;
n = 24;
newSize = [12, 12];  % [Y, X]
epsilon = 0 ;%0.01;
% FacesImg = zeros( N*newSize(1), N*newSize(2) );
% FacesImg0Order = zeros( N*newSize(1), N*newSize(2) );
% FacesImg1Order = zeros( N*newSize(1), N*newSize(2) );
% FacesImg2Order = zeros( N*newSize(1), N*newSize(2) );

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
FacesMat = zeros(newSize(1)*newSize(2), N^2);
NonFacesLen = 100000;
NonFacesMat = zeros(newSize(1)*newSize(2), NonFacesLen);

nLoops = 30;
d1 = double(zeros(1,nLoops));
d2 = double(zeros(1,nLoops));
e1 = double(zeros(1,nLoops));
e2 = double(zeros(1,nLoops));
u = double(zeros(newSize(1)*newSize(2),nLoops));

[indxX, indxY] = meshgrid(1:newSize(2),1:newSize(1));
X = zeros(newSize(1)*newSize(2), 6);
X(:,1) = indxX(:).^2;
X(:,2) = indxY(:).^2;
X(:,3) = indxX(:) .* indxY(:);
X(:,4) = indxX(:);
X(:,5) = indxY(:);
X(:,6) = ones(newSize(1)*newSize(2),1);

dirName = 'C:\Efrat\face-detection\FaceDetect_V1.3\data\';
fid = fopen([dirName, 'datasetMike.dat']); % fopen( 'D:\face detection\FaceDetect_V1.3\data\datasetTrainValid.dat' );
fread( fid, 5, 'uchar' );

% if(exist('NonFacesMat.mat', 'file'))
%    load NonFacesMat;
%    load FacesMat;
%    buildCascadesFlag = 0;
% else
   buildCascadesFlag = 1;
% end


if(buildCascadesFlag)
   %Read Faces Vectors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ii = 1;
   jj = 1;
   for i = 1:N,
      jj = 1;
      for j = 1:N,
         fread( fid, 9, 'uchar' );
         NewImg = uint8( fread( fid, [n, n], 'uchar' )' );
         NewImg = imresize(NewImg, newSize, 'bicubic');
         FacesImg(ii:ii+newSize(2)-1, jj:jj+newSize(1)-1) = NewImg;
         NewImg = NewImg(:);
         NewImg = double(NewImg);
         %Calculate 2 Order Polynomial of the Image%%%%%%%%%%%%%%%%%%%%%
         %and reduce it from the Original Image%%%%%%%%%%%%%%%%%%%%%%%%%
         a = inv(X'*X)*X'*NewImg;
         evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
         %          evalY1Order = a(4)*indxX(:) + a(5)*indxY(:) + a(6);
         Img2Order = NewImg - evalY2Order;
         %          Img0Order = NewImg - mean(NewImg(:));
         Img2Order = reshape( Img2Order, newSize(2), newSize(1) );
         FacesImg2Order(ii:ii+newSize(1)-1, jj:jj+newSize(2)-1) = Img2Order;       
         FacesMat(:,(i-1)*N+j) = Img2Order(:);
         jj = jj + newSize(1);
      end
      ii = ii + newSize(1);
   end
   %    figure(10),image(FacesImg), colormap(Map), title( 'Original Faces' );
   %    figure(11),image(FacesImg0Order+128), colormap(Map), title( 'Faces - 0 Order' );
   %    figure(12),image(FacesImg1Order+128), colormap(Map), title( 'Faces - 1 Order' );
     figure(13),image(FacesImg2Order+128), colormap(Map), title( 'Faces - 2 Order' );
     save('FacesMat','FacesMat')
    fclose(fid);
   %Read Non Faces Vectors%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   dirName = 'C:\WuJX\SkinColor\non-skin-images';
   files = dir(strcat(dirName, '\*.jpg'));
   [nFiles,b] = size(files);

   exitFlag = 0;
   kk = 1; %Picures index
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

      nn = floor(nn/newSize(1));
      mm = floor(mm/newSize(2));
      ii = 1;
      jj = 1;
      for i=1:nn

         if(exitFlag)
            break;
         end
         jj = 1;

         for j=1:mm
            NewImg = Img(ii:ii+newSize(2)-1, jj:jj+newSize(1)-1);
            NewImg = double(NewImg);
            NewImg = NewImg(:);
            a = inv(X'*X)*X'*NewImg;
            evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
            %             evalY1Order = a(4)*indxX(:) + a(5)*indxY(:) + a(6);
            Img2Order = NewImg - evalY2Order;
            Img2Order = reshape( Img2Order, newSize(2), newSize(1) );
            NonFacesMat(:,kk) = Img2Order(:);
            kk = kk + 1;
            if(kk >= NonFacesLen)
               exitFlag = 1;
               break;
            end
            jj = jj + newSize(2);
         end
         ii = ii + newSize(1);
      end
   end

end

 save('NonFacesMat', 'NonFacesMat');
% save('FacesMat', 'FacesMat');

%  NotTrainedFaces = FacesMat(:, 361:400);
%  FacesMat = FacesMat(:, 1:360);

% Calculating Cascades%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(FacesMat);
Mx = (1/n)*sum(FacesMat')';
A = FacesMat-Mx*ones(1,n);
Rxx = A * A';
AAt = A * A';

NonFacesMat = single(NonFacesMat);
NonFaceSample = NonFacesMat(:,1);
for i=1:nLoops
   My = (1/NonFacesLen)*sum(NonFacesMat')';
   B = NonFacesMat-My*ones(1,NonFacesLen);
   Ryy = B * B';

   BBt = Rxx + Ryy + (My-Mx)*(My-Mx)';
   [U, D] = eig(AAt,BBt);
   d = diag( D );
   [minD, indx] = min( d );
   u(:,i) = U(:,indx); %eigen vector the correspond to the smallest eigen value

   muiX = u(:,i)' * Mx;
   muiY = u(:,i)' * My;  
   SigmaX = sqrt(abs(u(:,i)' * Rxx * u(:,i)));
   SigmaY = sqrt(abs(u(:,i)' * Ryy * u(:,i)));

   InnerProdNonFaces = u(:,i)' * NonFacesMat;
   InnerProdFaces = u(:,i)' * FacesMat;

%    [hNonFaces,xNonFaces] = hist(InnerProdNonFaces,64);
%    hNonFaces = hNonFaces / sum( hNonFaces );
%    [hFaces, xFaces] = hist(InnerProdFaces,64);
%    hFaces = hFaces / sum( hFaces );
   [d1(i), d2(i)] = calcBorders(InnerProdFaces);
   
%    figure, plot( xNonFaces, hNonFaces, 'r', xFaces, hFaces, 'b' ), title(['iteration-', num2str(i)]), legend('Non faces','Faces',2);
   
%    PNonFacesGivenX = (1/(sqrt(2*pi)*SigmaX))*exp(-((InnerProdNonFaces-muiX*ones(1,NonFacesLen)) .^ 2))/(2*SigmaX^2);
%    PNonFacesGivenY = (1/(sqrt(2*pi)*SigmaY))*exp(-((InnerProdNonFaces-muiY*ones(1,NonFacesLen)) .^ 2))/(2*SigmaY^2);
   
%     figure, plot(InnerProdNonFaces, ones(1,length(InnerProdNonFaces)), '*r', InnerProdFaces, zeros(1,length(InnerProdFaces)), '*b' ), legend('non-faces', 'faces',2), axis;
%    d1(i) = min( InnerProdFaces )-epsilon;
%    d2(i) = max( InnerProdFaces )+epsilon;
 
   e1(i) = min( InnerProdNonFaces )-epsilon;
   e2(i) = max( InnerProdNonFaces )+epsilon;

   if((d1(i) <= e1(i)) & (d2(i) >= e2(i)))
      nLoops = i;
      break;
   end
   %    display ([d1(i),d2(i)])
   indices = find( (InnerProdNonFaces >= d1(i)) &  (InnerProdNonFaces <= d2(i)) ); %find all indicies of non-faces that intersect with faces cluster
   NonFacesLen = length(indices);
   NonFacesMat = NonFacesMat(:,indices);
   if(NonFacesLen == 0)
      nLoops = i;
      break;
   end

end

Img = imread('D:\face detection\pictures\2007-06-10-1224-45\DSCF0439.JPG');
grayImg = rgb2gray(Img);

%Trail 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grayImg=imresize(grayImg,[40,85] , 'bicubic');
figure, imshow(grayImg), hold on;
[m,n] = size(grayImg);

halfHSize = floor(newSize(2)/2);
halfVSize = floor(newSize(1)/2);
for i = halfHSize+1:m-halfHSize;
   for j = halfVSize+1:n-halfVSize
      PartImg = grayImg(i-halfHSize:i+halfHSize-1,j-halfVSize:j+halfVSize-1);
      PartImg = double(PartImg);
      PartImg = PartImg(:);

      a = inv(X'*X)*X'*PartImg;
      evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
      %       evalY1Order = a(4)*indxX(:) + a(5)*indxY(:) + a(6);
      PartImg = PartImg - evalY2Order;
      PartImg = reshape( PartImg, newSize(2), newSize(1) );
      PartImg = PartImg(:);
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
      end

   end
end
%Trail 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for i=1:N^2,
%    passFlag = 1;
%    Face = FacesMat(:,i); %+0.1*rand(size(FacesMat(:,i)))-0.05;
%    Face(100) = Face(100)-1;
%    for k=1:nLoops,
%       proj = u(:,k)'* Face;
%       if ((d1(k)<= proj) & (d2(k) >= proj))
%          continue;
%       else
%          %         display(['Image', num2str(i), 'Failed']);
%          passFlag = 0;
%          break;
%       end
%    end
% 
%    if(passFlag)
%       display(['Image', num2str(i), 'Passed']);
%    end
% end
end


%Detect connected component using skin color%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YCBCR = rgb2ycbcr(Img);
%
% xx =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16 -8];
% yy =  [  7    12    20    27    31    28    22    16    12  7];
%
% Cb = double(YCBCR(:,:,2));
% Cr = double(YCBCR(:,:,3));
% Y = double(YCBCR(:,:,1));
% Cb_offset = Cb-128;
% Cr_offset = Cr-128;
%
% Indx = inpolygon(Cb_offset,Cr_offset,xx,yy);
% Cb(Indx)=0;
% Cr(Indx)=0;
% Y(Indx)=0;
%
% se = strel('square',3);
% SkinImg = imerode(255*Indx, se);
% h = fspecial( 'gaussian', [21 21], 10 );
% SkinImg = conv2( SkinImg, h, 'same' );
% SkinImg( SkinImg<50 ) = 0;
% SkinImg = imdilate( SkinImg, se );
% comp_mask = bwlabel(SkinImg,4);
% N = length(unique(comp_mask))-1;
%
% for i=1:N

%    %Get Component Bounderies%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ObjIdx = find(comp_mask==i);
%    ObjIdx = imclose(ObjIdx,se);
%    [noR, noC] = size(grayImg);
%    ObjImg = zeros(noR, noC);
%    ObjImg(ObjIdx) = 1;
%    [ObjX, ObjY] = ind2sub(size(comp_mask),ObjIdx);
%    min_y = min(ObjY);
%    max_y = max(ObjY);
%    min_x = min(ObjX);
%    max_x = floor(1.3*(max_y-min_y) + min_x);
%    % max_x = max(ObjX);
%
%    ObjImg = grayImg(min_x:max_x, min_y:max_y);
%
%    [noR, noC] = size(ObjImg);
%    %Scale The Image%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    scaledObjImg = imresize(ObjImg, newSize, 'bicubic');
%
%    %Calculate 2 Order Polynomial of the Image%%%%%%%%%%%%%%%%%%%%%
%    %and reduce it from the Original Image%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    scaledObjImg = double(scaledObjImg);
%    scaledObjImg = scaledObjImg(:);
%    a = inv(X'*X)*X'*scaledObjImg;
%    evalY2Order = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
%    scaledObjImg = scaledObjImg - evalY2Order;
%
%
%Classification Process%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Example Lets take the first Face Image and see
%if all the cascade tests were successful
% face = FacesMat(:,1);

%    for i=1:nLoops,
%       proj = u(:,i)'* scaledObjImg;
%       if ((d1(i)< proj) & (d2(i)> proj))
%          display( ['Cascade ' ,num2str(i) ,' passed'] );
%       else
%          display( ['Cascade ' ,num2str(i) ,' failed'] );
%          break;
%       end
%    end
% end


%
%    ObjImg = ObjImg(:);
%    [indxX, indxY] = meshgrid(1:noC,1:noR);
%    X = zeros(noR*noC, 6);
%    X(:,1) = indxX(:).^2;
%    X(:,2) = indxY(:).^2;
%    X(:,3) = indxX(:) .* indxY(:);
%    X(:,4) = indxX(:);
%    X(:,5) = indxY(:);
%    X(:,6) = ones(noR*noC,1);
%    a = inv(X'*X)*X'*ObjImg;
%    evalY = a(1)*indxX(:).^2 + a(2)*indxY(:).^2 + a(3)*indxX(:).*indxY(:) + a(4)*indxX(:) + a(5)*indxY(:) + a(6);
%    ObjImg = ObjImg - evalY;
%    ObjImg = reshape(ObjImg, noR, noC);

function a = chess(pic, dim1, dim2)

TmpPic = zeros(dim1/2*dim2,1);
k=1;

for i=1:dim1,
   for j=1:dim2
      if((mod(j,2)==1) & (mod(i,2)==1))
        TmpPic(k) = pic(i,j);
        k = k+1;
      elseif (mod(j,2)==0) & (mod(i,2)==0)
         TmpPic(k) = pic(i,j);
         k = k+1;
      end
   end
end
a = TmpPic;
end




function [a, b] = calcBorders(Proj)

[h,x] = hist(Proj,64);

histSum = cumsum(h);
minHistI = floor(x(1));
maxHistI = floor(x(length(h)));
maxHist = histSum(length(histSum));

Top = 0;
Botton = 0;
TopFlag = 1;
BottomFlag = 1;

for i = 1:length(h)
   if(((histSum(i)/maxHist)>0.05) & BottomFlag)
      Bottom  = i;
      BottomFlag = 0;
   end
   if(((histSum(i)/maxHist)>0.95) & TopFlag)
      Top  = i;
      TopFlag = 0;
      break;
   end
end
a = x(Bottom);
b = x(Top);

end

