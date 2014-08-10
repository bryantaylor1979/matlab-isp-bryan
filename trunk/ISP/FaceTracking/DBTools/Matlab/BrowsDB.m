function varargout = BrowsDB(varargin)
%BrowsDB - Brows the Face images DB , uses Excel DB files to point to
%          images and Faces

% Last Modified by GUIDE v2.5 04-Apr-2012 20:51:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrowsDB_OpeningFcn, ...
                   'gui_OutputFcn',  @BrowsDB_OutputFcn, ...
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


% --- Executes just before BrowsDB is made visible - Init Structures.
function BrowsDB_OpeningFcn(hObject, eventdata, handles, varargin)

handles.BaseBackupDir='c:\Broadcom\FaceDB';
handles.ImageFile='c:\Temp\test.jpg';
handles.FaceFile='c:\Temp\test.jpg';
handles.AlgoFile='';

handles.ReportFile='*.xls';
handles.ReportImageFile='*.jpg';
handles.ReportLine=1;

handles.OriginAlgoResultTree=[];
handles.ReadActualImages=1;

if exist('BrowsDBData.mat','file');
    load 'BrowsDBData.mat'
    handles.BaseBackupDir=BaseBackupDir;
    handles.ImageFile=ImageFile;
    handles.FaceFile=FaceFile;
    handles.AlgoFile=AlgoFile;

end
save ('BrowsDBData.mat','-struct','handles','BaseBackupDir','ImageFile','FaceFile','AlgoFile');
set(handles.edit4,'String',[handles.BaseBackupDir,'\DB_Images_TempSum']);
set(handles.edit1,'String',handles.BaseBackupDir);
set(handles.edit2,'String',handles.ImageFile);
set(handles.edit3,'String',handles.FaceFile);
set(handles.edit5,'String',handles.AlgoFile);

handles.AlgoDat=[];


handles.AspectRatio640p=0;
handles.AspectRatioXSize=640;
handles.AspectRatioYSize=480;
handles.AspectRatioX=0;
handles.AspectRatioY=0;
handles.AspectRatioOffsetX=1;
handles.AspectRatioOffsetY=1;


handles.output=1;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line. - Not
% ----useed currently
function varargout = BrowsDB_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function Generice_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes for DB Exel file selection.
function handles=edit4_Callback(hObject, eventdata, handles)
handles.XlsDB=get(hObject,'String');
[handles.ImgDataSum,handles.FaceDataSum,handles.CurrImgFile,handles.CurrFaceFile]=GetXlsSumDat(handles.BaseBackupDir,handles.XlsDB);

guidata(hObject, handles);



% --- Executes on button press in pushbutton7. select Exel DB file
function pushbutton7_Callback(hObject, eventdata, handles)
File=get(handles.edit4,'String');
[Path,Name,ext]=fileparts(File);

[filename, pathname] = uigetfile([Path,'\DB_Images*.xls']);
if filename ~= 0
    set(handles.edit4,'String',[pathname,filename]);
    handles=edit4_Callback(handles.edit4, eventdata, handles);
    
    if isfield(handles,'tree') && ishandle( handles.tree )
        
        delete(handles.tree);
    end
    
    S.FileList=handles.ImgDataSum;
    S.FaceList=handles.FaceDataSum;
    
    [handles.tree,handles.GetTreeSelection]=ExploreDB4(handles.figure1,get(handles.uipanel1,'Position'),S,handles.BaseBackupDir);%,@SelecteImage,handles);
    guidata(hObject, handles);
    Str=sprintf('Data Base %s  opened with %d images and %d faces',filename,length(S.FileList.ImgFiles),length(S.FaceList.FaceDat));
    set(handles.text11,'String',Str);
end

% --- Face DB Backup Dir edit
function edit1_Callback(hObject, eventdata, handles)
handles.BaseBackupDir=get(hObject,'String');
save ('BrowsDBData.mat','-struct','handles','BaseBackupDir','ImageFile','FaceFile','AlgoFile');


% --- Algo file selection
function edit5_Callback(hObject, eventdata, handles)
handles.AlgoFile=get(hObject,'String');
save ('BrowsDBData.mat','-struct','handles','BaseBackupDir','ImageFile','FaceFile','AlgoFile');

    [handles.AlgoDat]=ReadAlgoData(handles.AlgoFile,handles.OriginAlgoResultTree);
    Str=sprintf('Algo Result file  %s  opened with %d images and %d faces',handles.AlgoFile,length(handles.AlgoDat.Images),length(handles.AlgoDat.Faces));
    set(handles.text11,'String',Str);

guidata(hObject, handles);


% --- Executes on button press in pushbutton8. - Algo File selection
function pushbutton8_Callback(hObject, eventdata, handles)
Ok=0;
File=get(handles.edit5,'String');
Path='.';
if ~isempty(File)
   [Path,Name,ext]=fileparts(File);
   if isempty(ext)
       Path=File;
   end
end
% get first the palce where the files are taken from in the DB tree
folder_name=get(handles.edit1,'String');

Select=questdlg('Type of algorithm results to select ','Algo result file type','1-Dir tree origin','2- *txt file to indicate a ditrectory with txt files','3-*.xls - result that was previosly claculated','1-Dir tree origin');
if Select(1)=='1'
   handles.OriginAlgoResultTree= uigetdir(folder_name,'Select the origin of the tree where result files are taken from in DB');
   handles.OriginAlgoResultTree=['.',handles.OriginAlgoResultTree(length(folder_name)+1:end)];%rlative path to tree origin
   pathname = uigetdir(Path,'Select the origin of the results');
   filename=[];
   if pathname ~= 0
        Ok=1;
    end
else
    handles.OriginAlgoResultTree=[];
    if Select(1)=='2'
        SearchStr='\*.txt';
        Str='Select one of the txt files in the result directory';
    else
        SearchStr='\*.xls';
        Str='Select the result xls file';
    end
    [filename, pathname] = uigetfile([Path,SearchStr],Str);
    if filename ~= 0
        Ok=1;
    end
end


if Ok
    set(handles.edit5,'String',[pathname,filename]);
    guidata(hObject, handles);
    edit5_Callback(handles.edit5, eventdata, handles);
    
    
end

% --- Executes on button press in pushbutton2 - Face DB Dir
function pushbutton2_Callback(hObject, eventdata, handles)
File=get(handles.edit1,'String');

File = uigetdir(File);
if File ~= 0
    set(handles.edit1,'String',File);
    edit1_Callback(handles.edit1, eventdata, handles);
end


% --- Executes on button press in pushbutton5. Show  selected file
function pushbutton5_Callback(hObject, eventdata, handles)
 tmp =handles.tree. FigureComponent;
 UserDat=get(tmp, 'UserData');
 ImgNo=UserDat.CurrNodeDataIdx;
 SelectType=UserDat.CurrNodeType;
 if ImgNo>0  && SelectType==1% an image was selected
    Dat=handles.ImgDataSum.ImgFiles(ImgNo);
    File=[handles.BaseBackupDir,Dat.Dir(2:end),'\',Dat.FileName];
    set(handles.edit2,'String',File);
    
    edit2_Callback(handles.edit2, [], handles);
 elseif ImgNo>0  && SelectType==2% a face was selected
    Dat=handles.FaceDataSum.FaceDat(ImgNo);
    File=[handles.BaseBackupDir,Dat.ThumbDir(2:end),'\',Dat.ThumbFile];
    set(handles.edit3,'String',File);
    
    edit3_Callback(handles.edit3, [], handles);
 end

 
 
% --- Executes on button press in pushbutton6. Use tree multiple
% selesctions
function pushbutton6_Callback(hObject, eventdata, handles)

handles.List=handles.GetTreeSelection();
handles.hOpGui= open('SelectionOp.fig');
set(handles.hOpGui,'UserData',handles);
OpHandles=guihandles(handles.hOpGui);
set(OpHandles.text1,'String',...
     sprintf(['%d images were selected, out of total %d\n',...
              '%d faces selected , out of %d\n'],...
              length(handles.List.Img),length(handles.ImgDataSum.ImgFiles),...
              length(handles.List.Face),length(handles.FaceDataSum.FaceDat)));
InitTableDat( OpHandles.uitable2,handles.FaceDataSum.FaceDat(handles.List.Face));      
guidata(hObject, handles);
uiwait(handles.hOpGui);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Callbacks from Op fig


function Op_PB_NewSelection_Callback(handles,Op)
OpHandles=guihandles(gcf);
switch (Op)
    case 'SaveNew'
        % --- Create new Partial Data Base out of the selection in tree
        NewName=get(OpHandles.edit1,'String');
        
        NewList.ImgFiles=handles.ImgDataSum.ImgFiles(handles.List.Img);
        Approve=questdlg('Approve creation of New PArtial Data Base',sprintf('%s DB will be created, with %5.0f images',NewName,length(NewList.ImgFiles) ),'Ok','Cancel','Cancel');
        if strcmp(Approve,'Ok')
            StructMatch.ImgFiles.Non=[]; % append line;
            if exist([handles.BaseBackupDir,'\DB_Images_',NewName,'.xls'],'file')
                CopyFile=questdlg('DB set already exist','Copying Image Files','Overwrite','Skip','Append','Overwrite');
                switch (CopyFile)
                    case 'Overwrite'
                        delete([handles.BaseBackupDir,'\DB_Images_',NewName,'.xls']);
                        if exist([handles.BaseBackupDir,'\DB_Faces_',NewName,'.xls'],'file')
                            delete([handles.BaseBackupDir,'\DB_Faces_',NewName,'.xls']);
                        end
                    case 'Skip'
                        return;
                end
                
            end
            
            ExelInt('Update',[handles.BaseBackupDir,'\DB_Images_',NewName],NewList,StructMatch,[]);
            
            NewFaceList.FaceDat=handles.FaceDataSum.FaceDat(handles.List.Face);
            StructMatch.FaceDat.Non=[]; % append line;
            ExelInt('Update',[handles.BaseBackupDir,'\DB_Faces_',NewName],NewFaceList,StructMatch,[]);
            delete(handles.hOpGui);
        end
    case 'DeleteFromSet'
        
        if ~isempty(strfind(handles.CurrImgFile,'TempSum')) || ~isempty(strfind(handles.CurrFaceFile,'TempSum'))
            errordlg('Cant remove enterys from Main DB files, select a subset for this action');
            return
        end
        
        Approve=questdlg('Approve Deletion of images from DB',sprintf('%d images and %d faces will be deleted from DB %s',length(handles.List.Img),length(handles.List.Face), handles.CurrImgFile),'Ok','Cancel','Cancel');
        if strcmp(Approve,'Ok')
            TmpList=1:length(handles.ImgDataSum.ImgFiles);
            TmpList(handles.List.Img)=0;
            TmpList=TmpList(TmpList>0);
            
            NewList.ImgFiles=handles.ImgDataSum.ImgFiles(TmpList);
            StructMatch.ImgFiles.Non=[]; % append line;
            delete(handles.CurrImgFile);
            ExelInt('Update',handles.CurrImgFile,NewList,StructMatch,[]);
            
            TmpList=1:length(handles.FaceDataSum.FaceDat);
            TmpList(handles.List.Face)=0;
            TmpList=TmpList(TmpList>0);
            
            NewFaceList.FaceDat=handles.FaceDataSum.FaceDat(TmpList);
            delete(handles.CurrFaceFile);
            
            StructMatch.FaceDat.Non=[]; % append line;
            ExelInt('Update',handles.CurrFaceFile,NewFaceList,StructMatch,[]);
            delete(handles.hOpGui);
        end
   case 'UpdateField'
        
       OpHandles=guihandles(handles.hOpGui);
       [SubStruct,ModCount,NewCount]=GetTableDif(OpHandles.uitable2,OpHandles.uitable3);
       if ModCount==0 && NewCount==0
          Approve=questdlg('No Modification or addition ','Approve Modification of images from DB','Cancel','Cancel','Cancel');  
       else
          Approve=questdlg(sprintf('%d faces will be Modified in DB %s with %d mofified field and %d new',length(handles.List.Face), handles.CurrImgFile,ModCount,NewCount),'Approve Modification of images from DB','Ok','Cancel','Cancel');
       end
       if strcmp(Approve,'Ok')
            
            handles.FaceDataSum.FaceDat=AddStructFields(handles.FaceDataSum.FaceDat,SubStruct,handles.List.Face);
            delete(handles.CurrFaceFile);
          
            StructMatch.FaceDat.Non=[]; % append line;
            ExelInt('Update',handles.CurrFaceFile,handles.FaceDataSum,StructMatch,[]);
            delete(handles.hOpGui);
            guidata(handles.figure1, handles);
       end
        
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

% -- Planed as a call back from the tree view - currently not used
function SelecteImage(ImgNo,FaceNo,handles)
if ImgNo>0 % an image was selected
    Dat=handles.ImgDataSum.ImgFiles(ImgNo);
    File=[handles.BaseBackupDir,Dat.Dir(2:end),'\',Dat.FileName];
    set(handles.edit2,'String',File);
    
    edit2_Callback(handles.edit2, [], handles);
end


% --- Select an Image file 
 
function handles=edit2_Callback(hObject, eventdata, handles)
handles=checkbox2_Callback(handles.checkbox2, eventdata, handles);
handles.ImageFile=get(hObject,'String');

handles.FileData=GetFileData(handles.BaseBackupDir,handles.ImageFile,handles.ImgDataSum);
if handles.ReadActualImages
     save ('BrowsDBData.mat','-struct','handles','BaseBackupDir','ImageFile','FaceFile','AlgoFile');
     handles=DisplayImage(handles.BaseBackupDir,handles.FileData,handles.axes1,handles.listbox2,handles);
else
    [~,handles]=AspectRatio640p([],handles.FileData.ImgFiles(1),handles);
end
handles.FaceData=GetFile2Face(handles.BaseBackupDir,handles.FileData,[],handles.FaceDataSum);
if handles.ReadActualImages
    UpdateFaceList(handles.FaceData,handles.listbox1,[]);
    DisplayFace([],[],0,handles.axes2,1,handles.listbox3,[],[],handles);

    set(handles.listbox4,'Enable','Off','String',[]);
end
if ~isempty(handles.AlgoDat)
    handles.AlgoImgDat=GetFile2AlgoData(handles.FileData,handles.AlgoDat,handles);
    if ~ isempty(handles.AlgoImgDat) && handles.ReadActualImages
        set(handles.listbox4,'Enable','on');
        UpdateAlgoFaceList(handles.AlgoImgDat,handles.listbox4);
        DisplayAlgoFace([],0,handles.listbox5,[],[],handles);
        
    end
end

%handles.FileData=FileData;
guidata(hObject, handles);


% --- Executes on button press in pushbutton3. - Select image by dir UI
function pushbutton3_Callback(hObject, eventdata, handles)
File=get(handles.edit2,'String');
try
   [filename, pathname] = uigetfile(File);
catch
    File='*.jpg';
    [filename, pathname] = uigetfile(File);
end
if filename ~= 0
   File=[pathname,filename];
   set(handles.edit2,'String',File);
   edit2_Callback(handles.edit2, eventdata, handles);
end

% --- Select Face Image file 
function edit3_Callback(hObject, eventdata, handles)

handles.FaceFile=get(hObject,'String');
save ('BrowsDBData.mat','-struct','handles','BaseBackupDir','ImageFile','FaceFile','AlgoFile');

Face=GetFile2Face(handles.BaseBackupDir,[],handles.FaceFile,handles.FaceDataSum);
handles.SingleFaceData=Face;
if ~isempty(Face) && ~isempty( Face.FaceDat.FileName)
    handles.FileData=GetFileData(handles.BaseBackupDir, [handles.BaseBackupDir,Face.FaceDat.Dir(2:end),'\',Face.FaceDat.FileName],handles.ImgDataSum);
    handles=DisplayImage(handles.BaseBackupDir,handles.FileData,handles.axes1,handles.listbox2,handles);
    handles.FaceData=GetFile2Face(handles.BaseBackupDir,handles.FileData,[],handles.FaceDataSum);
    No=UpdateFaceList(handles.FaceData,handles.listbox1,Face.FaceDat.ThumbFile);
    set(handles.listbox1,'Val',No);
    listbox1_Callback(handles.listbox1, eventdata, handles);
end


guidata(hObject, handles);


% --- Executes on button press in pushbutton4. - Select Face File by Popup UI
function pushbutton4_Callback(hObject, eventdata, handles)
File=get(handles.edit3,'String');
[filename, pathname] = uigetfile(File);
if filename ~= 0
    File=[pathname,filename];
    set(handles.edit3,'String',File);
    edit3_Callback(handles.edit3, eventdata, handles);
end

% --- Executes on button press in pushbutton13. Use Report image
% use the current report as the main UI iamge
function pushbutton13_Callback(hObject, eventdata, handles)
R=handles.Report.FacesDetected(handles.ReportLine);
File=[handles.BaseBackupDir,R.Dir(2:end),'\',R.FileName];
set(handles.edit2,'String',File);
edit2_Callback(handles.edit2, eventdata, handles);
if isempty(handles.AlgoDat) || isempty(handles.AlgoDat.Faces) || isempty(handles.AlgoDat.Faces(1).Dir)
    msgbox('Please Note that the image is using Algo result file Face DB file and not report data','Note');
end

% --- Executes on button press in pushbutton9. Load Report Image
function pushbutton9_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile(handles.ReportImageFile);
Str='No File Selected';
if filename ~= 0
   handles.ReportImageFile=[pathname,filename];
   Str=sprintf('report file %s ', handles.ReportImageFile);
   handles=DisplayReportFace(handles,[]);
   set(handles.edit7,'String',num2str(handles.ReportLine));

   guidata(hObject, handles);
end
set(handles.text11,'String',Str);

% --- Executes on button press in pushbutton10. Load Report file
function pushbutton10_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile(handles.ReportFile);
Str='No File Selected';
if filename ~= 0
    Dat.FacesDetected.All=[];
    StructMatch.FacesDetected.All=[];
    handles.ReportFile=[pathname,'\',filename];
    handles.Report=ExelInt('Get',handles.ReportFile,Dat,StructMatch,[]);
    
    Str='Not a valid report file';
    if length(handles.Report.FacesDetected)>1
       set([handles.pushbutton9,handles.edit7,handles.pushbutton11,handles.pushbutton12,handles.pushbutton13],'Enable','on');
       for i=1:length(handles.Report.FacesDetected)
           if strcmp(handles.Report.FacesDetected(i).Detect,'Miss')
               handles.ReportImageFile=[handles.Report.FacesDetected(i).ThumbDir,'\*.jpg'];
               handles.ReportLine=i;
               break
           end
       end
       
       Str=sprintf('report file %s, with % enteries',handles.ReportFile,length(handles.Report.FacesDetected));
       guidata(hObject, handles);
    end
end
set(handles.text11,'String',Str);



% --- Select Report line
function edit7_Callback(hObject, eventdata, handles)
Str=get(hObject,'String');
Val=str2double(Str)-1;
Val=max(Val,1);
Val=min(Val,length(handles.Report.FacesDetected));
handles.ReportImageFile=handles.Report.FacesDetected(Val).ThumbFile;
handles.ReportLine=Val;
handles=DisplayReportFace(handles,Val);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
Generice_edit_CreateFcn(hObject, eventdata, handles);

% --- Executes on button press in pushbutton11. Next Report Line
function pushbutton11_Callback(hObject, eventdata, handles)

Str=get(handles.edit7,'String');
Val=str2double(Str)-1;
Val=Val+1;
Val=max(Val,1);
Val=min(Val,length(handles.Report.FacesDetected));

handles.ReportImageFile=handles.Report.FacesDetected(Val).ThumbFile;
handles.ReportLine=Val;
set(handles.edit7,'String',num2str(Val+1));

handles=DisplayReportFace(handles,Val);
guidata(hObject, handles);

% --- Executes on button press in pushbutton12. Prev Report Line
function pushbutton12_Callback(hObject, eventdata, handles)

Str=get(handles.edit7,'String');
Val=str2double(Str)-1;
Val=Val-1;
Val=max(Val,1);
Val=min(Val,length(handles.Report.FacesDetected));

handles.ReportImageFile=handles.Report.FacesDetected(Val).ThumbFile;
handles.ReportLine=Val;
set(handles.edit7,'String',num2str(Val+1));

handles=DisplayReportFace(handles,Val);
guidata(hObject, handles);
%set(handles.edit7,'String',num2str(Val+1));
%DisplayReportFace(handles,Val);

% --- Executes on selection change in listbox1. - Select Face file from
%     current image faces
function listbox1_Callback(hObject, eventdata, handles)
Str=get(hObject,'String');
Val=get(hObject,'Val');

if strcmp(Str(Val),'All')
    for i=1:length(Str)-1 % all is the last one
        Face=DisplayFace(handles.BaseBackupDir,handles.FaceData,i,handles.axes2,1,handles.listbox3,handles.axes1,'black',handles);
        
    end
else
    
    Face=DisplayFace(handles.BaseBackupDir,handles.FaceData,Val,handles.axes2,1,handles.listbox3,handles.axes1,'black',handles);
    DisplayAnalyze(handles.FaceData,get(handles.listbox1,'Val'),handles.text11);
end
set(handles.edit3,'String',Face);


% --- Executes on selection change in listbox2. - Display of File Data
function listbox2_Callback(hObject, eventdata, handles)



% --- Executes on selection change in listbox3. - Dispalay of Face Data
function listbox3_Callback(hObject, eventdata, handles)


% --- Executes on selection change in listbox4 - Algo Face list for current image.
function listbox4_Callback(hObject, eventdata, handles)
Str=get(hObject,'String');
Val=get(hObject,'Val');

if strcmp(Str(Val),'All')
    for i=1:length(Str)-1 % all is the last one
        DisplayAlgoFace(handles.AlgoImgDat,i,handles.listbox5,handles.axes1,'green',handles);
    end
else

DisplayAlgoFace(handles.AlgoImgDat,Val,handles.listbox5,handles.axes1,'green',handles);
end

% -----------------------------------------------------Call face analyzer---------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
    
if isfield(handles,'AlgoImgDat') && ~isempty(handles.AlgoImgDat)
    %DisplayAnalyze(handles.FaceData,get(handles.listbox1,'Val'),handles.text11);
    [handles.Analyze,handles.AlgoImgDat]=AnalyzeImageHits(handles.FileData,handles.AlgoImgDat,handles.FaceData);
    for i=1:length(handles.Analyze.Hits)
        DisplayAlgoFace(handles.AlgoImgDat,handles.Analyze.Hits(i),[],handles.axes1,'green',handles);
    end
    for i=1:length(handles.Analyze.PartialDetect)
        DisplayAlgoFace(handles.AlgoImgDat,handles.Analyze.PartialDetect(i),[],handles.axes1,'blue',handles);
    end
    for i=1:length(handles.Analyze.OverDetect)
        DisplayAlgoFace(handles.AlgoImgDat,handles.Analyze.OverDetect(i),[],handles.axes1,'magenta',handles);
    end
    for i=1:length(handles.Analyze.FalseAlarm)
        DisplayAlgoFace(handles.AlgoImgDat,handles.Analyze.FalseAlarm(i),[],handles.axes1,'yellow',handles);
    end

    for i=1:length(handles.Analyze.MissDetect)
        DisplayFace(handles.BaseBackupDir,handles.FaceData,handles.Analyze.MissDetect(i),[],0,[],handles.axes1,'red',handles);
    end
    Str=sprintf('DB faces %3.0f , Algo Faces %3.0f Hits %3.0f , Misdetect %3.0f \n False alarm %3.0f OverDetect %3.0f under detect %3.0f',...
        length(handles.FaceData.FaceDat), length(handles.AlgoImgDat.Faces),length(handles.Analyze.Hits), length(handles.Analyze.MissDetect),...
        length(handles.Analyze.FalseAlarm), length(handles.Analyze.OverDetect),length(handles.Analyze.PartialDetect));
else
    Str='No Algo data found';
end
set(handles.text11,'String',Str);
guidata(hObject, handles);


% ---- Call repot creation for all images in Current DB
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
if isempty(handles.AlgoDat) || isempty(handles.AlgoDat.Faces) || isempty(handles.AlgoDat.Faces(1).Dir)
    msgbox('Please Note that report creation needs Algo result file and ImageDB ','Note');
else
    Str=AlgoReport(handles);
    set(handles.text11,'String',Str);
    guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Get current file data from DB
function FileData=GetFileData(BaseBackupDir,ImageFile,ImgDataSum)

[pathstr, name, ext] = fileparts(ImageFile);
[ImgDat, FaceDat]=InitXlsStruct();
FileData=[];

FileSD.ImgFiles=ImgDat;

FileSD.ImgFiles.FileName=[name,ext]; % look for this file in excel
MatchF=strcmp(ImgDataSum.FileName,FileSD.ImgFiles.FileName);

a=strfind(pathstr,BaseBackupDir);
if ~isempty(a)
    FileSD.ImgFiles.Dir=['.',pathstr(a(1)+length(BaseBackupDir):end)];
    StructMatch.ImgFiles.Dir=FileSD.ImgFiles.Dir;
    MatchD=strcmp(ImgDataSum.Dir,FileSD.ImgFiles.Dir);
    MatchF(MatchD==0)=0;
end
Idx=find(MatchF==1);
if ~isempty(Idx)
    FileData.ImgFiles=ImgDataSum.ImgFiles(Idx(1));
end
StructMatch.ImgFiles.FileName=[name,ext]; % look for this file in excel
%FileData=ExelInt('Get',[pathstr,'\DB_Images'],FileSD,StructMatch,ImgDataSum);
if isempty(FileData) || isempty(FileData.ImgFiles(1).FileName(1))
    FileData=ExelInt('Get',[pathstr,'\DB_Images'],FileSD,StructMatch,[]);
end


% --- Get Faces that belong to current Image from DB
function FaceData=GetFile2Face(BaseBackupDir,FileData,FaceFile,FaceDatSum)

ImgDat.All=[];
FaceDat.All=[];
FaceData=[];

FaceSD.FaceDat=FaceDat;
if ~isempty(FaceFile)
    [DBFileDir,FaceFileRel,FaceFileName]=Convert2Relative(FaceFile,BaseBackupDir);
    StructMatch.FaceDat.ThumbFile=FaceFileName;
    MatchF=strcmp(FaceDatSum.FileName,FaceFileName);
    
    Idx=find(MatchF==1);
    if ~isempty(Idx)
        FaceData.FaceDat=FaceDatSum.FaceDat(Idx(1));
    end
    
    %FaceData=ExelInt('Get',[DBFileDir,'\','DB_Faces'],FaceSD,StructMatch,FaceDatSum);
    if isempty(FaceData)
        FaceData=ExelInt('Get',[DBFileDir,'\','DB_Faces'],FaceSD,StructMatch,[]);
    end
    
else
    
    
    MatchF=strcmp(FaceDatSum.FileName,FileData.ImgFiles.FileName);
    if ~isempty(FileData.ImgFiles.Dir)
        StructMatch.FaceDat.Dir=FileData.ImgFiles.Dir;
        MatchD=strcmp(FaceDatSum.Dir,FileData.ImgFiles.Dir);
        MatchF(MatchD==0)=0;
    end
    Idx=find(MatchF==1);
    if ~isempty(Idx)
        FaceData.FaceDat=FaceDatSum.FaceDat(Idx);
    end 
   StructMatch.FaceDat.FileName=FileData.ImgFiles.FileName;
   %FaceData=ExelInt('Get',[BaseBackupDir,FileData.ImgFiles.Dir(2:end),'\','DB_Faces'],FaceSD,StructMatch,FaceDatSum);
   if isempty(FaceData)
       FaceData=ExelInt('Get',[BaseBackupDir,FileData.ImgFiles.Dir(2:end),'\','DB_Faces'],FaceSD,StructMatch,[]);
   end
   
end

% --- Get Algorithm face dta for current image
function AlgoData=GetFile2AlgoData(FileData,AlgoDatSum,handles)


Dat.Faces.All=[];
AlgoData.Faces=[];

   [pathstr, name, ext] = fileparts(FileData.ImgFiles.FileName);
   StructMatch.Faces.FileName=name;
   MatchF=strcmp(AlgoDatSum.FileName,name);
    
   if AlgoDatSum.Faces(1).Dir(1)~='?' % signal to ignore file dir and use only file name
       StructMatch.Faces.Dir=FileData.ImgFiles.Dir;
       MatchD=strcmp(AlgoDatSum.Dir,FileData.ImgFiles.Dir);
       MatchF(MatchD==0)=0;
       
   end
   Idx=find(MatchF==1);
   if ~isempty(Idx)
        AlgoData.Faces=AlgoDatSum.Faces(Idx);
   end 
    if (handles.AspectRatio640p==1);
        Factor=handles.AspectRationYCorrection;
    else
        Factor=1;
    end
   %AlgoData=ExelInt('Get',['dummy.dummy'],Dat,StructMatch,AlgoDatSum);
   for i = 1 : length ( AlgoData.Faces )
       AlgoData.Faces(i).FaceBoxX=AlgoData.Faces(i).FaceBoxRelX * FileData.ImgFiles.SizeX;
       AlgoData.Faces(i).FaceBoxY=AlgoData.Faces(i).FaceBoxRelY * FileData.ImgFiles.SizeY*Factor;
       AlgoData.Faces(i).FaceBoxW=AlgoData.Faces(i).FaceBoxRelW * FileData.ImgFiles.SizeX;
       AlgoData.Faces(i).FaceBoxH=AlgoData.Faces(i).FaceBoxRelH * FileData.ImgFiles.SizeY*Factor;
       AlgoData.Faces(i).FaceBoxRelH=AlgoData.Faces(i).FaceBoxRelH*Factor;
       AlgoData.Faces(i).FaceBoxRelY=AlgoData.Faces(i).FaceBoxRelY*Factor;
   end
   if length ( AlgoData.Faces )==1 && isempty(AlgoData.Faces.FileName) % ExelInt return emty fileds and not empty struct when doesn't find match
       AlgoData=[];
   end
       
       
   
   
   
% --- update the List box of faces belonging to current image
function Match=UpdateFaceList(FaceData,listbox,ThumbFile)

Match=1;
for i=1:length(FaceData.FaceDat)
    if i==1
        Str{1}='Face 1';
    else
        if strcmp(ThumbFile,FaceData.FaceDat(i).ThumbFile)
            Match=i;
        end
        Str{end+1}=['Face ',num2str(i)];
    end
end
if i>1
    Str{end+1}='All';
end
set(listbox,'Value',1);
set(listbox,'String',Str);
set(listbox,'Visible','on');

% --- update the List box of Algo found faces belonging to current image
function UpdateAlgoFaceList(AlgoFaceData,listbox)
Str{1}=[];

for i=1:length(AlgoFaceData.Faces)
    if i==1
        Str{1}='Res 1';
    else
        Str{end+1}=['Res ',num2str(i)];
    end
end
if i>1
    Str{end+1}='All';
end
set(listbox,'Value',1);
set(listbox,'String',Str);
set(listbox,'Visible','on');

% --- Read and display current image and Image Data
function handles=DisplayImage(BaseBackupDir,FileData,axes,List,handles)
subplot(axes);

if handles.ReadActualImages
    try
        Img=imread([BaseBackupDir,FileData.ImgFiles(1).Dir(2:end),'\',FileData.ImgFiles(1).FileName]);
    catch
        Img = zeros(1200, 1600, 3);
        Img(:, 800:850, 3) = Img(:, 800:850, 3)+1;
    end
    
    if (handles.AspectRatio640p==1);
        [Img,handles]=AspectRatio640p(Img,FileData.ImgFiles(1),handles);
        
        if(max(max(Img)) < 2)
            Img(Img < 0) = 0;
            Img(Img > 1) = 1;
        end
    end
    
    
    image(Img);
    axis image
end
    
if ishandle(List)
    Fields=fieldnames(FileData.ImgFiles);
    Str{1}='File Data';
    for i=1:length(Fields)
        Dat=FileData.ImgFiles.(Fields{i});
        if ~ischar(Dat)
            Dat=num2str(Dat);
        end
        Str{end+1}=sprintf('%10s :   %s \n',Fields{i},Dat);
    end
    set(List,'String',Str);
end


% if (handles.AspectRatio640p==1) && ~isempty(strfind(Fields{i},'RelW'))
%             Dat=[Dat,' (',int16(str2double(Dat)*handles.AspectRatioXSize),' pxl)'];
%         end
%         
%         if (handles.AspectRatio640p==1) && ~isempty(strfind(Fields{i},'RelH'))
%             Dat=[Dat,' (',int16(str2double(Dat)*handles.AspectRatioYSizeM),' pxl)'];
%         end
%         

% --- Read and display current face image and data both on Face image axis
%     and on Main Image as markers for eyes mouth and bounding box
function FaceFile=DisplayFace(BaseBackupDir,FaceData,No,axesF,MarkFace,List,axesI,Color,handles)
    
Img=[0 0;0 0];
Face.ThumbFile=[];
FaceFile=[];

if No>0
    Face=FaceData.FaceDat(No);
end

if handles.ReadActualImages
    if ~isempty(axesF)
        subplot(axesF);
        FaceFile=[];
        if  ischar(Face.ThumbFile)
            FaceFile=[BaseBackupDir,Face.ThumbDir(2:end),'\',Face.ThumbFile];
            if exist(FaceFile,'file')
                Img=imread(FaceFile);
                
                if (handles.AspectRatio640p ==1) % rescale the image to the size of internal algo
                    Scale=[handles.AspectRatioX,handles.AspectRatioY];
                else
                    Scale=[ 1 1];
                end
                SizeI=[Face.SizeX,Face.SizeY];
                if sum(SizeI>0)>0
                    Box  = [Face.FaceBoxRelW,Face.FaceBoxRelH].*SizeI./Scale;
                    Img=imresize(Img,[Box(2),Box(1)]);
                end
            end
        end
        
        image(Img);
        axis image;
    end
end
if ~isempty(List) && ishandle(List)
    Fields=fieldnames(Face);
    Str{1}='Face Data';
    for i=1:length(Fields)
        Dat=Face.(Fields{i});
        if ~ischar(Dat)
            Dat=num2str(Dat);
        end
        if (handles.AspectRatio640p==1) && ~isempty(strfind(Fields{i},'RelW'))
            Dat=[Dat,' (',num2str(int16(str2double(Dat)*handles.AspectRatioXSize)),' pxl)'];
        end
        
        if (handles.AspectRatio640p==1) && ~isempty(strfind(Fields{i},'RelH'))
            Dat=[Dat,' (',num2str(int16(str2double(Dat)*handles.AspectRatioYSizeM)),' pxl)'];
        end
        

        Str{end+1}=sprintf('%10s :   %s \n',Fields{i},Dat);
    end
    set(List,'String',Str);
end

if No>0
    RelBoxStart = [Face.FaceBoxRelX,Face.FaceBoxRelY];
    RelBoxSize  = [Face.FaceBoxRelW,Face.FaceBoxRelH];
    Leye=[Face.LeftEyeRelX,Face.LeftEyeRelY];
    Reye=[Face.RightEyeRelX,Face.RightEyeRelY];
    Mouth=[Face.MouthRelX,Face.MouthRelY];
    if (handles.AspectRatio640p ==1) % rescale the image to the size of internal algo
        Offset=[handles.AspectRatioOffsetX-1,handles.AspectRatioOffsetY-1];
        Scale=[handles.AspectRatioX,handles.AspectRatioY];
    else
        Offset=[0 0];
        Scale=[ 1 1];
    end
    SizeI=[Face.SizeX,Face.SizeY];
    if sum(SizeI>0)>0
        SizeT=[Face.FaceBoxRelW,Face.FaceBoxRelH].*SizeI./Scale;
    else
    SizeT=[Face.ThumbX,Face.ThumbY];
    end
    
    if ~isempty(axesF) && MarkFace
        hold on;
        L=((Leye-RelBoxStart)./RelBoxSize).*SizeT;
        R=((Reye-RelBoxStart)./RelBoxSize).*SizeT;
        M=((Mouth-RelBoxStart)./RelBoxSize).*SizeT;
        plot(L(1),L(2),'*r');
        plot(R(1),R(2),'*g');
        plot(M(1),M(2),'*b');
        hold off;
    end
    subplot(axesI);
    if sum(SizeI>0)>0
        hold on;
        L=((Leye).*SizeI-Offset)./Scale;
        R=((Reye).*SizeI-Offset)./Scale;
        M=((Mouth).*SizeI-Offset)./Scale;
        
        RelBoxStart=(RelBoxStart.*SizeI-Offset)./Scale;
        RelBoxSize=(RelBoxSize.*SizeI./Scale);
        plot(L(1),L(2),'*r');
        plot(R(1),R(2),'*g');
        plot(M(1),M(2),'*b');
        rectangle('Position',[RelBoxStart,RelBoxSize],'EdgeColor',Color);
        Tp=(RelBoxStart)+[0,-8];
        AddTxt=[];
        if isfield(Face,'Remark') && ~isempty(Face.Remark) && ~isnan(Face.Remark(1))
            AddTxt=Face.Remark;
            if ~isempty(strfind(Face.FaceQuality,'Ver'))
                AddTxt=[AddTxt,' ',Face.FaceQuality];
            end
            
        end
        text(Tp(1),Tp(2),sprintf('Face %d %s',No,AddTxt),'Color',Color);
        hold off;
    end
end

% --- Display markers of current Algo face on main image, and display algo
%     face data
function DisplayAlgoFace(FaceData,No,List,axesI,Color,handles)

Face.NoFields=[];
if No>0
    Face=FaceData.Faces(No);
end

if ~isempty(List)
    if ishandle(List)
        
        
        Fields=fieldnames(Face);
        Str{1}='Face Data';
        for i=1:length(Fields)
            Dat=Face.(Fields{i});
            if ~ischar(Dat)
                Dat=num2str(Dat);
            end
            Str{end+1}=sprintf('%10s :   %s \n',Fields{i},Dat);
        end
        set(List,'String',Str);
    end
end
if No>0
    subplot(axesI);
    hold on;
    if (handles.AspectRatio640p ==1) % rescale the image to the size of internal algo
        Offset=[handles.AspectRatioOffsetX-1,handles.AspectRatioOffsetY-1];
        Scale=[handles.AspectRatioX,handles.AspectRatioY];
    else
        Offset=[0 0];
        Scale=[ 1 1];
    end
    Face.FaceBoxX=(Face.FaceBoxX-Offset(1))./Scale(1);
    Face.FaceBoxY=(Face.FaceBoxY-Offset(2))./Scale(2);
    Face.FaceBoxW=Face.FaceBoxW./Scale(1);
    Face.FaceBoxH=Face.FaceBoxH./Scale(2);
    AddTxt=[];
    if isfield(Face,'Remark') && ~isempty(Face.Remark) && ~isnan(Face.Remark(1))
            AddTxt=Face.Remark;
            if ~isempty(strfind(Face.FaceQuality,'Ver'))
                AddTxt=[AddTxt,' ',Face.FaceQuality];
            end

    end
    if isfield(Face,'Algo') && ~isempty(Face.Algo) && ~isnan(Face.Algo(1))
            AddTxt=[AddTxt,' Algo:(',Face.Algo,')'];
            

    end
    if ~isnan(Face.ConfA)
        Conf=Face.ConfA;
    else
        Conf=max(Face.DetConf1,max(Face.DetConf2,max(Face.PartDetConf1,Face.ConfA))) ;  
    end
    rectangle('Position',[Face.FaceBoxX,Face.FaceBoxY,Face.FaceBoxW,Face.FaceBoxH],'EdgeColor',Color);
    text(Face.FaceBoxX+4,Face.FaceBoxY+8,sprintf('%d', Conf),'Color',Color);
    text(Face.FaceBoxX,Face.FaceBoxY-8,sprintf('Res %d %s',No,AddTxt),'Color',Color);
    hold off;
end

% --- Analyze face data and display in text box, currently face angles
function Out=DisplayAnalyze(FaceData,No,Text)
Face=FaceData.FaceDat(No);

SizeI=[Face.SizeX,Face.SizeY];
Leye=[Face.LeftEyeRelX,Face.LeftEyeRelY].*SizeI;
Reye=[Face.RightEyeRelX,Face.RightEyeRelY].*SizeI;
Mouth=[Face.MouthRelX,Face.MouthRelY].*SizeI;

Angle=atand((Leye(2)-Reye(2))/(Leye(1)-Reye(1)));

Rotate=abs(((Leye(1)-Reye(1)).^2+(Leye(2)-Reye(2)).^2).^0.5/ ...
       (((Leye(1)+Reye(1))/2-Mouth(1))^2+((Leye(2)+Reye(2))/2-Mouth(2))^2)^0.5);

   Str= sprintf('Angle is %f , rotation is %f',Angle,Rotate);
   set(Text,'String',Str);
   Out.Rotate=Rotate;
   Out.Angle=Angle;
   

% --- Convert directory name to relative directory name, as Dir names in DB
%     are reative
function [DBFileDir,FaceFileRel,FaceFileName] = Convert2Relative(FaceFile,BaseBackupDir)

FaceFileRel=[];
DBFileDir=[];
     
[pathstr, name, ext] = fileparts(FaceFile);
FaceFileName=[name,ext];
F=strfind(pathstr,'\Thumb');
if ~isempty(F)
     DBFileDir=FaceFile(1:F(1)-1);

     BaseBackupDir=[BaseBackupDir,'\'];

     B=strfind(pathstr,BaseBackupDir);
     if ~isempty(B) % the directory of the images has the same base name in the tree
         %then we place it in the same hirarchy under the base
         ImageDir=pathstr(B+length(BaseBackupDir):end);
     end
     if ~isempty(ImageDir) && ImageDir(end)=='\'
         ImageDir=ImageDir(1:end-1);
     end
     
     FaceFileRel=['.\',ImageDir,'\',name,ext];
end


% --- Read the Exel data files into Matlab structures
function [ImgDataSum,FaceDataSum,ImageFile,FaceDBFile]=GetXlsSumDat(BaseBackupDir,ImgXlsFile)
StructMatch.All=[];
StructIn.All=[];
LoadAllFace=1;
if isempty(ImgXlsFile)
    ImageFile=[BaseBackupDir,'\DB_Images_TempSum'];
   
else
   [pathstr, name, ext]=fileparts(ImgXlsFile);
   ImageFile=[pathstr,'\', name];
   if strcmp(name(1:9),'DB_Images') % then look for the matchin file name
       FaceDBFile=[pathstr,'\','DB_Faces', name(10:end)];
       if exist([FaceDBFile,ext],'file')
           LoadAllFace=0;
       end
   end
      
end
if LoadAllFace==1
   FaceDBFile=[BaseBackupDir,'\DB_Faces_TempSum'];
end

    
ImgDataSum=ExelInt('Get',ImageFile,StructIn,StructMatch,[]);
Temp=cell(length(ImgDataSum.ImgFiles),1);
[Temp{:}]=ImgDataSum.ImgFiles.FileName;
ImgDataSum.FileName=Temp;
[Temp{:}]=ImgDataSum.ImgFiles.Dir;
ImgDataSum.Dir=Temp;

FaceDataSum=ExelInt('Get',FaceDBFile,StructIn,StructMatch,[]);
Temp=cell(length(FaceDataSum.FaceDat),1);
[Temp{:}]=FaceDataSum.FaceDat.FileName;
FaceDataSum.FileName=Temp;
[Temp{:}]=FaceDataSum.FaceDat.Dir;
FaceDataSum.Dir=Temp;


ImageFile=[ImageFile,'.xls'];
FaceDBFile=[FaceDBFile,'.xls'];




% --- Executes on selection change in listbox5. Algo Face Data list
function listbox5_Callback(hObject, eventdata, handles)



% --- Executes on button press in checkbox2 - Display in 640p aspect ratio.
function handles=checkbox2_Callback(hObject, eventdata, handles)
handles.AspectRatio640p = get(hObject,'Value');



guidata(hObject, handles);

% --- Read the Algo result data either from an Exel File or from directory
%     with text files for each image and convert to Matalb Structures
function [AlgoDat]=ReadAlgoData(AlgoFile,OriginAlgoResultTree)

[Path,Name,ext]=fileparts(AlgoFile);
if isempty(ext)
    Path=AlgoFile;
    Name=[];
end
StructMatch.All=[];
StructIn.All=[];
AlgoDat=[];
AlgoImages=[];
AlgoFaces=[];
switch (ext)
    case '.txt' % it is a directory with text files
        AlgoDat=ReadTxtDir(Path,Name,ext,'Algo.xls',[],[]);
        StructMatch.Faces.Non=[]; % append line;
        if exist([Path,'\Algo.xls'],'file'); % replace any existing DB dile with the current one.
            delete([Path,'\Algo.xls']);
        end
        ExelInt('Update',[Path,'\Algo'],AlgoDat,StructMatch,[]);
        AlgoDat.Images=[];
    case {'.xls'}
        AlgoDat=ExelInt('Get',[Path,'\',Name],StructIn,StructMatch,[]);
        if ~isfield(AlgoDat,'Images')
            AlgoDat.Images=[];
        end
    case [] % it is a directory
        if ~isempty(OriginAlgoResultTree)
            Str='Collecting results on algorithm run on file tree .....................................................';
            Fig=gcf;
            hMsg=msgbox(Str,Str);
            
            Tmp=get(hMsg,'Children');
            T=get(Tmp(1),'Children');
            figure(Fig);
            
            AlgoDat=ReadTxtDir(Path,Name,ext,'Algo.xls',OriginAlgoResultTree,T);
            if exist([Path,'\Algo.xls'],'file'); % replace any existing DB dile with the current one.
                delete([Path,'\Algo.xls']);
            end
            StructMatch.Faces.Non=[]; % append line;
            ExelInt('Update',[Path,'\Algo'],AlgoDat,StructMatch,[]);
            AlgoDat.Images=[];
            delete(hMsg);
        end
        
        
        
end
if ~isempty(AlgoDat)
    Temp=cell(length(AlgoDat.Faces),1);
   [Temp{:}]=AlgoDat.Faces.FileName;
   AlgoDat.FileName=Temp;
   for i=1:length(Temp);
       if ~ischar(Temp{i})
           AlgoDat.FileName{i}=num2str(AlgoDat.FileName{i});
           AlgoDat.Faces(i).FileName=num2str(AlgoDat.Faces(i).FileName);
       end
   end
   [Temp{:}]=AlgoDat.Faces.Dir;
   AlgoDat.Dir=Temp;
    msgbox('succedded in creating/ reading algo data','Algo Data');
else
     msgbox('Error creating/ reading algo data','Algo Data');
end
% --- Read Algo face data from a Dir with text files for each image, option
%     to save the data into exel file for future use
%     call recursivly if a TreeOrigin is given
function Out=ReadTxtDir(Path,Name,ext,XlsOutFile,TreeOrigin,Txt)
Algo.Faces=[];
Out.Faces=[];
FaceCount=0;
if ~isempty(TreeOrigin)
    if ~isempty(Txt);
        set(Txt,'String',['CurrentDir = ',TreeOrigin]);
        drawnow expose;
    end
    BaseDir=TreeOrigin;
    DirList=dir([Path,'\*']);
    for d=1:length(DirList) % first two ar current and previos directories
        if DirList(d).isdir && DirList(d).name(1) ~= '.'
            Tmp=ReadTxtDir([Path,'\',DirList(d).name],Name,ext,XlsOutFile,[TreeOrigin,'\',DirList(d).name],Txt);
            if ~isempty(Tmp.Faces)
                Out.Faces=[Out.Faces,Tmp.Faces];
            end
            
        end
    end
else
    BaseDir='?';
end
    

Date=date;    
Dir =dir([Path,'\*.txt']);
for i=1:length(Dir)
    % f=strfind(Dir(i).name,'_FD_'); % Old FD verison
    f=strfind(Dir(i).name,'_ciu_'); % New FD verison
    g=strfind(Dir(i).name,'statistic.txt');
    if ~isempty(f) && ~isempty(g)
        Faces.Dir=BaseDir;
        Faces.FileName=Dir(i).name(1:f(1)-1);
        file=fopen([Path,'\',Dir(i).name]);
        TmpArry=[];
        for j=1:4 
            Line=fgetl(file);
            Tokens = regexp(Line, '(\w+)\s+','tokens');
            for k=1 : length(Tokens)
                TmpArry(j,k)=str2double(Tokens{k});
            end
        end
        fclose(file);
        for k=1:size(TmpArry,2)
            if TmpArry(1,k)>1 % it is a valid rect
                FaceCount=FaceCount+1;
                ConfA=TmpArry(1,k);
                Algo.Faces(FaceCount).Dir=Faces.Dir;
                Algo.Faces(FaceCount).FileName=Faces.FileName;
                Algo.Faces(FaceCount).ConfA=ConfA;
                Algo.Faces(FaceCount).FaceBoxRelX=TmpArry(2,k)/640;
                Algo.Faces(FaceCount).FaceBoxRelY=TmpArry(3,k)/480;
                Algo.Faces(FaceCount).FaceBoxRelW=TmpArry(4,k)/640;
                Algo.Faces(FaceCount).FaceBoxRelH=TmpArry(4,k)/480;
                
                Algo.Faces(FaceCount).Algo=['BRCM (',Date(1:end-5),')'];
            end
        end
             
    end
end

%StructMatch.Faces.Non=[]; % append line;
%ExelInt('Update',[Path,'\',XlsOutFile(1:end-4)],Algo,StructMatch,[]);
if ~isempty(Algo.Faces)
    Out.Faces=[Out.Faces,Algo.Faces];
end
%Out.Images=[];

% --- Analyze the Algo faces against the DB golden truth, and display
%     results Graphicaly
function [Out,AlgoDatSum]=AnalyzeImageHits(FileData,AlgoDatSum,FaceData)
  Hits=[];
  MissDetect=[];
  PartialDetect=[];
  OverDetect=[];
  FalseAlarm=[];
  Detected=[];
  DetectedBy=[];
  PartDetectedBy=[];
  
  HitA=cell(2,length(AlgoDatSum.Faces));
  HitF=cell(2,length(FaceData.FaceDat));
  
 for i= 1: length (AlgoDatSum.Faces) % detected faces
      for j=1: length(FaceData.FaceDat)
          Res=TestFace(AlgoDatSum.Faces(i),FaceData.FaceDat(j)); % 0 none 1 hit 2 partial hit
          if Res>0
              if isfield(FaceData.FaceDat(j),'Remark')
                  AlgoDatSum.Faces(i).Remark=FaceData.FaceDat(j).Remark;
                  AlgoDatSum.Faces(i).FaceQuality=FaceData.FaceDat(j).FaceQuality;
              end
              HitA{Res,i}=[HitA{Res,i},j];
              HitF{Res,j}=[HitF{Res,j},i];
          end
      end
 end
 
 for i= 1: length (AlgoDatSum.Faces) 
     if isempty(HitA{1,i}) && isempty(HitA{2,i})
         FalseAlarm=[FalseAlarm,i];
     elseif length(HitA{1,i})>1 || (length(HitA{1,i})>0 && length(HitA{2,i})>0)
         OverDetect=[OverDetect,i];
     elseif length(HitA{2,i})>0
         PartialDetect=[PartialDetect,i];
     else
         Hits=[Hits,i];
         
     end
 end
 for i=1: length(FaceData.FaceDat)
     if isempty(HitF{1,i}) && isempty(HitF{2,i})
        MissDetect=[MissDetect,i];
     else
        Detected=[Detected,i];
        DetectedBy{end+1}=[HitF{1,i}];
        PartDetectedBy{end+1}=[HitF{2,i}];
        
     end
 end
 
 Out.Hits=Hits;
 Out.PartialDetect=PartialDetect;
 Out.OverDetect=OverDetect;
 Out.FalseAlarm=FalseAlarm;
 Out.MissDetect=MissDetect;
 Out.Detected=Detected;
 Out.DetectedBy=DetectedBy;
 Out.PartDetectedBy=PartDetectedBy;
 
 % --- compare a rectangle of found face to location of eyes and moth (
 %     from golden standard) to see if it is a hit missdetect or partial
 %     detection
function Res=TestFace(FaceA,FaceDB) % 0 none 1 hit 2 partial hit
Res=0;

 Reye=[FaceDB.RightEyeRelX,FaceDB.RightEyeRelY];
 Leye=[FaceDB.LeftEyeRelX,FaceDB.LeftEyeRelY];
 Mouth=[FaceDB.MouthRelX,FaceDB.MouthRelY];

 Box=[FaceA.FaceBoxRelX,FaceA.FaceBoxRelY,FaceA.FaceBoxRelW+FaceA.FaceBoxRelX,FaceA.FaceBoxRelH+FaceA.FaceBoxRelY];

 R=Reye(1)>Box(1) && Reye(1) < Box(3) && ...
   Reye(2)>Box(2) && Reye(2) < Box(4);
 L=Leye(1)>Box(1) && Leye(1) < Box(3) && ...
   Leye(2)>Box(2) && Leye(2) < Box(4);
 M=Mouth(1)>Box(1) && Mouth(1) < Box(3) && ...
   Mouth(2)>Box(2) && Mouth(2) < Box(4);

switch (R+L+M)
   case 3 
       Res=1;
   case {1,2}
       Res=2;
end

% --- Generate analysis report for all images in current DB
%     Generate Exel file with results, and optional directory with all the
%     missdetectd and false alarms thumbnails
function Str=AlgoReport(handles)
Faces=0;
Algo=0;
Hits=0;
Miss=0;
Part=0;
Over=0;
FalseD=0;
ThumbDir=[];

R(1).Detect=0;
   
CopyThumbs=questdlg('Create Thumb Dir for missdeteted and false alarms','Do you want to save missdetected and false alarm thumbnails to dir?','Yes','No','No');
if strcmp(CopyThumbs,'Yes')
    ThumbDir = uigetdir('.');
end
Str=sprintf( 'Creating repoprt file for the curent data base of %d images',length(handles.ImgDataSum.ImgFiles));

hMsg=msgbox(Str,Str);
Tmp=get(hMsg,'Children');
T=get(Tmp(1),'Children');
figure(handles.figure1);
handles.ReadActualImages=0;
guidata(handles.figure1, handles);
for No=1:length(handles.ImgDataSum.ImgFiles)
    %tic
    Dat=handles.ImgDataSum.ImgFiles(No);
    File=[handles.BaseBackupDir,Dat.Dir(2:end),'\',Dat.FileName];
    set(handles.edit2,'String',File);
    
    edit2_Callback(handles.edit2, [], handles);
    
    handles=guidata(handles.figure1);
    %toc
    
    
    FileProp = handles.FileData.ImgFiles(1);
    pat = '0[0-9]+[.]jpg';
    res = regexp( FileProp.FileName, pat, 'start' );
    
    if( (isfield(FileProp, 'Orientation') && ((FileProp.Orientation == 3 || FileProp.Orientation == 6 || FileProp.Orientation == 8) || (~isempty(res) && res == 1))) )
        continue;
    end
    
    if isfield(handles,'AlgoImgDat') && ~isempty(handles.AlgoImgDat)
%         tic
        set(T,'String',sprintf('File %d',No));
        drawnow expose;
        handles.Analyze=AnalyzeImageHits(handles.FileData,handles.AlgoImgDat,handles.FaceData);
        
        
        for i=1:length(handles.Analyze.MissDetect)
            R=AddStructFields(R,handles.FaceData.FaceDat(handles.Analyze.MissDetect(i)),0);
            R(end).Detect='Miss';
            Out=DisplayAnalyze(handles.FaceData,handles.Analyze.MissDetect(i),[]);
            R(end).Rotate=Out.Rotate;
            R(end).Angle=Out.Angle;
            R(end).Idx=length(R);
            if ~isempty(ThumbDir)
                ThumbDirT=ThumbDir;   % create subdir according to Remark, Typicaly Profile, Do not care etc.
                if isfield(R,'Remark') && ~isempty(R(end).Remark) && ~isnan(R(end).Remark(1))
                    ThumbDirT=[ThumbDir,'\',R(end).Remark];
                    if ~isdir(ThumbDirT)
                        mkdir(ThumbDirT);
                    end
                end
                try
                   if  ~isnan(R(end).ThumbDir(1)) &&  ~isnan(R(end).ThumbFile(1))
                       MissedFileName = [ThumbDirT,'\Missed_',num2str(R(end).Idx),'_',R(end).ThumbFile];
                       if( length(MissedFileName) >=260  )
                           MissedFileName = [MissedFileName(1:254) MissedFileName(end-4:end)];
                       end
                       copyfile([handles.BaseBackupDir,R(end).ThumbDir(2:end),'\',R(end).ThumbFile], MissedFileName);
                   else
                       Img=[1 1;1 1];
                       imwrite(Img,[ThumbDirT,'\Missed_',num2str(R(end).Idx),'_',R(end).FileName]);
                   end
                catch
                   Img=[1 1;1 1];
                   imwrite(Img,MissedFileName);
              
                end
                R(end).ThumbDir=ThumbDirT;
                R(end).ThumbFile=['Missed_',num2str(R(end).Idx),'_',R(end).ThumbFile];

            end
        end
        for i=1:length(handles.Analyze.Detected)
            R=AddStructFields(R,handles.FaceData.FaceDat(handles.Analyze.Detected(i)),0);
            R(end).Detect='Detect';
            Out=DisplayAnalyze(handles.FaceData,handles.Analyze.Detected(i),[]);
            R(end).Rotate=Out.Rotate;
            R(end).Angle=Out.Angle;
            R(end).Idx=length(R);
            if ~isempty(handles.Analyze.DetectedBy{i})
                R(end).DetConf1=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(1)).ConfA;
                R(end).FaceBoxRelX=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(1)).FaceBoxRelX;
                R(end).FaceBoxRelY=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(1)).FaceBoxRelY;
                R(end).FaceBoxRelW=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(1)).FaceBoxRelW;
                R(end).FaceBoxRelH=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(1)).FaceBoxRelH;
                
                if length(handles.Analyze.DetectedBy{i})>1
                    R(end).DetConf2=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(2)).ConfA;
                else
                    R(end).DetConf2=0;
                end
            else
                R(end).DetConf1=0;
            end
            if ~isempty(handles.Analyze.PartDetectedBy{i})
                if isempty(handles.Analyze.DetectedBy{i})
                    R(end).FaceBoxRelX=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(1)).FaceBoxRelX;
                    R(end).FaceBoxRelY=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(1)).FaceBoxRelY;
                    R(end).FaceBoxRelW=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(1)).FaceBoxRelW;
                    R(end).FaceBoxRelH=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(1)).FaceBoxRelH;
                end
                R(end).PartDetConf1=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(1)).ConfA;
                
                if length(handles.Analyze.PartDetectedBy{i})>1
                    R(end).PartDetConf2=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(2)).ConfA;
                else
                    R(end).PartDetConf2=0;
                end
            else
                R(end).PartDetConf1=0;
            end
            if ~isempty(handles.Analyze.DetectedBy{i})
                for DetBy=1: length(handles.Analyze.DetectedBy{i})
                    if isfield(handles.AlgoImgDat.Faces,'Algo') && ~isnan(handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(DetBy)).Algo(1))
                       R(end).(sprintf('Algo%d',DetBy))=handles.AlgoImgDat.Faces(handles.Analyze.DetectedBy{i}(DetBy)).Algo;
                    end
                end
            end
            if ~isempty(handles.Analyze.PartDetectedBy{i})
                Det=length(handles.Analyze.DetectedBy{i});
                for DetBy=1: length(handles.Analyze.PartDetectedBy{i})
                    if isfield(handles.AlgoImgDat.Faces,'Algo') && ~isnan(handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(DetBy)).Algo(1))
                       R(end).(sprintf('Algo%d',DetBy+Det))=handles.AlgoImgDat.Faces(handles.Analyze.PartDetectedBy{i}(DetBy)).Algo;
                    end
                end
            end
            
        end
        for i=1:length(handles.Analyze.FalseAlarm)
            R=AddStructFields(R,handles.AlgoImgDat.Faces(handles.Analyze.FalseAlarm(i)),0);
            R(end).Detect='FalseAlarm';
            R(end).FileName=handles.FileData.ImgFiles(1).FileName; % check later might have missmatch with file dir
            R(end).Dir=handles.FileData.ImgFiles(1).Dir;
            R(end).Idx=length(R);
                
            if ~isempty(ThumbDir)
                R(end).ThumbDir=ThumbDir;
                R(end).ThumbFile=['False_',num2str(R(end).Idx),'_',R(end).FileName(1:end-4),'_',num2str(i),'.jpg'];
                try
                File=imread([handles.BaseBackupDir,R(end).Dir(2:end),'\',R(end).FileName]);
                catch
                File = zeros(R(end).FaceBoxY+R(end).FaceBoxH, R(end).FaceBoxX+R(end).FaceBoxW, 3);
                end
                Lim=floor([R(end).FaceBoxX,R(end).FaceBoxX+R(end).FaceBoxW,R(end).FaceBoxY,R(end).FaceBoxY+R(end).FaceBoxH]);
                Lim(Lim<1)=1;
                Lim(4)=min(Lim(4),size(File,1));
                Lim(2)=min(Lim(2),size(File,2));
                
                
                if((size(Lim(3):Lim(4), 2) == 0) || (size(Lim(1):Lim(2), 2) == 0) )
                    continue;
                else
                    imwrite(File(Lim(3):Lim(4),Lim(1):Lim(2),:),[ThumbDir,'\',R(end).ThumbFile]);                
                end
            else
            end
            
        end
        Faces=Faces+length(handles.FaceData.FaceDat);
        Algo=Algo+length(handles.AlgoImgDat.Faces);
        Hits=Hits+length(handles.Analyze.Hits);
        Miss=Miss+length(handles.Analyze.MissDetect);
        FalseD=FalseD+length(handles.Analyze.FalseAlarm);
        Part=Part+length(handles.Analyze.PartialDetect);
        Over=Over+length(handles.Analyze.OverDetect);
%      'anakyze'
     % toc
    end
end


Str=sprintf('DB faces %3.0f , Algo Faces %3.0f Hits %3.0f , Misdetect %3.0f \n False alarm %3.0f OverDetect %3.0f under detect %3.0f',...
    Faces, Algo,Hits,Miss,FalseD, Over,Part);

Report.FacesDetected=R;
[Path,Name,ext]=fileparts(handles.AlgoFile);
StructMatch.ImgFiles.Non=[]; % append line;
if exist([Path,'\Report.xls'],'file')
    CopyFile=questdlg('Report already exist','Over wrie exisiting report file','Overwrite','Skip','Overwrite');
    switch (CopyFile)
        case 'Overwrite'
            delete([Path,'\Report.xls']);
        case 'Skip'
            return;
    end
    
end

ExelInt('Update',[Path,'\Report'],Report,StructMatch,[]);
handles.ReadActualImages=1;
guidata(handles.figure1, handles);
delete(hMsg);

% --- service function for adding one structure to an array of structures,
%     where the fields to add is a subset of the final fields in the struct
%     array
function StructArray=AddStructFields(StructArray,SubStruct,Idx)
fields=fieldnames(SubStruct);
Start=1;
if Idx(1)==0;
    StructArray(end+1).(fields{1})=SubStruct.(fields{1});
    Idx=length(StructArray);
    Start=2;
end

for j= 1:length(Idx)
    for i=Start:length(fields)
        StructArray(Idx(j)).(fields{i})=SubStruct.(fields{i});
    end
end

% --------------------------------------------------------------------


function InitTableDat( UiTable, Dat)     

UiDat=get(UiTable,'Data');
names=fieldnames(Dat);
    for i=1:length(names)
        UiDat{i,1}=names{i};
        UiDat{i,3}=' ';
        Val=Dat(1).(names{i});
        for j=1:length(Dat)
            if length(Val)==length(Dat(j).(names{i})) && sum(Val~=Dat(j).(names{i}))>0
                Val='XXXXXX';
                break;
            end
        end
            
         UiDat{i,2}=Val;
        
    end
set(UiTable,'Data',UiDat);

function [SubStruct,ModCount,NewCount]=GetTableDif(UiTable1, UiTable2)
SubStruct=[];
ModCount=0;
NewCount=0;

UiDat=get(UiTable1,'Data');
for i=1:length(UiDat)
    if ~strcmp(UiDat{i,3},' ')
        ModCount=ModCount+1;
        SubStruct.(UiDat{i,1})=UiDat{i,3};
    end
end

UiDat=get(UiTable2,'Data');
for i=1:length(UiDat)
    if ~isempty(UiDat{i,1})
        NewCount=NewCount+1;
        SubStruct.(UiDat{i,1})=UiDat{i,2};
    end
end
            

function handles=DisplayReportFace(handles,Idx)
handles.ReportRec=[];
if isempty(Idx)
    if ~isnan(handles.ReportImageFile)
        [pathstr, name, ext] = fileparts(handles.ReportImageFile);
        for i=1:length(handles.Report.FacesDetected)
            if strcmp([name,ext],handles.Report.FacesDetected(i).ThumbFile)
                handles.ReportRec=handles.Report.FacesDetected(i);
                handles.ReportLine=i;
                
                break;
            end
        end
    end

else
    handles.ReportLine=Idx;
    handles.ReportRec=handles.Report.FacesDetected(Idx);
end
   
if ~isempty(handles.ReportRec) 
    
    guidata(handles.figure1, handles);
    set(handles.edit2,'String',[handles.BaseBackupDir,handles.ReportRec.Dir(2:end),'\',handles.ReportRec.FileName]);   
    handles=edit2_Callback(handles.edit2, [], handles);

    Tmp.ImgFiles=handles.ReportRec;
    Tmp.Faces=handles.ReportRec;
    Tmp.FaceDat=handles.ReportRec;
    if ~isnan(Tmp.FaceDat.ThumbDir(1)) && Tmp.FaceDat.ThumbDir(1)~='.'
        Tmp.FaceDat.ThumbDir=[' ',Tmp.FaceDat.ThumbDir]; % to overcome the standard referance style .\ of this dir in DB
        BaseDir=[];
    else
        BaseDir=handles.BaseBackupDir;
    end
    handles=DisplayImage(handles.BaseBackupDir,Tmp,handles.axes1,handles.listbox2,handles);
    switch (handles.ReportRec.Detect)
        case 'Miss'
            DisplayAlgoFace([],0,handles.listbox5,[],[],handles);
            DisplayFace(BaseDir,Tmp,1,handles.axes2,1,handles.listbox3,handles.axes1,'red',handles);
        case 'FalseAlarm'
            DisplayFace(BaseDir,Tmp,1,handles.axes2,1,handles.listbox3,handles.axes1,'yellow',handles);

            DisplayAlgoFace(Tmp,1,handles.listbox5,handles.axes1,'yellow',handles);
        case 'Detect'
            if Tmp.FaceDat.ThumbDir(1)==' '
                Tmp.FaceDat.ThumbDir=Tmp.FaceDat.ThumbDir(2:end);
            DisplayFace(handles.BaseBackupDir,Tmp,1,handles.axes2,0,handles.listbox3,handles.axes1,'black',handles);
            DisplayAlgoFace(Tmp,1,handles.listbox5,handles.axes1,'green',handles);
            
            end
            DisplayFace(handles.BaseBackupDir,Tmp,1,handles.axes2,0,handles.listbox3,handles.axes1,'black',handles);
            DisplayAlgoFace(Tmp,1,handles.listbox5,handles.axes1,'green',handles);
            
    end
end
    

set(handles.listbox1,'Visible','off');
set(handles.listbox4,'Visible','off');

function [Img,handles]=AspectRatio640p(Img,FileData,handles)
% look also in GetFile2AlgoData for Y Factor!!
if ~isempty(Img)
      Size=size(Img);
else
    Size(1)=FileData.SizeY;
    Size(2)=FileData.SizeX;
end

handles.AspectRatioX=Size(2)/handles.AspectRatioXSize;
%handles.AspectRatioY=Size(1)/handles.AspectRatioYSize;
handles.AspectRatioY=handles.AspectRatioX;
handles.AspectRatioYSizeM=Size(1)/handles.AspectRatioY;
handles.AspectRationYCorrection=handles.AspectRatioYSize/handles.AspectRatioYSizeM; % correct Y mesurments , so will fit algo that runs on 640X480 only image

handles.AspectRatioOffsetX=1;
handles.AspectRatioOffsetY=1;

if ~isempty(Img)
   Img = Img(handles.AspectRatioOffsetY:end,handles.AspectRatioOffsetX:end,:);
   Img = imresize(Img, [handles.AspectRatioYSizeM handles.AspectRatioXSize]);
end
