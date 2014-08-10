
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = face_demo(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @face_demo_OpeningFcn, ...
                   'gui_OutputFcn',  @face_demo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function face_demo_OpeningFcn(hObject, eventdata, handles, varargin)

global XX IdxXX IdxYY Map VLims ULims N Nvj;
global SkinToneLut NOPepoles NCas NFlt StrongTresh Alphas Flt Rad RunFlag DebugFlag RotationFlag;
global MyF MxF SyF SxF SxyF ConfFArr NOFObj;


Map = linspace( 0, 1, 256 )' * ones( 1, 3 );

% ULims =round([-10.9726 -17.9551 -35.4115 -39.6509 -30.1746 -18.4539 -10.9726]+128);
% VLims = round([18.4539 13.2170 21.9451 27.9302 33.1671 26.4339 18.4539]+128);

% ULims1 =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16   -8];
% VLims1 =  [  7    12    20    27    31    28    22    16    12    7];

% ULims1 = [86    98   117   112   117   108    88    86];
% VLims1 = [160   163   146   142   134   130   145   160];%last of l27
% ULims1 = [106    99   117   118   106];%first of 105
% VLims1 = [160   152   135   148   160];
% ULims1 = [106   121   124   104    97   106];
% VLims1 = [160   147   126   132   149   160];
% ULims1 =[106   121   122   118   104    97   106];
% VLims1 =[160   147   136   129   132   149   160];
% ULims1 = [121   123   119   104    97   106   121]
% VLims1 =[147   135   129   132   149   160   147];
% ULims1 =[119   123   121   104    97    95   104   119];
% VLims1 =[129   136   147   162   159   152   133   129];
% ULims1 =[121   108    99    95   104   119   123   121];
% VLims1 =[147   165   165   152   133   129   136   147];
% ULims1 =[108    96   104   112   122   121   108];
% VLims1 =[165   152   133   132   141   147   165];
% ULims1 =[96   108   121   122   120   116   115   112   104    96];
% VLims1 =[152   165   147   141   139   140   135   132   133   152];
ULims1 =[96   108   121   109   104    96];
VLims1 =[152   165   147   133   133   152];
%    
N = 15; Nvj = 25;
DebugFlag = 0; RunFlag = 0; RotationFlag = 0;
NOFObj = 0; NOPepoles = 5;

load FaceDet;
%  if(exist('OrigSkinToneLut.mat', 'file'))
%     load OrigSkinToneLut;
%  else
   SkinToneLut = BuildSkinToneLut( ULims1, VLims1 );
%  end
   
handles.OneObjAxes{1}=handles.OneObjAxes1;
handles.OneObjAxes{2}=handles.OneObjAxes2;
handles.OneObjAxes{3}=handles.OneObjAxes3;
handles.OneObjAxes{4}=handles.OneObjAxes4;


[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'Cascade.txt' );

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = face_demo_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RunBtn_Callback(hObject, eventdata, handles)

global RunFlag ImgRGB Map ;
global MyF MxF SyF SxF SxyF NOPepoles ConfArr;
global CurrMy CurrMx CurrSy CurrSx CurrSxy NOFObj;
global vid;

RunFlag = ~RunFlag;
% vfm( 'preview', 1 );
vid = videoinput('winvideo');

if(RunFlag)
   MyF  = zeros( 1, NOPepoles );
   MxF  = zeros( 1, NOPepoles );
   SyF  = zeros( 1, NOPepoles );
   SxF  = zeros( 1, NOPepoles );
   SxyF = zeros( 1, NOPepoles );
   ConfArr = zeros( 1, NOPepoles );
   NOFObj = 0;
   set(hObject, 'String','Stop');
else
   set(hObject, 'String','Run');
   axes(handles.DebugAxes); image(zeros(550,650)), colormap(Map);
   for i=1:4
      axes(handles.OneObjAxes{i}), image(zeros(50)), colormap(Map);
   end  
end

while(RunFlag)
%    ImgRGB = vfm( 'grab', 1 );
    ImgRGB = getsnapshot(vid);
   FaceDetection(hObject, eventdata, handles);
   pause(0.00001);
end

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LoadPicBtn_Callback(hObject, eventdata, handles)

global Map RunFlag ImgRGB DebugFlag;
global PathName;

[FileName,PathName] = uigetfile('PathName\*.jpg','Select a Picture');
FileName = [PathName ,FileName];
Img = imread(FileName);
if( length(size(ImgRGB)) == 2 ),
   ImgRGB = uint8( zeros( size( Img, 1 ), size( Img, 2 ), 3 ) );
   ImgRGB(:,:,1) = uint8( Img );
   ImgRGB(:,:,2) = uint8( Img );
   ImgRGB(:,:,3) = uint8( Img );
else
   ImgRGB = uint8( Img );
end
axes(handles.VideoAxes);
hold off, image( ImgRGB ), colormap( Map );
RunFlag = 0;
set(handles.RunBtn, 'String', 'Run');
axes(handles.VideoAxes), hold off,
FaceDetection(hObject, eventdata, handles);

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SkinToneLut = BuildSkinToneLut( ULims, VLims )

   global Map;
   [g,b,r] = meshgrid( 0:31, 0:31, 0:31 );
   RGB = [r(:), g(:), b(:)];
   YUV = rgb2ycbcr( RGB*8 );
   SkinToneLut = inpolygon( YUV(:,2), YUV(:,3), ULims, VLims );
%    save('OrigSkinToneLut', 'SkinToneLut');
   
   UVFig = zeros(255);
   SkinMat = zeros(64);
   for u=0:63
      for v=0:63
           inPoly = inpolygon(u*4, v*4, ULims, VLims);
           SkinToneLutYUV(u*2^6+v+1) = inPoly; %SkinToneLutYUV(u*2^10+v*2^5+y+1) = inPoly;
           SkinMat(u+1,v+1) = inPoly;
           UVFig(4*v+1,4*u+1) = 255*inPoly;
         end
   end
   figure, image(UVFig), colormap(Map)
%    line(ULims, VLims);
   %fid = fopen('D:\DF_STW\Zoran\L2_74\L274_0206\SL\Main\Sightic\FaceDetection\SkinTonLut.txt', 'wt');
%    fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\SkinTonLut.txt', 'wt');
%    fprintf(fid, '%d, ',SkinToneLutYUV);
%    fclose(fid);
   size(find(SkinToneLutYUV))

   H = fspecial( 'gaussian', [1, 5], 9 );
   Img = conv2( SkinMat, H,  'same' );
   Img = conv2( Img, H',  'same' );
   size(find(Img))
   for u=0:63
      for v=0:63
         inPoly = inpolygon(u*4, v*4, ULims, VLims);
         SkinMat(u+1,v+1) = max(inPoly, Img(u+1,v+1));
      end
   end
   SkinMat1 = SkinMat;
   SkinMat1 = SkinMat*32;
   SkinMat2 = uint8(SkinMat1);
   tmp = SkinMat2;
   tmp = SkinMat2';
   tmp = tmp(:);
   size(tmp)
   fid = fopen('SkinTonLut.txt', 'wt');
    fprintf(fid, '%d, ',tmp);
   fclose(fid);
   size(find(tmp))

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
   phiRad = atan2( eVecs(2,1), eVecs(1,1) )+pi;
   SxR = 1 ./ sqrt( sin( phiRad )^2 / Sx^2 + cos( phiRad )^2 / Sy^2);
   SyR = 1 ./ sqrt( cos( phiRad )^2 / Sx^2 + sin( phiRad )^2 / Sy^2 );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ImgPrt = GetImagePart1 ( Idx, Img, Mx, Sx, IdxLL, F, offset )

ImgIdx = zeros( size( Idx ) );
ImgIdx(IdxLL) = 255;
 
[Y, X] = find( ImgIdx );
minX = max(1, round( min( X ) )-10-offset );
maxX = min( size( Idx, 2 ), round( max( X ) )+10+offset );
diffX =  round( maxX-minX );
minY = max( 1, round( min( Y )+10-offset ) );
maxY = min( size( Idx, 1 ), round( minY+F*diffX )-10+offset ); %maxY = min( size( Idx, 1 ), round( minY+F*diffX ) );
diffY = round( maxY-minY );

ImgPrt = Img(minY:maxY, minX:maxX);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IdxAll, NGrpInit] = FindAllGroups( Idx )

IdxAll = bwlabel( Idx, 4 );
NGrpInit = max(max( IdxAll ));
   
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
         powOfGroup(NGrp) = length(IdxGrp);
      end
   end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FaceDetection( hObject, eventdata, handles )

global Map N Nvj SkinToneLut ImgRGB DebugFlag RunFlag RotationFlag;
global NCas NFlt StrongTresh Alphas Flt;
global MyF MxF SyF SxF SxyF NOPepoles NOFObj;


axes(handles.VideoAxes);
image( uint8( ImgRGB ) ), colormap( Map );
image( ImgRGB,'ButtonDownFcn',{@AddSkinToneLut, handles} );

H = fspecial( 'gaussian', [1, 5], 9 );
Idx = DetectSkinTone( double( bitshift( ImgRGB, -3 ) ), SkinToneLut );
Idx1 = GaussClean( double( Idx ), H, 0.3 );
[IdxL, NGrpInit] = FindAllGroups( Idx1 );
[IdxLL, NGrp] = RemoveSmallGroups( IdxL, NGrpInit, 500/12 );
ObjCnt = 0;
ImgIdx = zeros( size( Idx ) );
if(RunFlag)
   CurrMy = zeros( 1, NOPepoles );
   CurrMx  = zeros( 1, NOPepoles );
   CurrSy = zeros( 1, NOPepoles );
   CurrSx = zeros( 1, NOPepoles );
   CurrSxy = zeros( 1, NOPepoles );
end

 if( NGrp == 0 )
    axes(handles.DebugAxes); hold off
    image( ImgIdx ), colormap( Map ),
 else %NGrp>0
    if(DebugFlag)
       for l = 1:NGrp,
          ImgIdx(IdxLL{l}) = l;
       end
       axes(handles.DebugAxes); hold off
       image( ImgIdx*80 ), colormap( Map ),
    end
    
    for l = 1:NGrp,   
       [M0, My, Mx, Sy, Sx, Sxy, phiRad, SyR, SxR] = CalcMoments( IdxLL{l}, size(Idx,1), size(Idx,2) );
       
       Pass3 = 0; angle = 0; offset = 0; %Rotate Image For Detection       
       if(RotationFlag)         
          if (180*phiRad/pi>45 & 180*phiRad/pi<90)
             angle = -(90-180*phiRad/pi);
             offset = 10;
          elseif (180*phiRad/pi>90 & 180*phiRad/pi<135)
             angle = -(450-180*phiRad/pi);
             offset = 10;
          end

          if(offset) %do this part only when offset!=0 - if offset=0 then check with no rotation as usual and the next block
             for k=-3:2:3 %Check with rotation
                ImgPrt = GetImagePart1( Idx, ImgRGB(:,:,2), Mx, Sx, IdxLL{l}, 1.1+k*0.1, offset);
                ImgPrt = imrotate( ImgPrt, angle, 'bilinear', 'crop' );
                if (offset)
                   ImgPrt = ImgPrt(10:end-10,5:end-10);
                end
                ImgPrt2 = double( imresize( ImgPrt, [Nvj+5, Nvj+5] ) );
                Pass3 = ValidateFaceByVJ( ImgPrt2, NCas, NFlt, StrongTresh, Alphas, Flt, hObject, eventdata, handles );
                if(Pass3)
                   ObjCnt = ObjCnt+1;
                   break;
                end
             end
          end
       end
       
       if (~Pass3)%Check without rotation;
          for k=-3:2:3
             ImgPrt = GetImagePart1( Idx, ImgRGB(:,:,2), Mx, Sx, IdxLL{l}, 1.1+k*0.1, 0);        
             if(~isempty(ImgPrt))
             ImgPrt2 = double( imresize( ImgPrt, [Nvj+5, Nvj+5] ) );
             Pass3 = ValidateFaceByVJ( ImgPrt2, NCas, NFlt, StrongTresh, Alphas, Flt, hObject, eventdata, handles );
             end
             if(Pass3)
                ObjCnt = ObjCnt+1;
                break;
             end
          end
       end
        
       if(DebugFlag) %Draw Face Candidate
          if (l<=4)
             axes(handles.OneObjAxes{l}), image(ImgPrt2), colormap(Map);
          end
       end
       
       if(RunFlag & Pass3) %Time filter the Obj
           [CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy] = AddToCurrArr( ObjCnt, CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy, My, Mx, Sy, Sx, Sxy  );
       end
       
       if(~RunFlag & Pass3)
          axes(handles.VideoAxes);
          F = 1.3
          hold on, plot( Mx-1, My-1, '*r' ), hold off
          line( [Mx-Sx Mx+Sx], [My-Sy+3 My-Sy+3] ,'Color','r' );
          line( [Mx-Sx Mx+Sx], [My-Sy+2*F*Sx+3 My-Sy+2*F*Sx+3], 'Color','r' );
          line( [Mx-Sx Mx-Sx], [My-Sy+3 My-Sy+2*F*Sx+3], 'Color','r' );
          line( [Mx+Sx Mx+Sx], [My-Sy+3 My-Sy+2*F*Sx+3], 'Color','r');
       end
       
       if(DebugFlag) %Draw Skin elipsa
          axes(handles.DebugAxes); hold on,
          line( [Mx-Sx Mx+Sx], [My My] ); line( [Mx Mx], [My-Sy My+Sy] );
          line( [Mx-SyR*cos(phiRad) Mx+SyR*cos(phiRad)], [My-SyR*sin(phiRad) My+SyR*sin(phiRad)], 'color', 'red' );
          line( [Mx-SxR*sin(phiRad) Mx+SxR*sin(phiRad)], [My+SxR*cos(phiRad) My-SxR*cos(phiRad)], 'color', 'red' );
          ellipse( SyR, SxR, phiRad, Mx, My, 'red', 20 );
       end
    end  
 end
 
 if(RunFlag & (ObjCnt | NOFObj))
    FilterObjArr( ObjCnt, CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy );
    ReArangeFilteredMoments(); %after all faces were detected rearange the filtered faces array
    DrawDetectedArea( hObject, eventdata, handles );
 end
 
 guidata(hObject, handles);
 return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DrawDetectedArea( hObject, eventdata, handles )

global NOFObj MyF MxF SyF SxF SxyF ConfArr NOPepoles; 
 F = 1.3;%Draw Face Borders
 
 axes(handles.VideoAxes); hold on,
 for i=1:NOFObj
    if(ConfArr(i)>0.5)
       hold on, plot( MxF(i)-1, MyF(i)-1, '*r' ), hold off
       line( [MxF(i)-SxF(i) MxF(i)+SxF(i)], [MyF(i)-SyF(i)+3 MyF(i)-SyF(i)+3] ,'Color','r' );
       line( [MxF(i)-SxF(i) MxF(i)+SxF(i)], [MyF(i)-SyF(i)+2*F*SxF(i)+3 MyF(i)-SyF(i)+2*F*SxF(i)+3], 'Color','r' );
       line( [MxF(i)-SxF(i) MxF(i)-SxF(i)], [MyF(i)-SyF(i)+3 MyF(i)-SyF(i)+2*F*SxF(i)+3], 'Color','r' );
       line( [MxF(i)+SxF(i) MxF(i)+SxF(i)], [MyF(i)-SyF(i)+3 MyF(i)-SyF(i)+2*F*SxF(i)+3], 'Color','r');
    end
 end
 
guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveBtn_Callback( hObject, eventdata, handles )

global ImgRGB;

[file_name,path] = uiputfile('sample.jpg','Save file name');
imwrite(ImgRGB, [path, file_name]);

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy] = AddToCurrArr( ObjCnt, CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy, My, Mx, Sy, Sx, Sxy  )
   
global  NOPepoles;

if(ObjCnt<=NOPepoles)
   CurrMy(ObjCnt) = My;
   CurrMx(ObjCnt) = Mx;
   CurrSy(ObjCnt) = Sy;
   CurrSx(ObjCnt) = Sx;
   CurrSxy(ObjCnt) = Sxy;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  FilterObjArr( ObjCnt, CurrMy, CurrMx, CurrSy, CurrSx, CurrSxy )

global NOFObj MyF MxF SyF SxF SxyF ConfArr NOPepoles;
alpha = 0.7;

UpdatedIndex = zeros( 1, NOPepoles );
UpdatedCurrIndex = zeros( 1, ObjCnt );

%The current frame contains more or equal number of objects
if(NOFObj<=ObjCnt)
   for i=1:NOFObj
      i_index = 0;
      j_index = 0;
      min_dist = 100000; %infinit
      for j=1:ObjCnt
         if(ConfArr(i)>=0.5) 
            dist = (CurrMy(j)-MyF(i))^2+(CurrMx(j)-MxF(i))^2;
            if(dist<min_dist & (UpdatedIndex(i) == 0) & (UpdatedCurrIndex(j) == 0))
               min_dist = dist;
               i_index = i;
               j_index = j;
            end
         end
      end    
      UpdatedCurrIndex(j_index) = 1; UpdatedIndex(i_index) = 1;
      MyF(i_index) = (1-alpha)*MyF(i_index) + alpha*CurrMy(j_index);
      MxF(i_index) = (1-alpha)*MxF(i_index) + alpha*CurrMx(j_index);
      SyF(i_index) = (1-alpha)*SyF(i_index) + alpha*CurrSy(j_index);
      SxF(i_index) = (1-alpha)*SxF(i_index) + alpha*CurrSx(j_index);
      SxyF(i_index) = (1-alpha)*SxyF(i_index) + alpha*CurrSxy(j_index);
      ConfArr(i_index) = 1.5;
   end
else %The current frame contains less objects
   for i=1:ObjCnt
      i_index = 0;
      j_index = 0;
      min_dist = 100000; %infinit
      for j=1:NOFObj
         if(ConfArr(j)>0.5)
            dist = (CurrMy(i)-MyF(j))^2+(CurrMx(i)-MxF(j))^2;
            if(dist<min_dist & (UpdatedIndex(j) == 0) & (UpdatedCurrIndex(i) == 0))
               min_dist = dist;
               i_index = i;
               j_index = j;
            end
         end
      end
      UpdatedCurrIndex(i_index) = 1; UpdatedIndex(j_index) = 1;
      MyF(j_index) = (1-alpha)*MyF(j_index) + alpha*CurrMy(i_index);
      MxF(j_index) = (1-alpha)*MxF(j_index) + alpha*CurrMx(i_index);
      SyF(j_index) = (1-alpha)*SyF(j_index) + alpha*CurrSy(i_index);
      SxF(j_index) = (1-alpha)*SxF(j_index) + alpha*CurrSx(i_index);
      SxyF(j_index) = (1-alpha)*SxyF(j_index) + alpha*CurrSxy(i_index);
      ConfArr(j_index) = 1.5;
   end
end

%New Face/s was/were descovered
NOUpdatedIndex = size(find( UpdatedIndex), 2 );
if(NOUpdatedIndex<ObjCnt)
   NONewObjs = ObjCnt-NOUpdatedIndex;
   NewObjsIndex = find( UpdatedCurrIndex == 0 );
   for i=1:NONewObjs
      if(NOFObj+i <= NOPepoles)
         NOFObj = NOFObj+1;
         index = NOFObj;
      else
         [index, min_val] = min(ConfArr);
      end
      MyF(index) = CurrMy(NewObjsIndex(i));
      MxF(index) = CurrMx(NewObjsIndex(i));
      SyF(index) = CurrSy(NewObjsIndex(i));
      SxF(index) = CurrSx(NewObjsIndex(i));
      SxyF(index) = CurrSxy(NewObjsIndex(i));
      ConfArr(index) = 1.5;
   end
end
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ReArangeFilteredMoments()

global NOPepoles NOFObj MyF MxF SyF SxF SxyF ConfArr;

ConfArr = ConfArr*0.8;
Id = find(ConfArr<0.5);
NOFObj = NOPepoles-length(Id); %Debug remove the ;

if(Id)
   ConfArr(Id) = 0;
   MyF(Id) = 0;
   MxF(Id) = 0;
   SyF(Id) = 0;
   SxF(Id) = 0;
   SxyF(Id) = 0;
end

[ConfArr, Id] = sort(ConfArr, 'descend');
MyF = MyF(Id);
MxF = MxF(Id);
SyF = SyF(Id);
SxF = SxF(Id);
SxyF = SxyF(Id);

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
function Pass = ValidateFaceByVJ( ImgPrt, NCas, NFlt, StrongTresh, Alphas, Flt, hObject, eventdata, handles )

global Nvj;
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

for s = 0:2:WinSize
   for t = 0:2:WinSize
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
            y1 = Flt{n}{k}(8)+1+t;
            y2 = Flt{n}{k}(9)+1+t;
            y3 = Flt{n}{k}(10)+1+t;
            y4 = Flt{n}{k}(11)+1+t;
        
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
      if(Pass)
         return;
      end
   end
end
   
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mask = BuildCircle(u, v)

global Rad;

u = double(u);
v = double(v);

% mask = zeros(Rad);
% for i=u-Rad:u-1
%    for j=v-Rad:v-1
%       if (((i-u)^2+(j-v)^2) < (Rad^2))
%          mask(i-u+Rad+1, j-v+Rad+1)=1;
%       end
%    end
% end
% mask = [mask ones(Rad, 1) fliplr(mask)];
% mask = [mask; ones(1, 2*Rad+1); flipud(mask)];


%More simple 
mask = zeros(Rad);
for i=1:Rad
   for j=1:Rad
      if (((i-Rad-1)^2+(j-Rad-1)^2) < (Rad^2))
         mask(i,j) = 1;
      end
   end
end
mask = [mask ones(Rad, 1) fliplr(mask)];
mask = [mask; ones(1, 2*Rad+1); flipud(mask)];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AddSkinToneLut(hObject, eventdata, handles)

global ImgRGB SkinToneLut Rad;

point = get(handles.VideoAxes,'currentpoint');
PntLoc = round([point(1,1), point(1,2)]);
[g,b,r] = meshgrid( 0:31, 0:31, 0:31 );
RGB = [r(:), g(:), b(:)];
YUV = rgb2ycbcr( RGB*8 );
yuv = rgb2ycbcr( double(ImgRGB(PntLoc(2), PntLoc(1), :)) );
u = round( yuv(2) );
v = round( yuv(3) );
mask = BuildCircle( u, v);
[B,L] = bwboundaries( mask, 8 );
B = B{1};
Y = B(:,1)-Rad+double(u);
X = B(:,2)-Rad+double(v);

SkinToneLutCircle = inpolygon( YUV(:,2), YUV(:,3), Y, X );
SkinToneLut = SkinToneLut | SkinToneLutCircle;
% save('SkinToneLut', 'SkinToneLut');

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DebugBtn_Callback(hObject, eventdata, handles)

global DebugFlag Map;

DebugFlag = ~DebugFlag;
if(DebugFlag)
   set(hObject, 'String','Stop-Debug');
else
   set(hObject, 'String','Debug');
   axes(handles.DebugAxes); image(zeros(550,650)), colormap(Map);
   for i=1:4
      axes(handles.OneObjAxes{i}), image(zeros(50)), colormap(Map);
   end
end
     
guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SkinToneBtn_Callback(hObject, eventdata, handles)

global SkinToneLut

load SkinToneLut;

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RadSld_Callback(hObject, eventdata, handles)

global Rad;

Rad = round(get(hObject, 'Value'));
set(hObject, 'Value', Rad);
set(handles.SldValTxt, 'String', num2str(Rad));

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RadSld_CreateFcn(hObject, eventdata, handles)

global Rad;

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'min',1);
set(hObject, 'max',10);
set(hObject, 'value',3);
Rad = 3;

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MinTxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Maxtxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SldValTxt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetectBtn_Callback(hObject, eventdata, handles)

FaceDetection( hObject, eventdata, handles )
axes(handles.VideoAxes), hold off,

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RotationCB_Callback(hObject, eventdata, handles)

global RotationFlag;

RotationFlag = ~RotationFlag;

guidata(hObject, handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y] = swap(x,y)

temp = x;
x = y;
y = temp;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  ScaledImg = ScaleRGBImg(Img, XFactor, YFactor)

Img = double(Img);
[OrigXDim,OrigYDim, x]=size(Img);

NewXDim  = floor(OrigXDim/XFactor);
NewYDim  = floor(OrigYDim/YFactor);
ScaledImg = double(zeros(NewXDim,NewYDim,x));

for rgb=1:x
   k=1; l=1;
   for i=1:XFactor:OrigXDim
      l=1;
      for j=1:YFactor:OrigYDim
         ScaledImg(k,l, rgb)=Img(i,j,rgb);
         l=l+1;
      end
      k=k+1;
   end
end

ScaledImg = uint8(ScaledImg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ULims =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16   -8];
% VLims =  [  7    12    20    27    31    28    22    16    12    7];


 %        ImgPrt = GetImagePart( ImgRGB(:,:,2), My, Mx, Sy, Sx, Sxy, 1.25 );
      %       ImgPrt1 = double( imresize( ImgPrt, [N, N] ) );   
      %       ImgPrt1 = RemoveLighting( ImgPrt1, N );     
      %       Pass1 = ValidateFaceByStds( SyR, SxR, phiRad );
      %       Pass2 = ValidateFaceByMRC( ImgPrt1, nLoops, u, d1, d2 );
      %       Pass =  Pass1* Pass2;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function isValid = validFace(x,y, Idx, imgSize)
% 
% [Y, X] = ind2sub(imgSize,Idx);
% numOfPixels = inpolygon(y, x, Y, X);
% 
% return;

%          else %if(Pass)
%             hold on, plot( Mx, My, '*b' ), hold off
%             line( [Mx-Sx Mx+Sx], [My-Sy My-Sy] ,'Color','b' );
%             line( [Mx-Sx Mx+Sx], [My-Sy+2*F*Sx My-Sy+2*F*Sx], 'Color','b' );
%             line( [Mx-Sx Mx-Sx], [My-Sy My-Sy+2*F*Sx], 'Color','b' );
%             line( [Mx+Sx Mx+Sx], [My-Sy My-Sy+2*F*Sx], 'Color','b');

%H = fspecial( 'gaussian', [1, 11], 21 );


% figure( 2 ),
% hold on,plot3( YUV(:,2), YUV(:,3), SkinToneLut, '*' ), grid;
% plot3(Y,X,zeros(size(X)),'*b')
% plot3( u, v, 0, '*r' ), hold off


% axes(handles.DebugAxes); 
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] );
% axes(handles.VideoAxes);
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] ); 



% axes(handles.DebugAxes); 
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] );
% axes(handles.VideoAxes);
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] ); 
% for i=1:4
%    axes(handles.OneObjAxes{i})
%    set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] );
% end
 
% axes(handles.DebugAxes); 
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] );
% axes(handles.VideoAxes);
% set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] ); 
% for i=1:4
%    axes(handles.OneObjAxes{i})
%    set( gca, 'XTick', [], 'YTick', [], 'XTickLabel', [], 'YTickLabel', [] );
% end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Img = RemoveLighting( ImgPrt, N )
% 
% global XX IdxXX IdxYY
% 
%    a1 = inv(XX'*XX)*XX'*ImgPrt(:);
%    Img1Ord = a1(1)*IdxXX(:) + a1(2)*IdxYY(:) + a1(3);
%    Img = ImgPrt - reshape( Img1Ord, N, N ) + 128;
%    
% return;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Pass = ValidateFaceByMRC( ImgPrt, nLoops, u, d1, d2 )
% 
%    for i = 1:nLoops,
%       proj = u(:,i)'* ImgPrt(:);
%       if( (d1(i)< proj) & (d2(i)> proj) ),
%          Pass = 1;
%       else
%          Pass = 0;
%          break;
%       end
%    end
% 
% return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function Pass = ValidateFaceByStds( Sy, Sx, phiRad )
% 
%    if( Sy < Sx | max(Sy,Sx) > 2*min(Sy,Sx) ),
%       Pass = 0;
%    else
%       Pass = 1;
%    end
%    
% return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ImgPrt = GetImagePart( Img, My, Mx, Sy, Sx, Sxy, F)
% 
% Y = size( Img, 1 );
% X = size( Img, 2 );
% 
% Y1 = max( 1, round(My-2*F*Sx) ); %    Y1 = max( 1, round(My-Sy/2) ); %
% Y2 = min( Y, round(Mx+2*F*Sx) );%    Y2 = min( Y, round(My-Sy/2+2*F*Sx) );%
% X1 = max( 1, round(Mx-F*Sx) );
% X2 = min( X, round(Mx+F*Sx) );
% 
% ImgPrt = Img(Y1:Y2,X1:X2);
% return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt] = FilterMoments( MyFlt, MxFlt, SyFlt, SxFlt, SxyFlt, My, Mx, Sy, Sx, Sxy, Fact )
% 
%    if( isempty(MyFlt) ),
%       MyFlt = My;
%    else
%       MyFlt = Fact*MyFlt+(1-Fact)*My;
%    end
%    if( isempty(MxFlt) ),
%       MxFlt = Mx;
%    else
%       MxFlt = Fact*MxFlt+(1-Fact)*Mx;
%    end
%    if( isempty(SyFlt) ),
%       SyFlt = Sy;
%    else
%       SyFlt = Fact*SyFlt+(1-Fact)*Sy;
%    end
%    if( isempty(SxFlt) ),
%       SxFlt = Sx;
%    else
%       SxFlt = Fact*SxFlt+(1-Fact)*Sx;
%    end
%    if( isempty(SxyFlt) ),
%       SxyFlt = Sxy;
%    else
%       SxyFlt = Fact*SxyFlt+(1-Fact)*Sxy;
%    end
% 
% return;

% [IdxXX, IdxYY] = meshgrid( 1:N, 1:N );
% XX = zeros( N*N, 3 );
% XX(:,1) = IdxXX(:);
% XX(:,2) = IdxYY(:);
% XX(:,3) = ones( N*N, 1 );

