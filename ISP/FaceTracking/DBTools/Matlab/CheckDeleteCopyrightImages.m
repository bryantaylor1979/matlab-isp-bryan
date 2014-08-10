
function Str= CheckDeleteCopyrightImages(BaseDir,SubDir,hDisplay)

Str=[];
%CheckDeleteCopyrightImages('C:\My Documents\Bulk Image Downloader',1)

Dir=dir([BaseDir,'\*']);

for i=1:length(Dir)
    if ~strcmp(Dir(i).name,'.') && ~strcmp(Dir(i).name,'..') &&isdir([BaseDir,'\',Dir(i).name]) && SubDir>0
        Str=[Str,CheckDeleteCopyrightImages([BaseDir,'\',Dir(i).name],SubDir,hDisplay)];
        
        
    end
end

 DisplayMsg(sprintf('Testing images in [ %s] for Copyright images\n',BaseDir),hDisplay);

%BaseDir='C:\My Documents\Bulk Image Downloader\group pictures japan faces\';
Dir=dir([BaseDir,'\*.jpg']);
CountI=0;
CountC=0;
CopyrightImages=[];
for i=1:length(Dir)
    
    CountI=CountI+1;
    [Copyright,Str1]=TestExifCopyright([BaseDir,'\',Dir(i).name]);
    
    if Copyright>0
        CountC=CountC+1;
        CopyrightImages{CountC}=Dir(i).name;
        %Str=[Str,sprintf('%s\n',Str1)];
        DisplayMsg(Str1,hDisplay);
        %display(Str1);
    end
    
end
Str1=[sprintf('in %s out of tootal %s Images, in %s Copyright note was found\n',BaseDir, num2str(CountI),num2str(CountC))];

Str=[Str,Str1];

if CountC>0
    Input= questdlg('To delete Copyright images?');
    
    if strcmp(Input,'Yes')
        DisplayMsg('Deleting Copyright images',hDisplay);
        %display('Deleting Copyright images');
        for i=1:length(CopyrightImages)
            delete([BaseDir,'\',CopyrightImages{i}]);
        end
    end
end
Str=[Str,sprintf('*********************************\n')];


function [Copyright,Str]=TestExifCopyright(File)
Exif=[];
Copyright=0;
Str=[];
    try
        warning('off','all');
        Exif = imfinfo(File);
        warning('on','all');
    catch
    end
    if isstruct(Exif)
        Names = fieldnames(Exif);
        for j=1:length(Names)
            if ischar(Exif.(Names{j}))
                if strfind(Names{j},'Copyright')
                    Str=['Copyright field in ',File,' with value=',Exif.(Names{j})];
                    Copyright=1;
                    
                else
                    for k=1:size(Exif.(Names{j}),1);
                        Copyright=strfind(Exif.(Names{j})(k,:),'Copyright');
                        if ~isempty(Copyright)
                            Str=['Copright in file : ',File,'  Field:',Names{j},': ',Exif.(Names{j})(k,:)];
                            Copyright=1;
                            
                        end
                    end
                end
            end
            
        end
    end