function ConvertExtTxt2AlgXLS(ExtFile,AlgFile,BaseDir, AlgoName)
% convert a file sent by Ext analysis to Alg.xls file to be read by BrowsDB
%currently used on files sent from CBG
%ExtFile - is the external text file including path
%AlgFile - is the result file including path.
%BaseDir - the base dir of images as appears in the text file ; like /mfs/sd
%AlgoName - Name of current algorith as it will appear in xls file
% use example  ConvertExtTxt2AlgXLS('C:\Public\BRCM\RND\SV5\FT\Tools\Mat DB\results.txt','C:\Documents and Settings\nsorek\Desktop\ExtAlg.xls','/mfs/sd');

[path,file,ext]=fileparts(AlgFile);

if isempty(ext)
    FullAlgFile=[AlgFile,'.xls'];
else
    FullAlgFile=AlgFile;
    AlgFile=[path,'\',file];
end

   f=fopen(ExtFile);
   FaceCount=0;
   Line=fgetl(f);
   while ~isempty(Line) && Line(1)~=-1
      
      b=strfind(Line,'/');
      Line(b)='\';
      g=strfind(Line,' ');
      Xsize=str2double(Line(1:g(1)-1));
      Ysize=str2double(Line(g(1)+1:g(2)-1));
      FaceNo=str2double(Line(g(2)+1:g(3)-1));
      FaceNFile=(Line(g(3)+1:end));
      [Fpath,Ffile,Fext]=fileparts(FaceNFile);
      RelPath=['.',Fpath(length(BaseDir)+1:end)];
      Ratio640p=(640/Xsize)*Ysize/480;
      for i=1:FaceNo
          LineF=fgetl(f);
          g=strfind(LineF,' ');
          X=str2double(LineF(1:g(1)-1));
          Y=str2double(LineF(g(1)+1:g(2)-1));
          W=str2double(LineF(g(2)+1:g(3)-1));
          H=str2double(LineF(g(3)+1:end));
          FaceCount=FaceCount+1;
          
          
          
          Algo.Faces(FaceCount).Dir=RelPath;
          Algo.Faces(FaceCount).FileName=Ffile;
          Algo.Faces(FaceCount).ConfA=0;
          Algo.Faces(FaceCount).FaceBoxRelX=X/Xsize;
          Algo.Faces(FaceCount).FaceBoxRelY=Y/Ysize*Ratio640p;
          Algo.Faces(FaceCount).FaceBoxRelW=W/Xsize;
          Algo.Faces(FaceCount).FaceBoxRelH=H/Ysize*Ratio640p;
          Algo.Faces(FaceCount).Algo=AlgoName;
      end
      Line=fgetl(f);
   end
             
    fclose(f);
    if exist([AlgFile,'.xls'],'file'); % replace any existing DB dile with the current one.
                delete([AlgFile,'.xls']);
    end
   StructMatch.Faces.Non=[]; % append line;
   ExelInt('Update',AlgFile,Algo,StructMatch,[]);