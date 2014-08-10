function varargout = face_detection(varargin)
% FACE_DETECTION M-file for face_detection.fig
%      FACE_DETECTION, by itself, creates a new FACE_DETECTION or raises the existing
%      singleton*.
%
%      H = FACE_DETECTION returns the handle to a new FACE_DETECTION or the handle to
%      the existing singleton*.
%
%      FACE_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE_DETECTION.M with the given input arguments.
%
%      FACE_DETECTION('Property','Value',...) creates a new FACE_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before face_detection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to face_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

global Map
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );

% Edit the above text to modify the response to help face_detection

% Last Modified by GUIDE v2.5 30-Jan-2011 11:20:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @face_detection_OpeningFcn, ...
    'gui_OutputFcn',  @face_detection_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end


global point_arr;
global point_index;
global point_arr1;
global point_index1;
global DirName;
global color;

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before face_detection is made visible.
function face_detection_OpeningFcn(hObject, eventdata, handles, varargin)

global DirName;
handles.output = hObject;
guidata(hObject, handles);
DirName = 'F:\DCIM\brcm2763\';
dirName = [DirName];%'G:\DCIM\999SSCAM'  ['D:\face-detection\pictures\2007-06-10-1224-45'];
files = dir(strcat(dirName, '\*.jpg'));%Very important  '\*.bmp'));
[nFiles,b] = size(files);

imgFiles = {};
for imgFile = 1:nFiles,
    %ImgFileName = fullfile(dirName, files(imgFile).name);
    imgFiles{imgFile} =  files(imgFile).name;
end
set(handles.Piclst,'String',imgFiles );
color = 1;
% ULims1 =[96   108   121   109   104    96];
% VLims1 =[152   165   147   133   133   152];
%  SkinToneLut = BuildSkinToneLut( ULims1, VLims1 );
%

function varargout = face_detection_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes on selection change in Piclst.
function Piclst_Callback(hObject, eventdata, handles)

function Piclst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton1_Callback(hObject, eventdata, handles)


function Okbtn_Callback(hObject, eventdata, handles)
cla(handles.RGBPic);
global point_index;
global point_index1;
point_index = 1;
point_index1 = 1;
global point_arr;
global point_arr1;
global DirName
point_arr = [];
point_arr1 = [];

x3 =  [ -8    -6   -11   -19   -35   -39   -36   -24   -16  -8];
y3 =  [  7    12    20    27    31    28    22    16    12   7];

%
% ULims1 =[108    96   104   112   122   121   108];
% VLims1 =[165   152   133   132   141   147   165];
% ULims1 =[96   108   121   122   120   116   115   112   104    96];
% VLims1 =[152   165   147   141   139   140   135   132   133   152];
ULims1 =[96   108   121   109   104    96];
VLims1 =[152   165   147   133   133   152];
% x4 = round([-39.9626 -11.1596 -11.1596 -39.9626 -39.9626]);
% y4 = round([28.1172 28.1172 16.8953 16.8953 28.1172]);

files_names = get(handles.Piclst,'String');
index = get(handles.Piclst,'Value');
selected_file_name = files_names(index);
file_path =[DirName,char(selected_file_name)];% ['D:\face-detection\pictures\2007-06-10-1224-45\', char(selected_file_name)];
handles.ImgRGB = imread(file_path);
handles.ImgYUV = rgb2ycbcr( handles.ImgRGB );
handles.Y = handles.ImgYUV(:,:,1) ;
handles.U = handles.ImgYUV(:,:,2) ;
handles.V = handles.ImgYUV(:,:,3) ;

axes(handles.RGBPic);
image( handles.ImgRGB,'ButtonDownFcn',{@PicBtnDw,handles});

axes(handles.UVfig);
%axis( [-100 50 -100 50] ), grid on;
set(handles.UVfig,'ButtonDownFcn',{@UVBtnDw,handles});


%line(x3, y3);
line(ULims1, VLims1, 'Color','r');
hold on,line( [-35 -30 -20 -3 0]+128, [13 13 36 23 23]+128);
line( [-35 -30 -7 -3 0]+128, [13 13 7 23 23]+128 );


hold on,line( [-35 -30 -25 -5 0]+128, [13 13 36 15 15]+128, 'Color', 'g');
line( [-35 -30 -7 -3 0]+128, [13 13 7 15 15]+128, 'Color', 'g' );



%X/Y
% line( [0 9 129 149 159], [10 100 100 100 10] );
% line( [0 9 129 149 159], [100 10 10 10 100] );

%line(ULims, VLims);
%line(x4, y4);
guidata(hObject, handles);


function PicBtnDw(hObject, eventdata, handles)

point = get(handles.RGBPic,'currentpoint');
PntLoc = round([point(1,1), point(1,2)]);
set(handles.PntLoc1, 'String',mat2str(PntLoc));

global color;
global point_arr;
global point_index;

if( strcmp(click_type, 'normal') )
    point_arr(point_index,1)=PntLoc(1);
    point_arr(point_index,2)=PntLoc(2);
    point_arr;
    point_index = point_index + 1;
else
    %  point_arr(point_index,1) = point_arr(1,1);
    %  point_arr(point_index,2) = point_arr(1,2);
    %  axes( handles.UVfig );
    %  plot( handles.U(point_arr(:,2),point_arr(:,1)), handles.V(point_arr(:,2),point_arr(:,1)), '*-' ,'color', 'red' ); hold on;
end
set(handles.RGBPnt, 'String',mat2str(handles.RGBPic));

axes( handles.UVfig );hold on;%axis( [-50 50 -50 50] ); hold on;

if(color)
    plot( handles.U(PntLoc(2),PntLoc(1)), handles.V(PntLoc(2),PntLoc(1)), '*' ,'color', 'blue' ),grid on
else
    plot( handles.U(PntLoc(2),PntLoc(1)), handles.V(PntLoc(2),PntLoc(1)), '*' ,'color', 'red' ),grid on
end

set(handles.RGBPnt, 'String',mat2str([handles.U(PntLoc(2),PntLoc(1)), handles.V(PntLoc(2),PntLoc(1))]));

guidata(hObject, handles);
return;


function UVBtnDw(hObject, eventdata, handles)

click_type = get(get(handles.UVfig,'parent'), 'SelectionType');
point = get(handles.UVfig,'currentpoint');
PntLoc = round([point(1,1), point(1,2)]);

% global point_index1;
% global point_arr1;
%
% if( strcmp(click_type, 'normal') )
%    point_arr1(point_index1,1)=PntLoc(1);
%    point_arr1(point_index1,2)=PntLoc(2);
%    point_arr1
%    point_index1 = point_index1 + 1;
% else
%    point_arr1(point_index1,1) = point_arr1(1,1);
%    point_arr1(point_index1,2) = point_arr1(1,2);
%    axes( handles.UVfig );hold on;axis( [-50 50 -50 50] ); hold on;
%    plot( handles.U(point_arr1(:,2),point_arr1(:,1)), handles.V(point_arr1(:,2),point_arr1(:,1)), '*-' ,'color', [1 0 0] )
%
% end
%
% axes( handles.UVfig );hold on;axis( [-50 50 -50 50] ); hold on;
%plot( handles.U(PntLoc(2),PntLoc(1)), handles.V(PntLoc(2),PntLoc(1)), '*-' ,'color', [1 0 0] )

guidata(hObject, handles);
return;


function RGBPic_ButtonDownFcn(hObject, eventdata, handles)

position = get(hObject, 'Position');
mouse = get(gca,'currentpoint');
guidata(hObject, handles);


function Okbtn_ButtonDownFcn(hObject, eventdata, handles)
guidata(hObject, handles);


function Okbtn_KeyPressFcn(hObject, eventdata, handles)
guidata(hObject, handles);


function RGBPic_CreateFcn(hObject, eventdata, handles)
guidata(hObject, handles);
return;


function UVfig_ButtonDownFcn(hObject, eventdata, handles)
guidata(hObject, handles);
return;


function figure1_ButtonDownFcn(hObject, eventdata, handles)


function ZInBtn_Callback(hObject, eventdata, handles)
zoom on


function ZOutBtn_Callback(hObject, eventdata, handles)
zoom off



function ClearBtn_Callback(hObject, eventdata, handles)

global point_arr;
global point_index;
global point_arr1;
global point_index1;

point_arr = [];
point_index = 1;
point_arr1 = [];
point_index1 = 1;

cla reset


function selected_arr_Callback(hObject, eventdata, handles)

[x,y] = getpts(handles.UVfig);
x=uint8(round([ x' x(1)]))
y=uint8(round([ y' y(1)]))
Idx = inpolygon(handles.U,handles.V,x,y);
[IdxX,IdxY] = find(Idx);
%handles.RGBPic(Idx) = 255;
axes(handles.RGBPic);
hold on;
zoom reset

plot( handles.RGBPic, IdxY, IdxX, '.' ,'color', 'red')


function radiobutton1_Callback(hObject, eventdata, handles)



function RedEyeBtn_Callback(hObject, eventdata, handles)
% 
% x=uint8([-30 -20 -3 -7 -30] + 128);
% y=uint8([13 36 23 7 13] + 128);
% 
% Idx = inpolygon(handles.U,handles.V,x,y);
% H = fspecial( 'gaussian', [1, 5], 9 );
% Idx1 = GaussClean( double( Idx ), H, 0.3 );
% [IdxL, NGrpInit] = FindAllGroups( Idx1 );
% redMask = zeros(size(handles.U));
% T = mean(handles.V(:))+0.2*(max(handles.V(:))-min(handles.V(:)));
% redMask(handles.V>T) = 1;
% redMask = conv2(redMask, ones(3));
% redMask(redMask<2) = 0;
% redMask(redMask>=2) = 1;
% 
% LumMask = zeros(size(handles.U));
% T = mean(handles.Y(:))-0.2*(max(handles.Y(:))-min(handles.Y(:)));
% LumMask(handles.Y<T) = 1;
% LumMask = conv2(LumMask, ones(3));
% LumMask(LumMask<2) = 0;
% LumMask(LumMask>=2) = 1;
% 
% figure, image(255*redMask)
% figure, image(255*LumMask)
% tmp = LumMask & redMask;
% figure, image(255*tmp);

function Idx = GaussClean( Img, H, Tresh )

Img = conv2( Img, H,  'same' );
Img = conv2( Img, H', 'same' );
Idx = double( Img > Tresh );

function [IdxAll, NGrpInit] = FindAllGroups( Idx )

IdxAll = bwlabel( Idx, 4 );
NGrpInit = max(max( IdxAll ));




% --- Executes on button press in ColorBtn.
function ColorBtn_Callback(hObject, eventdata, handles)
global color;

color = ~color;

guidata(hObject, handles);
return;
return
    
% hObject    handle to ColorBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
