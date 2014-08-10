function varargout = FaceDBUI(varargin)
% FACEDBUI MATLAB code for FaceDBUI.fig
%      FACEDBUI, by itself, creates a new FACEDBUI or raises the existing
%      singleton*.
%
%      H = FACEDBUI returns the handle to a new FACEDBUI or the handle to
%      the existing singleton*.
%
%      FACEDBUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACEDBUI.M with the given input arguments.
%
%      FACEDBUI('Property','Value',...) creates a new FACEDBUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FaceDBUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FaceDBUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FaceDBUI

% Last Modified by GUIDE v2.5 22-Dec-2011 18:15:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FaceDBUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FaceDBUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before FaceDBUI is made visible.
function FaceDBUI_OpeningFcn(hObject, eventdata, handles, varargin)
BaseBackupDir='c:\Broadcom\backup\FaceDB';
ImageDir='c:\Temp';
if exist('FaceDBUiData.mat','file');
    load 'FaceDBUiData.mat'
end
% 
% if( exist('BaseBackupDir', 'dir') == 0 )
%     mkdir('BaseBackupDir');
% end
% if( exist('ImageDir', 'dir') == 0 )
%     mkdir('ImageDir');
% end

save ('FaceDBUiData.mat','BaseBackupDir','ImageDir');
set(handles.edit1,'String',BaseBackupDir);
set(handles.edit2,'String',ImageDir);
% Update handles structure
handles.output=1;
guidata(hObject, handles);

% UIWAIT makes FaceDBUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FaceDBUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
CheckboxFunc(hObject, eventdata, handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
CheckboxFunc(hObject, eventdata, handles);

function CheckboxFunc(hObject, eventdata, handles)
if get(handles.checkbox1,'Value') && get(handles.checkbox2,'Value')
    set(handles.pushbutton1,'Enable','On');
else
    set(handles.pushbutton1,'Enable','Off');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
BaseBackupDir=get(handles.edit1,'String');
BaseRelDir=get(handles.edit2,'String');
Str=['Op Started'];
set(handles.text4,'String',Str);
drawnow;
Str=['Op didnot succeed'];
OnlyFaces=get(handles.checkbox5,'Val');
BackupPicasa=get(handles.checkbox6,'Val');
BackupReport=get(handles.checkbox7,'Val');
Str=FaceDBProcessBackup(BaseBackupDir,BaseBackupDir,BaseRelDir,OnlyFaces,BackupPicasa,BackupReport,handles.text4);
set(handles.text4,'String',Str);


function edit1_Callback(hObject, eventdata, handles)
ImageDir=[];
if exist('FaceDBUiData.mat','file');
    load 'FaceDBUiData.mat'
end
BaseBackupDir=get(hObject,'String');
save ('FaceDBUiData.mat','BaseBackupDir','ImageDir');

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
BaseBackupDir=get(handles.edit1,'String');
BaseBackupDir = uigetdir(BaseBackupDir);
set(handles.edit1,'String',BaseBackupDir);
edit1_Callback(handles.edit1, eventdata, handles);



function edit2_Callback(hObject, eventdata, handles)
BaseBackupDir=[];
if exist('FaceDBUiData.mat','file');
    load 'FaceDBUiData.mat'
end
ImageDir=get(hObject,'String');
save ('FaceDBUiData.mat','BaseBackupDir','ImageDir');
set(handles.pushbutton4,'Enable','On');



% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
ImageDir=get(handles.edit2,'String');
ImageDir = uigetdir(ImageDir);
set(handles.edit2,'String',ImageDir);
edit2_Callback(handles.edit2, eventdata, handles);


% --- Executes on button press in pushbutton4. - Delete Copyright images
function pushbutton4_Callback(hObject, eventdata, handles)
ImageDir=get(handles.edit2,'String');
Str=['Delete Copyright images Started'];
set(handles.text4,'String',Str);
drawnow;
Str=['Op didnot succeed'];
SubDir=get(handles.checkbox4,'Val');
Str= CheckDeleteCopyrightImages(ImageDir,SubDir,handles.text4);

set(handles.text4,'String',Str);


% --- Executes on button press in checkbox4 include sub dir for copyright cheack.
function checkbox4_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in checkbox5 only images with faces.
function checkbox5_Callback(hObject, eventdata, handles)





% --- Executes on button press in pushbutton5 clean older version runs
function pushbutton5_Callback(hObject, eventdata, handles)

if strcmp('OK', questdlg('Only latest Xls file will be kept in each directory, others will be deleted','Cleanup Data Base dir','OK','Cancel','Cancel'))
    BaseBackupDir=get(handles.edit1,'String');
    CleanOlderDirs(BaseBackupDir,handles.text4);
    
end


% --- Executes on button press in checkbox6. - backup picasa DB
function checkbox6_Callback(hObject, eventdata, handles)



% --- Executes on button press in checkbox7. - backup report files
function checkbox7_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CleanOlderDirs(DirStart,hDisplay)

Dir=dir([DirStart,'\*']);
DirDate=zeros(1,length(Dir));
exp=['(.{2})-(.{3})-(.{4})-(.{2})-(.{2})-(.{2})'];
for i=1:length(Dir)
    if ~strcmp(Dir(i).name,'Backups') % reserved word for keeping data
        if ~strcmp(Dir(i).name,'.') && ~strcmp(Dir(i).name,'..') &&isdir([DirStart,'\',Dir(i).name])
            tok  = regexp(Dir(i).name,exp,'tokens');
            if isempty(tok)
                CleanOlderDirs([DirStart,'\',Dir(i).name],hDisplay);
            else
               % DirDate(i)=(24*60)*datenum([tok{1}{1},'-',tok{1}{2},'-',tok{1}{3}])+60*str2num(tok{1}{4})+str2num(tok{1}{5});
            end
            
        end
    end
end
DirF=dir([DirStart,'\*-*-*.xls']);
for i=1:length(DirF)
    delete([DirStart,'\',DirF(i).name]);
end
% Dirs=find(DirDate>0);
% DirDates=DirDate(Dirs);
% [S,Idx] = sort(DirDates,'descend');
% for i=2:length(S)
%     DelDir=Dir( Dirs(Idx(i)) ).name;
%     rmdir([DirStart,'\',DelDir],'s');
% end
        
    
    
    
    
    


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
BaseBackupDir=get(handles.edit1,'String');
StructInM.All=[];
StructMatch.All=[];

ImageStruct=ExelInt('XlsTree',[BaseBackupDir,'\DB_Images.xls'],StructInM,StructMatch,[]);
FaceStruct=ExelInt('XlsTree',[BaseBackupDir,'\DB_Faces.xls'],StructInM,StructMatch,[]);

set(handles.text4,'String','Op Completed');
