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