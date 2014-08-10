function InitFaceDB()

FileStruct.ImgFiles.FileName=[];
FileStruct.ImgFiles.Dir=[];
FileStruct.ImgFiles.SizeX=[];
FileStruct.ImgFiles.SizeY=[];
FileStruct.ImgFiles.ThumbFile=[];
FileStruct.ImgFiles.ThumbDir=[];
FileStruct.ImgFiles.NoOfFaces=[];

FaceStruct.FaceDat.FileName=[];
FaceStruct.FaceDat.Dir=[];
FaceStruct.FaceDat.SizeX=[];
FaceStruct.FaceDat.SizeY=[];
FaceStruct.FaceDat.ThumbFile=[];
FaceStruct.FaceDat.ThumbDir=[];
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
FaceStruct.FaceDat.MouthEyeRelX=[];
FaceStruct.FaceDat.MouthEyeRelY=[];
FaceStruct.FaceDat.MouthEyeX=[];
FaceStruct.FaceDat.MouthEyeY=[];
FaceStruct.FaceDat.Conf=[];
FaceStruct.FaceDat.Pan=[];
FaceStruct.FaceDat.FaceQuality=[];

StructMatch.All=[];

StructOut=ExelInt('Update','DB_Images',FileStruct,StructMatch,[]);
StructOut=ExelInt('Update','DB_Faces',FaceStruct,StructMatch,[]);
