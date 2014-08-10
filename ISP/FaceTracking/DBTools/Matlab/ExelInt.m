function StructOut=ExelInt(Op,ImageFileName,StructIn,StructMatch,AltStruct)

%interface for exel files
%Structures have pages where each have filednames and values
% Struct.Page.Field(n)= value
%Op - Str with operation
%     'Update' - update values in exel and structure
%                appednd line if field / page does not exsit
%     'Get'    - get filtered info from exel file
%     'GetTree'-  get filtered info from all xl file in the tree below
%     'XlsTree'-  same as Get Tree + write result to xls file
%
%call like this
%StructOut=ExelInt('GetTree','.\Te*.xls',StructInM,StructMatch)
%ImageFileName - file name without extention, refering to the same file
%                with ext xls.
%                in Get Tree - the file name contain* to accomodate files
%                to be included in the search
%StructIn      - structure containing Pgae.Fiels type.
%                includes values to be updated or append into xls file
%                may include subset of the current fields in the xls, and
%                may include additional fields and pages. In this case the
%                fiields and pages will be added to the xls file, and be
%                padded with 0 or null were no other info is specified
%                In GetTree theis struct defines the info to be returned.
%                in this case if contains a pagename 'All' wil lreturen all
%                fields and pages
%StructMatch   - structure containing Pgae.Fiels type.
%                Defines the filter , or selection of fields
%                in Get , contains matching number of eneteries as Struct
%                In , so for each StructIn entery , the coresponding Filter
%                will be used
%                May contain Page ' All' or field 'All' in wich case all
%                may also contain 'non as field name to indicate no line to
%                be selected mainly in Update, in wich case the StructIn
%                line will be added to the file
%                fields or pages will pass the filter.
%                In GetTree used the same.
%AltStruct     - Alternative structure in, if we already read the Xls file,
%                and would like to use this interface for searching -
%                relevant only in  ' Get' operation

% Example of Get Tree
%StructOut=ExelInt('GetTree','.\Te*.xls',StructInM,StructMatch,[])
%StructInM =
%   All: []
%StructMatch =
%   All: []



StructOut.Fields=[];
StructOut.Values=[];

switch(Op)
    case 'Update'
        StructOut=ExelWirite(ImageFileName,StructIn,StructMatch);
    case 'Get'
        StructOut=ExelRead(ImageFileName,StructIn,StructMatch,AltStruct);
    case 'GetTree'
        StructOut=ExelReadTree(ImageFileName,StructIn,StructMatch);
    case 'XlsTree'
        StructOut=ExelReadTree(ImageFileName,StructIn,StructMatch);
        [pathstr, name, ext] = fileparts(ImageFileName) ;
        name(name=='*')='_';
        ExportStructArr2Exel([pathstr,'\',name,'_TempSum.xls'],StructOut) ;
    otherwise
end

function Struct=ExelReadTree(ImageFileName,StructInM,StructMatch)
Struct=[];
[pathstr, name, ext] = fileparts(ImageFileName) ;
name1=name;
name1(name1=='*')='_';
SumName=[pathstr,'\',name1,'_TempSum.xls'];

DirList=GetSubDirTree(pathstr);
for d=1:length(DirList)
    Files=dir([DirList{d},'\',name,'.xls']);
    for f=1:length(Files)
        if ~strcmp([DirList{d},'\',Files(f).name],SumName)
            StructIn=ExelRead([DirList{d},'\',Files(f).name(1:end-4)],StructInM,StructMatch,[]);
            
            
            PageIn=fieldnames(StructIn);
            
            %         if isempty(Struct)
            %             Struct=StructIn;
            %         else
            for i=1:length(PageIn)
                for l=1:length((StructIn.(PageIn{i})))
                    StructIn.(PageIn{i})(l).('XlsDir')=DirList{d};
                    StructIn.(PageIn{i})(l).('XlsFile')=Files(f).name;
                end
                
                if isfield(Struct,PageIn(i))==0
                    Struct.(PageIn{i})=StructIn.(PageIn{i});
                    
                else
                    
                    FieldsIn=fieldnames(StructIn.(PageIn{i}));
                    IsField= isfield(Struct.(PageIn{i}),FieldsIn);
                    for j=1:length(IsField)
                        if ~IsField(j)
                            Struct.(PageIn{i})(1).(FieldsIn{j})=[];
                        end
                    end
                    
                    %match fields
                    Lines=length(StructIn.(PageIn{i}));
                    for l=1:Lines
                        N=length(Struct.(PageIn{i}));
                        FieldsTotal=fieldnames(Struct.(PageIn{i}));
                        Found=0;
                        for n=1:N
                            for k=1:length(FieldsIn) %init new fields in previos records
                                if ~IsField(k) && isnumeric(StructIn.(PageIn{i})(l).(char(FieldsIn(k))));
                                    
                                    Struct.(PageIn{i})(n).(FieldsIn{k})= 0;
                                end
                            end
                        end
                        
                        for k=1:length(FieldsIn)
                            Struct.(PageIn{i})(N+1).(FieldsIn{k})= StructIn.(PageIn{i})(l).(FieldsIn{k});
                            
                        end
                        
                        
                        for t=1:length(FieldsTotal) % init uninitialized fields in new record
                            if isempty(Struct.(PageIn{i})(N+1).(FieldsTotal{t})) && isnumeric(Struct.(PageIn{i})(N).(FieldsTotal{t}));
                                Struct.(PageIn{i})(N+1).(FieldsTotal{t})=0;
                            end
                        end
                        % end % Found
                    end % Lines
                end %isPage
            end  % PAges
        end%if isnot the summary file
    end % is file
end %dir



function Struct=ExelWirite(ImageFileName,StructIn,StructMatch)


[pathstr, name, ext] = fileparts(ImageFileName) ;
File=[pathstr,'\', name,'.xls'];
if ~exist(File,'file')
    Struct=StructIn;
else
    Struct=ImportExel2StructArr(File);
    
    PageIn=fieldnames(StructIn);
    for i=1:length(PageIn)
        FieldsIn=fieldnames(StructIn.(PageIn{i}));
        if ~isfield(Struct,PageIn(i)) || isfield(StructMatch.(PageIn{i}),'Replace')
            Struct.(PageIn{i})=StructIn.(PageIn{i});
            
        else
            IsField= isfield(Struct.(PageIn{i}),FieldsIn);
            for j=1:length(IsField)
                if ~IsField(j)
                    Struct.(PageIn{i})(1).(FieldsIn{j})=[];
                end
            end
            
            %match fields
            Lines=length(StructMatch.(PageIn{i}));
            for l=1:Lines
                N=length(Struct.(PageIn{i}));
                FieldsMatch=fieldnames(StructMatch.(PageIn{i}));
                FieldsTotal=fieldnames(Struct.(PageIn{i}));
                CurrentFields=length(FieldsMatch);
                Found=0;
                for n=1:N
                    if isfield(StructMatch.(PageIn{i}),'All') % updae all fields
                        Match=CurrentFields;
                    elseif isfield(StructMatch.(PageIn{i}),'Non') % updtae no fields
                        Match=0;
                    else
                        Match=0;
                        for k=1:CurrentFields
                            if(StructMatch.(PageIn{i})(l).(FieldsMatch{k})==Struct.(PageIn{i})(n).(FieldsMatch{k}))
                                Match=Match+1;
                                
                            end
                        end
                    end
                    if Match>0 && Match==CurrentFields % all non new fields match
                        for k=1:length(FieldsIn)
                            Struct.(PageIn{i})(n).(FieldsIn{k})= StructIn.(PageIn{i})(l).(FieldsIn{k});
                            
                        end
                        Found=Found+1;
                    else
                        for k=1:length(FieldsIn)
                            if ~IsField(k) && isnumeric(StructIn.(PageIn{i})(l).(char(FieldsIn(k))));
                                
                                Struct.(PageIn{i})(n).(FieldsIn{k})= 0;
                            end
                        end
                    end
                end
                if Found==0 % no record to update found, appaned record
                    for k=1:length(FieldsIn)
                        Struct.(PageIn{i})(N+1).(FieldsIn{k})= StructIn.(PageIn{i})(l).(FieldsIn{k});
                    end
                    for t=1:length(FieldsTotal) % init uninitialized fields in new record
                        if isempty(Struct.(PageIn{i})(N+1).(FieldsTotal{t})) && isnumeric(Struct.(PageIn{i})(N).(FieldsTotal{t}));
                            Struct.(PageIn{i})(N+1).(FieldsTotal{t})=0;
                        end
                    end
                end % Found
            end % Lines
        end % is page
    end % PAges
end % is file

ExportStructArr2Exel(File,Struct) ;

function [StructOut,Ok]=ExelRead(ImageFileName,StructIn,StructMatch,AltStruct)
StructOut=[];
Ok=0;
[pathstr, name, ext] = fileparts(ImageFileName) ;
File=[pathstr,'\', name,'.xls'];

if exist(File,'file') || ~isempty(AltStruct)
    if isempty(AltStruct)
        Struct=ImportExel2StructArr(File);
    else
        Struct=AltStruct;
    end
    Ok=1;
    
    
    PageIn=fieldnames(Struct);
    for i=1:length(PageIn)
        if isfield(StructIn,PageIn(i)) || isfield(StructIn,'All')
            
            if isfield(StructIn,'All') || isfield(StructIn.(PageIn{i}),'All')
                FieldsIn=fieldnames(Struct.(PageIn{i}));
            else
                FieldsIn=fieldnames(StructIn.(PageIn{i}));
            end
            
            IsField= isfield(Struct.(PageIn{i}),FieldsIn);
            
            %match fields
            if isfield(StructIn,'All')
                Lines=1;
            else
                Lines=length(StructIn.(PageIn{i}));
            end
            NewLine=0;
            for l=1:Lines
                N=length(Struct.(PageIn{i}));
                FieldsTotal=fieldnames(Struct.(PageIn{i}));
                Found=0;
                if ~isfield(StructMatch,'All')
                    
                    
                    FieldsMatch=fieldnames(StructMatch.(PageIn{i}));
                    CurrentFields=length(FieldsMatch);
                    
                else
                    CurrentFields=1;
                end
                
                for n=1:N
                    if isfield(StructMatch,'All') || isfield(StructMatch.(PageIn{i}),'All') % updae all fields
                        Match=CurrentFields;
                    elseif isfield(StructMatch.(PageIn{i}),'Non') % updtae no fields
                        Match=0;
                    else
                        Match=0;
                        for k=1:CurrentFields
                            if isempty( StructMatch.(PageIn{i})(l).(FieldsMatch{k})) || ...
                                    (ischar(StructMatch.(PageIn{i})(l).(FieldsMatch{k})) && ...
                                    strcmp(StructMatch.(PageIn{i})(l).(FieldsMatch{k}),Struct.(PageIn{i})(n).(FieldsMatch{k}))) ||...
                                    (~ischar(StructMatch.(PageIn{i})(l).(FieldsMatch{k})) && ...
                                    (StructMatch.(PageIn{i})(l).(FieldsMatch{k})==Struct.(PageIn{i})(n).(FieldsMatch{k})))
                                Match=Match+1;
                                
                            end
                        end
                    end
                    
                    if Match>0 && Match==CurrentFields % all non new fields match
                        NewLine=NewLine+1;
                        for k=1:length(FieldsIn)
                            if IsField(k)
                                StructOut.(PageIn{i})(NewLine).(FieldsIn{k})= Struct.(PageIn{i})(n).(FieldsIn{k});
                            else
                                StructOut.(PageIn{i})(NewLine).(FieldsIn{k})=[];
                            end
                        end
                        Found=Found+1;
                        
                    end
                end
                if Found==0 % no record to update found, appaned record
                    for k=1:length(FieldsIn)
                        StructOut.(PageIn{i})(1).(FieldsIn{k})= [];
                    end
                    
                end % Found
            end % Lines
        end % is page
    end % PAges
end % is file




function DirList=GetSubDirTree(Dir)
%Dir
TmpDirList=dir(Dir);
Tmp=[];
for i=1:length(TmpDirList)
    if(TmpDirList(i).isdir==1)
        Tmp=[Tmp {[Dir,'\',TmpDirList(i).name]}];
    end
end
DirList=[];
for i=3:length(Tmp)
    DirList=[DirList GetSubDirTree(char(Tmp{i}))];
end
DirList=[{Dir} DirList];
