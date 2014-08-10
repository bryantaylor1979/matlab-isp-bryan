function Struct=ImportExel2StructArr(File)

%data should have uper row header text, 
%left col as numeric number ( to ensure that the data and textdata matches
% and should not define the header row as such in exel
% Struct=struct();
% D= importdata(File);
% 
% 
% Pages=fieldnames(D.textdata);
% for i=1:length(Pages)
%     Struct.(Pages{i})=struct();
%     Fields=D.textdata.(Pages{i})(1,:);
%    
%     for j=1:length(Fields)
%               if isfield(D.data, Pages{i}) && max(isnan((D.data.(Pages{i})(:,j))))==0 % no NaNs in the culomn
%                   for k=1:length(D.data.(Pages{i})(:,j))
%                       Struct.(Pages{i})(k).(Fields{j})={D.data.(Pages{i})(k,j)};
%                   end
%                else
%                    for k=2:size(D.textdata.(Pages{i}),1)
%                       Struct.(Pages{i})(k-1).(Fields{j})=D.textdata.(Pages{i})(k,j);
%                   end
%               end
%     end
% end

     [typ, Pages, fmt] = xlsfinfo(File) ;
     if ~strcmp(fmt,'xlWorkbookNormal') && ~strcmp(fmt,'xlExcel8')
         error('unsuported format');
         return
     end
     
     for i=1:length(Pages)
         
       [Num,Text,Raw]= xlsread(File,char(Pages(i)));
       NumS=size(Num);
       TextS=size(Text);
       RawS=size(Raw);
       if RawS(1) == 1
           continue
       end
       TextS=size(Text);
       if NumS(1)==0
           HeaderRawNumber=1;
           DataSize=TextS-[1 0];
       else
           DataSize=TextS-[1 0];
           %DataSize=NumS; % for the case that there is text longer then
                           %table before tabel as comment
           DataSize=max(DataSize,NumS);% for the case there is no text in data
           HeaderRawNumber=RawS(1)-NumS(1);   % assuming the lst raw before numbers apears is a  header line
       end
       Fields=Text(HeaderRawNumber,:);
       Struct.(char(Pages(i)))=cell2struct(Raw(HeaderRawNumber+1:HeaderRawNumber+DataSize(1),1:DataSize(2)),Fields,2);
     end
       

