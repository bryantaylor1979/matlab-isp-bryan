
BaseDir='C:\My Documents\Bulk Image Downloader\group pictures japan faces\';
Dir=dir([BaseDir,'*.jpg']);
CountI=0;
CountC=0;
CopyrightImages=[];
for i=1:length(Dir)
    CountI=CountI+1;
    Exif=[];
    try
        warning('off','all');
        Exif = imfinfo([BaseDir,Dir(i).name]);
        warning('on','all');
    catch
    end
    if isstruct(Exif)
        Names = fieldnames(Exif);
        for j=1:length(Names)
            if ischar(Exif.(Names{j}))
                if strfind(Names{j},'Copyright')
                    display(['Copyright field in ',Dir(i).name]);
                    CountC=CountC+1;
                    CopyrightImages{CountC}=Dir(i).name;
                else
                    for k=1:size(Exif.(Names{j}),1);
                        Copyright=strfind(Exif.(Names{j})(k,:),'Copyright');
                        if ~isempty(Copyright)
                            display(['Copright in file : ',Dir(i).name,'  Field:',Names{j},': ',Exif.(Names{j})(k,:)]);
                            CountC=CountC+1;
                            CopyrightImages{CountC}=Dir(i).name;
                        end
                    end
                end
            end
            
        end
    end
end
display(['out of tootal ', num2str(CountI),' Images, in ',num2str(CountC), ' Copyright note was found']);

if CountC>0
    Input= questdlg('To delete Copyright images?');
    
    if strcmp(Input,'Yes')
        for i=1:length(CopyrightImages)
            delete([BaseDir,CopyrightImages{i}]);
        end
    end
end

