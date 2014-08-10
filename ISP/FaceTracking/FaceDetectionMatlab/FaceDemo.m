function FaceDemo

global XX IdxXX IdxYY

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
load FaceDet;
nLoops = size( u, 2 );
ULims =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16   -8];
VLims =  [  7    12    20    27    31    28    22    16    12    7];
SkinToneLut = BuildSkinToneLut( ULims, VLims );
H = fspecial( 'gaussian', [1, 11], 21 );
% ImgRGB = vfm( 'grab', 1 );


vid = videoinput('winvideo');
ImgRGB = getsnapshot( vid );
N = 15;
Nvj = 25;
[IdxXX, IdxYY] = meshgrid( 1:N, 1:N );
XX = zeros( N*N, 3 );
XX(:,1) = IdxXX(:);
XX(:,2) = IdxYY(:);
XX(:,3) = ones( N*N, 1 );

[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'Cascade.txt' );

% Define People
MaxNPpl = 4;
MyF  = cell( 1, MaxNPpl );
MxF  = cell( 1, MaxNPpl );
SyF  = cell( 1, MaxNPpl );
SxF  = cell( 1, MaxNPpl );
SxyF = cell( 1, MaxNPpl );
Pwr  = cell( 1, MaxNPpl );

MyFlt = [];
MxFlt = [];
SyFlt = [];
SxFlt = [];
SxyFlt = [];

% Run the loop ...
for n = 1:1000,
%    ImgRGB = vfm( 'grab', 1 );
   ImgRGB = getsnapshot( vid );
   subplot(223), image( uint8( ImgRGB ) ), colormap( Map );

   Idx = DetectSkinTone( double( bitshift( ImgRGB, -3 ) ), SkinToneLut );
   Idx1 = GaussClean( double( Idx ), H, 0.3 );

   [IdxL, NGrpInit] = FindAllGroups( Idx1 );
   [IdxLL, NGrp] = RemoveSmallGroups( IdxL, NGrpInit, 500 );
   
   ImgIdx = zeros( size( Idx ) );
   if( NGrp > 0 ),
      for l = 1:NGrp,
         ImgIdx(IdxLL{l}) = 255;
      end
      subplot(221), image( ImgIdx ), colormap( Map ), title( [num2str(n), ' NGrp = ', num2str(NGrp)] );
      
      for l = 1:NGrp,
         [M0, My, Mx, Sy, Sx, Sxy, phiRad, SyR, SxR] = CalcMoments( IdxLL{l}, size(Idx,1), size(Idx,2) );
         [MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt] = FilterMoments( MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt, My, Mx, Sy, Sx, Sxy, 0.8 );

         ImgPrt = GetImagePart( ImgRGB(:,:,2), My, Mx, Sy, Sx, Sxy, 1.25 );
         %ImgPrt = imrotate( ImgPrt, 180*(phiRad+pi/2)/pi, 'bilinear', 'crop' );
         ImgPrt1 = double( imresize( ImgPrt, [N, N] ) );
         ImgPrt2 = double( imresize( ImgPrt, [Nvj, Nvj] ) );
         ImgPrt1 = RemoveLighting( ImgPrt1, N );

         Pass1 = ValidateFaceByStds( SyR, SxR, phiRad );
         Pass2 = ValidateFaceByMRC( ImgPrt1, nLoops, u, d1, d2 );
         Pass3 = ValidateFaceByVJ( ImgPrt2, NCas, NFlt, StrongTresh, Alphas, Flt );
         Pass = Pass1 * Pass2;
         
         subplot(221), line( [Mx-Sx Mx+Sx], [My My] ); line( [Mx Mx], [My-Sy My+Sy] ); drawnow;
         subplot(221), line( [Mx-SyR*cos(phiRad) Mx+SyR*cos(phiRad)], [My-SyR*sin(phiRad) My+SyR*sin(phiRad)], 'color', 'red' );
         subplot(221), line( [Mx-SxR*sin(phiRad) Mx+SxR*sin(phiRad)], [My+SxR*cos(phiRad) My-SxR*cos(phiRad)], 'color', 'red' );
         subplot(221), ellipse( SyR, SxR, phiRad, Mx, My, 'red', 20 );
         if( Pass ), subplot(221), hold on, plot( Mx, My, '*' ), hold off, end
         subplot(222), image( uint8( ImgPrt1 ) ), colormap( Map ), title( num2str(180*phiRad/pi) ), axis( 'square' );
         subplot(224), image( uint8( ImgPrt2 ) ), colormap( Map ), axis( 'square' );
         if( Pass ), subplot(223), hold on, plot( Mx, My, '*' ), hold off, end
         if( Pass3 ), subplot(223), hold on, plot( Mx+8, My, '*r' ), hold off, end
      end
   else
%       subplot(221), image( ImgIdx ), colormap( Map ), title( [num2str(n), ' NGrp = ', num2str(NGrp)] );
continue;
   end
   drawnow;
   %pause( 0.1 );
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SkinToneLut = BuildSkinToneLut( ULims, VLims )

   [g,b,r] = meshgrid( 0:31, 0:31, 0:31 );
   RGB = [r(:), g(:), b(:)];
   YUV = rgb2ycbcr( RGB*8 );
   SkinToneLut = inpolygon( YUV(:,2), YUV(:,3), ULims, VLims );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Idx = DetectSkinTone( Img, SkinToneLut )

   Idx = SkinToneLut( Img(:,:,1)*2^10 + Img(:,:,2)*2^5 + Img(:,:,3) + 1 );
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Idx = GaussClean( Img, H, Tresh )
   
   Img = conv2( Img, H,  'same' );
   Img = conv2( Img, H', 'same' );
   Idx = double( Img > Tresh );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [M0, My, Mx, Sy, Sx, Sxy, phiRad, SyR, SxR] = CalcMoments( Idx, Ny, Nx )

   M0 = length( Idx );
   [IdxY,IdxX] = ind2sub( [Ny, Nx], Idx );
   My = mean( IdxY );
   Mx = mean( IdxX );
   My2 = mean( (IdxY-My).^2 );
   Mx2 = mean( (IdxX-Mx).^2 );
   Mxy = -mean( (IdxY-My).*(IdxX-Mx) );
   Sy  = 2*sqrt( My2 );
   Sx  = 2*sqrt( Mx2 );
   Sxy = 2*sqrt( Mxy );
   tensor = [My2, Mxy; Mxy, Mx2];
   [eVecs, eVals] = eig( tensor );
   phiRad = atan2( eVecs(2,1), eVecs(1,1) ) + pi;
   SxR = 1 ./ sqrt( sin( phiRad )^2 / Sx^2 + cos( phiRad )^2 / Sy^2);
   SyR = 1 ./ sqrt( cos( phiRad )^2 / Sx^2 + sin( phiRad )^2 / Sy^2 );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ImgPrt = GetImagePart( Img, My, Mx, Sy, Sx, Sxy, F )

   Y = size( Img, 1 );
   X = size( Img, 2 );
   Y1 = max( 1, round(My-Sy/2) );
   Y2 = min( Y, round(My-Sy/2+2*F*Sx) );
   X1 = max( 1, round(Mx-F*Sx) );
   X2 = min( X, round(Mx+F*Sx) );
   
   ImgPrt = Img(Y1:Y2,X1:X2);
   
return;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Img = RemoveLighting( ImgPrt, N )

global XX IdxXX IdxYY

   a1 = inv(XX'*XX)*XX'*ImgPrt(:);
   Img1Ord = a1(1)*IdxXX(:) + a1(2)*IdxYY(:) + a1(3);
   Img = ImgPrt - reshape( Img1Ord, N, N ) + 128;
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pass = ValidateFaceByMRC( ImgPrt, nLoops, u, d1, d2 )

   for i = 1:nLoops,
      proj = u(:,i)'* ImgPrt(:);
      if( (d1(i)< proj) & (d2(i)> proj) ),
         %display( ['Cascade ', num2str(i), ' passed'] );
         Pass = 1;
      else
         %display( ['Cascade ', num2str(i), ' failed'] );
         Pass = 0;
         break;
      end
   end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IdxAll, NGrpInit] = FindAllGroups( Idx )

   IdxAll = bwlabel( Idx, 4 );
   NGrpInit = max( max( IdxAll ) );
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IdxLL, NGrp] = RemoveSmallGroups( IdxL, NGrpInit, Tresh )

   NGrp = 0;
   IdxLL = [];
   if( NGrpInit > 0 ),
      for n = 1:NGrpInit,
         IdxGrp = find( IdxL == n );
         if( length(IdxGrp) > Tresh ),
            NGrp = NGrp + 1;
            IdxLL{NGrp} = IdxGrp;
         end
      end
   end
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pass = ValidateFaceByStds( Sy, Sx, phiRad )

   if( Sy < Sx | max(Sy,Sx) > 2*min(Sy,Sx) ),
      Pass = 0;
   else
      Pass = 1;
   end
   
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt] = FilterMoments( MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt, My, Mx, Sy, Sx, Sxy, Fact )

   if( isempty(MyFlt) ),
      MyFlt = My;
   else
      MyFlt = Fact*MyFlt+(1-Fact)*My;
   end
   if( isempty(MxFlt) ),
      MxFlt = Mx;
   else
      MxFlt = Fact*MxFlt+(1-Fact)*Mx;
   end
   if( isempty(SyFlt) ),
      SyFlt = Sy;
   else
      SyFlt = Fact*SyFlt+(1-Fact)*Sy;
   end
   if( isempty(SxFlt) ),
      SxFlt = Sx;
   else
      SxFlt = Fact*SxFlt+(1-Fact)*Sx;
   end
   if( isempty(SxyFlt) ),
      SxyFlt = Sxy;
   else
      SxyFlt = Fact*SxyFlt+(1-Fact)*Sxy;
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

   Pass = 1;
   MeanMin = 12348;
   MeanMax = 140065;
   SqMin = 591320;
   VarMin = 18.0123;
   N = size( ImgPrt, 1 );
   
   I  = cumsum( cumsum( ImgPrt' )' );
   II = cumsum( cumsum( (ImgPrt.^2)' )' );
   
   I1 = I(end,end)-I(1,end)-I(end,1)+I(1,1);
   if( I1 < MeanMin | I1 > MeanMax ),
      Pass = 0;
      return;
   end
   
   I2 = II(end,end)-II(1:end)-II(end,1)-II(1,1);
   if( I2 < SqMin ),
      Pass = 0;
      return;
   end
   
   I3 = ( I1 * I1 - I2 ) / (N*N);
   if( I3 < VarMin ),
      Pass = 0;
      return;
   end
   
   for n = 1:NCas,
      Val = 0;
      for k = 1:NFlt{n},
         x1 = Flt{n}{k}(4) +1;
         x2 = Flt{n}{k}(5) +1;
         x3 = Flt{n}{k}(6) +1;
         x4 = Flt{n}{k}(7) +1;
         y1 = Flt{n}{k}(8) +1;
         y2 = Flt{n}{k}(9) +1;
         y3 = Flt{n}{k}(10)+1;
         y4 = Flt{n}{k}(11)+1;
         switch( Flt{n}{k}(3) ), % Filter type
            case( 0 ), 
               f1 = I(x1,y3) - I(x1,y1) + I(x3,y3) - I(x3,y1) + 2*(I(x2,y1) - I(x2,y3));
            case( 1 ),
               f1 = I(x3,y1) + I(x3,y3) - I(x1,y1) - I(x1,y3) + 2*(I(x1,y2) - I(x3,y2));
            case( 2 ),
               f1 = I(x1,y1) - I(x1,y3) + I(x4,y3) - I(x4,y1) + 3*(I(x2,y3) - I(x2,y1) + I(x3,y1) - I(x3,y3));
            case( 3 ),
               f1 = I(x1,y1) - I(x1,y4) + I(x3,y4) - I(x3,y1) + 3*(I(x3,y2) - I(x3,y3) + I(x1,y3) - I(x1,y2));
            case( 4 ),
               f1 = I(x1,y1) + I(x1,y3) + I(x3,y1) + I(x3,y3) - 2*(I(x2,y1) + I(x2,y3) + I(x1,y2) + I(x3,y2)) + 4*I(x2,y2);
         end

         if( Flt{n}{k}(2) ~=0 ), % Parity
            if( f1 < Flt{n}{k}(1) ),   % Weak treshold
               Val = Val + Alphas{n}(k);
            end
         else
            if( f1 >= Flt{n}{k}(1) ),
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
   