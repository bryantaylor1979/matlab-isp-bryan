function TestDB(ReportDir,DisplayImages)

DB=ParseHTMLDB([ReportDir,'Report.html']);
%ReportDir='C:\Public\BRCM\RND\SV5\FT\Tools\Mat DB\report\';
%  FaceS.FaceDat=[];
%  FileS.ImgFiles=[];

for i=1:length(DB);
    
    [pathstr, name, ext] = fileparts(DB{i}.FileName);
    switch (ext)
        case {'.jpg','.JPG','.bmp','.BMP'}
        otherwise
            display(['un supported format ',ext]);
            continue
    end
    if (DisplayImages)
        figure(1);
        if ~exist(   DB{i}.FileName,'file' )
            display(['unknownfile name ',DB{i}.FileName]);
            continue
        end
        Img=imread(DB{i}.FileName);
        image(Img);
        %S=size(Img);
        if isfield(DB{i},'Thumb') && ~isempty(DB{i}.Thumb)
            ImgT=imread([ReportDir,DB{i}.Thumb(1).File(3:end)]);
            %ST=size(ImgT);
            figure(2);
            image(ImgT);
        end
        figure(1);
        
    end
    [FileStruct, FaceStruct]=InitStruct();
    ImgDat.FileName=[name,ext];
    ImgDat.Dir=pathstr;
    if isfield(DB{i},'Thumb')
       ImgDat.ThumbFile=DB{i}.Thumb(1).File(3:end);
       ImgDat.ThumbWidth=str2num(DB{i}.Thumb(1).Width);
       ImgDat.ThumbHeight=str2num(DB{i}.Thumb(1).Height);
       ImgDat.ThumbDir=ReportDir;
    end
    FaceImg=0;
    S=[];
    ST(2)=ImgDat.ThumbWidth;
    ST(1)=ImgDat.ThumbHeight;
    
    for j=1:length( DB{i}.Param)
        switch (DB{i}.Param(j).Name)
            case 'facerect'
            if DB{i}.Param(j).Decode.Box(3)>0 && DB{i}.Param(j).Decode.Box(4)>0
                BoxRel=DB{i}.Param(j).Decode.Box;
                Box=DB{i}.Param(j).Decode.Box.*[S(2),S(1),S(2),S(1)];
                FaceStruct.FaceDat.FaceBoxRelX=BoxRel(1);
                FaceStruct.FaceDat.FaceBoxRelY=BoxRel(2);
                FaceStruct.FaceDat.FaceBoxRelW=BoxRel(3);
                FaceStruct.FaceDat.FaceBoxRelH=BoxRel(4);
                FaceStruct.FaceDat.FaceBoxX=Box(1);
                FaceStruct.FaceDat.FaceBoxY=Box(2);
                FaceStruct.FaceDat.FaceBoxW=Box(3);
                FaceStruct.FaceDat.FaceBoxH=Box(4);
                if (DisplayImages)
                    rectangle('Position',DB{i}.Param(j).Decode.Box.*[S(2),S(1),S(2),S(1)]);
                end
            end
        
            case 'facerectdata';
            if isfield(DB{i}.Param(j).Decode,'leye')
                FaceImg=1;
                Leye=DB{i}.Param(j).Decode.leye.*[S(2),S(1)];
                Reye=DB{i}.Param(j).Decode.reye.*[S(2),S(1)];
                Mouth=DB{i}.Param(j).Decode.mouth.*[S(2),S(1)];
                if (DisplayImages)
                    hold on;
                    plot(Leye(1),Leye(2),'*r');
                    plot(Reye(1),Reye(2),'*g');
                    plot(Mouth(1),Mouth(2),'*b');
                    hold off;
                    figure(2);
                    hold on;
                end
                LeyeT=((DB{i}.Param(j).Decode.leye-BoxRel(1:2))./BoxRel(3:4)).*[ST(2),ST(1)];
                ReyeT=((DB{i}.Param(j).Decode.reye-BoxRel(1:2))./BoxRel(3:4)).*[ST(2),ST(1)];
                MouthT=((DB{i}.Param(j).Decode.mouth-BoxRel(1:2))./BoxRel(3:4)).*[ST(2),ST(1)];
                if (DisplayImages)
                    plot(LeyeT(1),LeyeT(2),'*r');
                    plot(ReyeT(1),ReyeT(2),'*g');
                    plot(MouthT(1),MouthT(2),'*b');
                    hold off;
                    pause
                end
                FaceStruct.FaceDat.RightEyeRelX=DB{i}.Param(j).Decode.reye(1);
                FaceStruct.FaceDat.RightEyeRelY=DB{i}.Param(j).Decode.reye(2);
                FaceStruct.FaceDat.RightEyeX=DB{i}.Param(j).Decode.reye(1)*S(2);
                FaceStruct.FaceDat.RightEyeY=DB{i}.Param(j).Decode.reye(2)*S(1);
                FaceStruct.FaceDat.LeftEyeRelX=DB{i}.Param(j).Decode.leye(1);
                FaceStruct.FaceDat.LeftEyeRelY=DB{i}.Param(j).Decode.leye(2);
                FaceStruct.FaceDat.LeftEyeX=DB{i}.Param(j).Decode.leye(1)*S(2);
                FaceStruct.FaceDat.LeftEyeY=DB{i}.Param(j).Decode.leye(2)*S(1);
                FaceStruct.FaceDat.MouthRelX=DB{i}.Param(j).Decode.mouth(1);
                FaceStruct.FaceDat.MouthRelY=DB{i}.Param(j).Decode.mouth(2);
                FaceStruct.FaceDat.MouthX=DB{i}.Param(j).Decode.mouth(1)*S(2);
                FaceStruct.FaceDat.MouthY=DB{i}.Param(j).Decode.mouth(2)*S(1);
                FaceStruct.FaceDat.Conf=DB{i}.Param(j).Decode.conf;
                FaceStruct.FaceDat.Pan=DB{i}.Param(j).Decode.pan;
            end
            case 'facequality'
                FaceStruct.FaceDat.FaceQuality=DB{i}.Param(j).Val;
            case 'Width'
                S(2)=str2num(DB{i}.Param(j).Val);
                ImgDat.FileWidth=S(1);
            case 'Height'
                S(1)=str2num(DB{i}.Param(j).Val);
                ImgDat.FileHeight=S(1);
        end
    end % Param loop
    if FaceImg==1 % it is a fec image
        FaceStruct.FaceDat.FileName=ImgDat.FileName;
        FaceStruct.FaceDat.Dir=ImgDat.Dir;
        FaceStruct.FaceDat.SizeX=ImgDat.FileWidth;
        FaceStruct.FaceDat.SizeY=ImgDat.FileHeight;
        FaceStruct.FaceDat.ThumbFile=ImgDat.ThumbFile;
        FaceStruct.FaceDat.ThumbDir=ImgDat.ThumbDir;
        FaceStruct.FaceDat.ThumbWidth=ImgDat.ThumbWidth;
        FaceStruct.FaceDat.ThumbHeight=ImgDat.ThumbHeight;
        if  ~exist('FaceS','var')
            FaceS.FaceDat(1)=FaceStruct.FaceDat;
        else
            FaceS.FaceDat(end+1)=FaceStruct.FaceDat;
        end
        
    else
        FileStruct.ImgFiles.FileName=ImgDat.FileName;
        FileStruct.ImgFiles.Dir=ImgDat.Dir;
        FileStruct.ImgFiles.SizeX=ImgDat.FileWidth;
        FileStruct.ImgFiles.SizeY=ImgDat.FileHeight;
        FileStruct.ImgFiles.ThumbFile=ImgDat.ThumbFile;
        FileStruct.ImgFiles.ThumbDir=ImgDat.ThumbDir;
        FileStruct.ImgFiles.ThumbWidth=ImgDat.ThumbWidth;
        FileStruct.ImgFiles.ThumbHeight=ImgDat.ThumbHeight;
        if ~exist('FileS','var')
            FileS.ImgFiles(1)=FileStruct.ImgFiles;
        else
            FileS.ImgFiles(end+1)=FileStruct.ImgFiles;
        end
        
        
    end
end

for i=1:length(FileS.ImgFiles)
    for j=1:length(FaceS.FaceDat)
        if strcmp(FaceS.FaceDat(j).FileName,FileS.ImgFiles(i).FileName)
            FileS.ImgFiles(i).NoOfFaces=FileS.ImgFiles(i).NoOfFaces+1;
        end
    end
end

StructMatch.FaceDat.Non=[]; % append line;
if exist('DB_Faces.xls','file');
    delete('DB_Faces.xls');
end
StructOut=ExelInt('Update','DB_Faces',FaceS,StructMatch,[]);

StructMatch.ImgFiles.Non=[]; % append line;
if exist('ImgFiles.xls','file');
    delete('DB_Images.xls');
end
StructOut=ExelInt('Update','DB_Images',FileS,StructMatch,[]);


function [FileStruct, FaceStruct]=InitStruct()

FileStruct.ImgFiles.FileName=[];
FileStruct.ImgFiles.Dir=[];
FileStruct.ImgFiles.SizeX=[];
FileStruct.ImgFiles.SizeY=[];
FileStruct.ImgFiles.ThumbFile=[];
FileStruct.ImgFiles.ThumbDir=[];
FileStruct.ImgFiles.ThumbWidth=[];
FileStruct.ImgFiles.ThumbHeight=[];
FileStruct.ImgFiles.NoOfFaces=0;

FaceStruct.FaceDat.FileName=[];
FaceStruct.FaceDat.Dir=[];
FaceStruct.FaceDat.SizeX=[];
FaceStruct.FaceDat.SizeY=[];
FaceStruct.FaceDat.ThumbFile=[];
FaceStruct.FaceDat.ThumbDir=[];
FaceStruct.FaceDat.ThumbWidth=[];
FaceStruct.FaceDat.ThumbHeight=[];
FaceStruct.FaceDat.FaceBoxRelX=[];
FaceStruct.FaceDat.FaceBoxRelY=[];
FaceStruct.FaceDat.FaceBoxRelW=[];
FaceStruct.FaceDat.FaceBoxRelH=[];
FaceStruct.FaceDat.FaceBoxX=[];
FaceStruct.FaceDat.FaceBoxY=[];
FaceStruct.FaceDat.FaceBoxW=[];
FaceStruct.FaceDat.FaceBoxH=[];
FaceStruct.FaceDat.RightEyeRelX=[];
FaceStruct.FaceDat.RightEyeRelY=[];
FaceStruct.FaceDat.RightEyeX=[];
FaceStruct.FaceDat.RightEyeY=[];
FaceStruct.FaceDat.LeftEyeRelX=[];
FaceStruct.FaceDat.LeftEyeRelY=[];
FaceStruct.FaceDat.LeftEyeX=[];
FaceStruct.FaceDat.LeftEyeY=[];
FaceStruct.FaceDat.MouthRelX=[];
FaceStruct.FaceDat.MouthRelY=[];
FaceStruct.FaceDat.MouthX=[];
FaceStruct.FaceDat.MouthY=[];
FaceStruct.FaceDat.Conf=[];
FaceStruct.FaceDat.Pan=[];
FaceStruct.FaceDat.FaceQuality=[];