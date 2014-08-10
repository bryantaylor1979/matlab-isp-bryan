function UpdateRemarkInReport()
% maintanance utility for Report DB


% update the field of remark in report , according to the directory were
% the thumbnail was found - the directory name become the remark
% the process is as follows
% run report with Thumbnail creation.
% copy the thumbnail to sub dir with remark name like 
%          Face         - for faulse alarm that is actualy a face
%          Profile      - for miss detect that is in profile
%          NonCritical  - for miss detect that is not critical


Ver=' Ver 1';
Date=date;

VerStr=[Ver,' ',Date];
BaseReportDir='C:\Documents and Settings\nsorek\Desktop';
BaseReportThumbDir='C:\Documents and Settings\nsorek\Desktop\Thumbnails';
ReportFile=[BaseReportDir,'\Report'];
ReportFileFull=[ReportFile,'.xls'];

BaseBackupDir='C:\Broadcom\FaceDB';
ImageFile=[BaseBackupDir,'\DB_Images_TempSum'];
FaceDBFile=[BaseBackupDir,'\DB_Faces_TempSum'];

ImageFileFull=[ImageFile,'.xls'];
FaceDBFileFull=[FaceDBFile,'.xls'];


%Backup Files
copyfile(ReportFileFull,[ReportFile,'_Back.xls']);
copyfile(ImageFileFull,[ImageFile,'_Back.xls']);
copyfile(FaceDBFileFull,[FaceDBFile,'_Back.xls']);

StructMatch.All=[];
StructIn.All=[];

R=ExelInt('Get',ReportFile,StructIn,StructMatch,[]);


ImgDataSum=ExelInt('Get',ImageFile,StructIn,StructMatch,[]);

Temp=cell(length(ImgDataSum.ImgFiles),1);
[Temp{:}]=ImgDataSum.ImgFiles.FileName;
Img.FileName=Temp;
[Temp{:}]=ImgDataSum.ImgFiles.Dir;
Img.Dir=Temp;

FaceDataSum=ExelInt('Get',FaceDBFile,StructIn,StructMatch,[]);

Temp=cell(length(FaceDataSum.FaceDat),1);
[Temp{:}]=FaceDataSum.FaceDat.FileName;
Face.FileName=Temp;
[Temp{:}]=FaceDataSum.FaceDat.Dir;
Face.Dir=Temp;
[Temp{:}]=FaceDataSum.FaceDat.SmlThumbFile;
Face.SmlThumbFile=Temp;


BaseDir=dir([BaseReportThumbDir,'\*.']);
exp=['(.*?)','_','(.*?)','_','(.*?)'];

for i=3:length(BaseDir)
    Thumbs=dir([BaseReportThumbDir,'\',BaseDir(i).name,'\*.*']);
    for j=3:length(Thumbs) 
        tmp = regexp(Thumbs(j).name,exp,'tokens');
        Idx = str2double(tmp{1}{2});
        if ~isempty(Idx)
            R.FacesDetected(Idx).Remark=BaseDir(i).name;
            
            FileMatchF=strcmp(Img.FileName,R.FacesDetected(Idx).FileName);
            FileMatchD=strcmp(Img.Dir,R.FacesDetected(Idx).Dir);
            FileMatchF(FileMatchD==0)=0;
            FileIdx=find(FileMatchF==1);
            
            FaceMatchF=strcmp(Face.FileName,R.FacesDetected(Idx).FileName);
            FaceMatchD=strcmp(Face.Dir,R.FacesDetected(Idx).Dir);
            FaceMatchS=strcmp(Face.SmlThumbFile,R.FacesDetected(Idx).SmlThumbFile);
            FaceMatchF(FaceMatchD==0)=0;
            
            
            switch(R.FacesDetected(Idx).Remark)
                case {'Profile','NonCritical'}
                    FaceMatchF(FaceMatchS==0)=0;
                    FaceIdx=find(FaceMatchF==1);
                    if ~isempty(FaceIdx)
                        FaceDataSum.FaceDat(FaceIdx).Remark=R.FacesDetected(Idx).Remark;
                    end
                case 'Face'
                    FaceIdx=find(FaceMatchF==1);
                    Test=0;
                    for k=1:length(FaceIdx)
                        Test = TestFace(R.FacesDetected(Idx),FaceDataSum.FaceDat(FaceIdx(k)));
                        if Test
                            break
                        end
                    end
                    if ~Test
                        if ~isempty(FileIdx)
                            ImgDataSum.ImgFiles(FileIdx).NoOfFaces=ImgDataSum.ImgFiles(FileIdx).NoOfFaces+1;
                            FaceDataSum=AddFace(R.FacesDetected(Idx),FaceDataSum,ImgDataSum.ImgFiles(FileIdx),ImgDataSum.ImgFiles(FileIdx).NoOfFaces,VerStr);
                        
                        end
                    end
                    
                otherwise
            end
        end
    end
end

clear Img Face Temp



delete(ImageFileFull);
ExelInt('Update',ImageFile,ImgDataSum,StructMatch,[]);

clear ImgDataSum

delete(FaceDBFileFull);
ExelInt('Update',FaceDBFile,FaceDataSum,StructMatch,[]);

clear FaceDataSum

delete(ReportFileFull);
ExelInt('Update',ReportFile,R,StructMatch,[]);
            

function Test=TestFace(R,FaceDat)
OverlapXStart=max(R.FaceBoxRelX,FaceDat.FaceBoxRelX);
OverlapXEnd=min(R.FaceBoxRelX+R.FaceBoxRelW,FaceDat.FaceBoxRelX+FaceDat.FaceBoxRelW);
OverlapX=max(0,OverlapXEnd-OverlapXStart)/min(R.FaceBoxRelW,FaceDat.FaceBoxRelW);

OverlapYStart=max(R.FaceBoxRelY,FaceDat.FaceBoxRelY);
OverlapYEnd=min(R.FaceBoxRelY+R.FaceBoxRelH,FaceDat.FaceBoxRelY+FaceDat.FaceBoxRelH);
OverlapY=max(0,OverlapYEnd-OverlapYStart)/min(R.FaceBoxRelH,FaceDat.FaceBoxRelH);

Overlap=OverlapX*OverlapY;
Test=Overlap>0.25;


function FaceDataSum=AddFace(R,FaceDataSum,ImgData,NoOfFaces,VerStr)
FaceDataSum.FaceDat(end+1).Remark=R.Remark; % creat the entery
FaceFields=fieldnames(FaceDataSum.FaceDat);
for i=1:length(FaceFields)
    if isfield(R,FaceFields(i))
        FaceDataSum.FaceDat(end).(FaceFields{i})=R.(FaceFields{i});
    end
end
    FaceDataSum.FaceDat(end).SizeX=ImgData.SizeX;
    FaceDataSum.FaceDat(end).SizeY=ImgData.SizeY;
    FaceDataSum.FaceDat(end).ThumbFile=[];
    FaceDataSum.FaceDat(end).ThumbDir=[];
    FaceDataSum.FaceDat(end).SmlThumbFile=[];
    FaceDataSum.FaceDat(end).SmlThumbDir=[];


%create syntetich eye and Mouth
    FaceDataSum.FaceDat(end).LeftEyeRelX=R.FaceBoxRelX+R.FaceBoxRelW*0.4;
    FaceDataSum.FaceDat(end).RightEyeRelX=R.FaceBoxRelX+R.FaceBoxRelW*0.6;
    FaceDataSum.FaceDat(end).RightEyeRelY=R.FaceBoxRelY+R.FaceBoxRelH*0.4;
    FaceDataSum.FaceDat(end).LeftEyeRelY=R.FaceBoxRelY+R.FaceBoxRelH*0.4;
    FaceDataSum.FaceDat(end).MouthRelX=R.FaceBoxRelX+R.FaceBoxRelW*0.5;
    FaceDataSum.FaceDat(end).MouthRelY=R.FaceBoxRelY+R.FaceBoxRelH*0.6;

    FaceDataSum.FaceDat(end).Conf=max(R.DetConf1,max(R.DetConf2,max(R.PartDetConf1,R.ConfA)));
    FaceDataSum.FaceDat(end).FaceQuality=['BRCM','(',VerStr,')'];

    

%test that double adding is ok
