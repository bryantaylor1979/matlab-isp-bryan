function FD()
global Map
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
dirName = 'D:\face detection\pictures\2007-06-10-1224-45\';
%dirName = '..\Images\OurOffice\';
%dirName = 'D:\Development\FaceDetection\ImagesBack\2007-06-14-1731-00\';
%dirName = '..\FromIgarashi\';
%dirName = '..\Images\2007-06-14-1731-00\Resized';
%Img = double( imread( 'D:\Development\FaceDetection\FromIgarashi\DSC_9757.JPG' ) );
files = dir(strcat(dirName, '\*.jpg')); 
[nFiles,b] = size(files); 

%Paper
%xx = round( xx/size( Img,2 )* 255 ) ;
%xx = [132   132   125   118   110    99    86    87   105   128   138 ] - 128; 
%yy = [129   138   155   164   166   179   180   167   139   125   141 ] - 128;  
%figure( 102 ), line( xx, yy), hold on; 
%xx = [-11   -36   -56   -51   -37   -24    -7    -7];
%yy = [5      20    42    47    44    31    10    10];
%figure( 102 ), line( xx, yy), hold on; 


for imgFile = 1:nFiles, 
    ImgFileName = fullfile(dirName, files(imgFile).name);
    Img = double( imread( ImgFileName ) );
    
    %Img = double( imread( '../colorspace_0_255__0_255.jpg' ) );
    figure( 100 ), image( uint8( Img ) ), colormap(Map), title( 'Image' )
    
    %continue;
    %======================================================================
    %preporation analysis part -- done offline once in order to investigate
    %the skintone area
    preparation = 0;
    if ( preparation == 1 ),
        MaskFileName = strrep( strrep(files(imgFile).name,'.JPG',''), '.jpg','' );
        MaskFileName =  [MaskFileName '_Mask.jpg'];
        MaskFileName = fullfile(dirName, 'Masks', MaskFileName);

        Mask = double( imread( MaskFileName ) );
        SkinImg  = Img .* Mask/255;
        figure( 101 ), image( uint8( SkinImg ) ), colormap(Map), title( 'SkinImg' )

        ImgYCbCr = rgb2ycbcr( SkinImg ); 
        %ImgYCbCr = colorspace('YCbCr<-RGB',SkinImg);
        Y  =  ImgYCbCr(:,:,1);
        Cb =  ImgYCbCr(:,:,2);
        Cr =  ImgYCbCr(:,:,3);
      
      
        figure( 102 ), plot(  Cb, Cr, 'g.'  ), grid on, hold on 
        continue;
    end
    %======================================================================
   
    
    ImgYCbCr_A = rgb2ycbcr( Img );
    Y_A  =  ImgYCbCr_A(:,:,1);
    Cb_A =  ImgYCbCr_A(:,:,2);
    Cr_A =  ImgYCbCr_A(:,:,3);
    
    Lum  =  0.3*Img(:,:,1) + 0.6*Img(:,:,2) + 0.1*Img(:,:,3);
    
    %brows test
%     s = 3;
%     filt = [ones( 1, s) ;  zeros( 1, s);  ones( 1, s) * -1];
%     brows = abs(conv2( Lum, filt ,'same' )/s );
%     figure( 300 ), image( uint8(  Lum  ) ), hold on, colormap(Map);
%     figure( 301 ), image( uint8( brows ) ), colormap(Map);
  
     
     if (0)
      filt = [-1 0 1; -1 0 1; -1 0 1];
      edgV = abs( conv2( Lum, filt ,'same' )) ;
      edgH = abs( conv2( Lum, filt' ,'same' )) ;
      
%      edgV = medfilt2( edgV, [3 1]); 
%      edgH = medfilt2( edgH, [1 3]); 
      edges = edgH ;
      edges = (edges > 80);
      
      %h = fspecial( 'gaussian', [11 11], 5 );
      %edgesG = conv2( edges, h, 'same' );
      %edges = (edgesG > 30) * 255;
      
      %edges = medfilt2( edges, [3 3]);
      figure( 300 ), image( uint8(  edges*255  ) ), hold on, colormap(Map);
      %figure( 302 ), image( uint8(  edges ) ), colormap(Map);
      %figure( 303 ), image( uint8(  medfilt2( edgH, [1 3]) ) ), colormap(Map);
     end
     if(0)
     H1 = [-ones( 5, 50 ); ones( 5, 50)]/(5*50);
     eyesH = conv2( Lum, H1 ,'same' ) ;
     eyesH = (eyesH > 15)*255;
     figure( 303 ), image( uint8(  eyesH ) ), colormap(Map);
    
     continue;
     end
     x = Cb_A;
     y = Cr_A;
    
    %skintone polygon approximated with getpts() 
    %xx = [-11   -36   -56   -51   -37   -24    -7    -7];
    %yy = [5      20    42    47    44    31    10    10];
     
    %Efrat
    %both types - not shifted
    xx =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16 -8];
    yy =  [  7    12    20    27    31    28    22    16    12  7];
       
    Idx = 255*inpolygon(x,y, xx,yy);
    Idx( Lum < 40 | Lum > 220) = 0;
     
    se = strel('square',3);
    SkinImg = imerode( Idx, se );
    
    h = fspecial( 'gaussian', [21 21], 10 );
    SkinImgG = conv2( SkinImg, h, 'same' );
    SkinImg( SkinImgG < 50 ) = 0;
    SkinImgD = imdilate( SkinImg, se );
    
    figure( 200 ), image( uint8( Img  ) ), hold on, colormap(Map);
    %figure( 201 ), image( uint8( Idx ) ), colormap(Map);
       
    
    figure( 500 ), subplot( 2,2,1), image( uint8( Img  )), colormap(Map);
    figure( 500 ), subplot( 2,2,2), image( uint8( Idx  )), colormap(Map);
    figure( 500 ), subplot( 2,2,3), image( uint8( SkinImg )  ),colormap(Map);
    figure( 500 ), subplot( 2,2,4), image( uint8( SkinImgD )  ),colormap(Map);
    %figure( 202 ), image( uint8( SkinImgG ) ), colormap(Map);
    %figure( 203), image( uint8( SkinImgD ) ), colormap(Map);
    %figure( 204 ), image( uint8( SkinImg  ) ), colormap(Map);
    
    %============ bulks test
%     fSq = ones( 40, 40 );
%     SkinImgG_D = conv2( SkinImgD/(40*40), fSq, 'same' );
%     figure( 110 ), image( uint8( SkinImgG_D ) ), colormap(Map);
%     bulksMask = zeros( size( SkinImgG_D ));
%     bulksMask( find( SkinImgG_D > 250 ) ) = 255;
%     seBulk = strel('square',40);
%     bulksMask  =   imdilate( bulksMask, seBulk );
%     
%     SkinImgD2 = SkinImgD;
%     SkinImgD2( find( bulksMask  ) ) = 0 ; 
%     
%     figure( 111 ), image( uint8( bulksMask ) ), colormap(Map);
%     figure( 112 ), image( uint8( SkinImgD2G ) ), colormap(Map);
%     SkinImgD = SkinImgD2
%     
%     h = fspecial( 'gaussian', [21 21], 10 );
%     SkinImgG2 = conv2( SkinImgD2, h, 'same' );
%     SkinImg( SkinImgG2 < 50 ) = 0;
%     SkinImgD3 = imdilate( SkinImg, se );
%     figure( 111 ), image( uint8( SkinImgG2 ) ), colormap(Map);
    %============ end test
    
    L = bwlabel(SkinImgD,4);
    N = length( unique( L ))-1;
    
    %se = strel('disk',25);
    %SkinImgD_Closed = imclose(SkinImgD,se);
    %L_Closed        = bwlabel(SkinImgD_Closed,4);
    
    %figure( 201 ), image( uint8( SkinImgD ) ), colormap(Map);
    %figure( 202 ), image( uint8( SkinImgD_Closed ) ), colormap(Map);
  
    
    %for each label in the picture
    stats = []; 
    for( i = 1:N )
        ObjIdx = find( L == i );
        [ObjY, ObjX] = ind2sub( size( L ), ObjIdx );
        
        yM = round(mean( ObjY ));
        xM = round(mean( ObjX ));
        yS = round(std( ObjY ));
        xS = round(std( ObjX ));
         
        %yStart = round( max( 1, yM-2*yS ) );
        %yEnd   = round( max( 1, yM-3.5*yS ) );
        yStart = round( max( 1, yM-2.5*xS ) );
        yEnd   = round( max( 1, yM-5*xS ) );
        
        
        minHair = min( Img(yEnd:yStart,xM,2));
        h1 = find(  (Img(yEnd:yStart,xM,2) < 80) & ( abs(Cb_A(yEnd:yStart,xM)) < 15) & (abs(Cr_A(yEnd:yStart,xM)) < 15 )   );
        hairClassifier = ((minHair < 30) | (length(h1) > 0 ));
        %rect    = SkinImgD( round(yM-yS*2/3):round(yM+yS*2/3), round(xM-xS*2/3):round(xM+xS*2/3) );
        %numZeros  =  length( find(rect == 0) );
        
        %estimates number of holes in each region  
        objImgInv = zeros( size( L )) + 255;
        objImgInv( ObjIdx ) = 0;
        LL = bwlabel(objImgInv,4);
        NN = length( unique( LL ))-1;
        
        objSkinIdx = intersect( find( Idx~=0 ) , ObjIdx );
        cbObj = Cb_A(objSkinIdx);
        crObj = Cr_A(objSkinIdx);
        
        stats.MeanCb(i) = mean( cbObj );
        stats.MeanCr(i) = mean( crObj );
        stats.StdCb(i) = std( cbObj );
        stats.StdCr(i) = std( crObj );
        stats.Size(i) = length( ObjX );
            
          
        if (( length( ObjX ) < 400 ) || ( yS *1.5 < xS ) ...
              || (xS * 2.5 < yS) || (xS<=10 && yS<=10) ...
              || (~hairClassifier) || ( NN <=4 ) || (NN > 60 ) )
            continue;
        end 
        
        kX   = 2*xS;
        kYUp = 1.5*xS;
        kYDn = 3*xS;
        
        ObjImg = zeros( size( Idx ) );
        [NRows, NCols] = size( ObjImg ); 
        ObjImg( ObjIdx ) = 1; 
        figure( 112 ), image( uint8( ObjImg*255 ) ), colormap(Map);
 
        rect = ObjImg(  max(1,yM-kYDn):min(yM+kYUp, NRows), max(1,xM-kX):min(xM+kX,NCols));
        skinInRect = sum( rect(:) );
  
        rectClassifier = skinInRect/length( rect(:) ) > 1/3;
        if (~rectClassifier)
            continue;
        end
    
        %eyeMask = ones( kYUp/2, kX/2);
        %eyeImg = conv2( edges/length( eyeMask(:) ), eyeMask, 'same' );
        %figure( 112 ), image( uint8( eyeImg*255 ) ), colormap(Map);
          
        figure( 200 ), line( [xM-kX, xM+kX, xM+kX, xM-kX, xM-kX], ...
               [yM+kYUp, yM+kYUp, yM-kYDn, yM-kYDn, yM+kYUp], 'LineWidth', 2, 'color', 'red' ), hold on;
           
        %line( [xM xM], [yStart yEnd], 'color', 'blue' );  
        %figure( 200 ),  title([ num2str(xS), ' ',  num2str(yS), ' NN ', num2str( NN ) ]); 
        figure( 200 ),  title([ num2str(skinInRect), ' ',  num2str(length( rect(:) )), ' ', num2str(rectClassifier) ]); 
        
        %figure( 201 ), plot( yStart:-1:yEnd, Img(yEnd:yStart,xM,2) ), title('Projection for Hair'), grid   
        %yMM = round(yM+(kYUp-kYDn)/2);
        %figure( 200 ), line( [xM - xS*2, xM + xS ], [yMM, yMM], 'color', 'blue' ), hold on;
        %yy = mean( Lum(yMM-5:yMM+5, xM - xS: xM + xS),1);
        %figure( 401 ), plot( 1: xS*2+1, yy ),  axis( [0, 100, 0, 300] ), title('Projection'), grid   
         
    end
    %pause
    %preparation part - figure
    %figure( 102 ), plot(  Cb(Idx >0 ), Cr(Idx>0), 'g.', cbObj, crObj, 'r.'  ), axis( [-70, 10, -10, 60] ), grid on, hold on 
    %figure( 102 ), plot(  Cb_A, Cr_A, 'r.'  ), axis( [-70, 10, -10, 60] ), grid on, hold on 
    
    
  fileName = fullfile(dirName, 'Res', files(imgFile).name);
  figure( 200 ), axis off
  saveas(200, fileName,'jpg') 
  close( 200 )

  SkinFileName = strrep( strrep(files(imgFile).name,'.JPG',''), '.jpg','' );
  SkinFileName =  [SkinFileName '_Skin.jpg'];  
  SkinFileName = fullfile(dirName, 'Res', SkinFileName);
  saveas(500, SkinFileName ,'jpg') 
end
x = 1;
 

