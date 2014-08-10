function ExportStructArr2Exel(File,Struct)

Pages=fieldnames(Struct);

     for i=1:length(Pages)
         
        Fields=fieldnames(Struct.(char(Pages(i)))); 
        Raw=struct2cell(Struct.(char(Pages(i))));
        
        if(size(Raw,3)>1)
          Raw=struct2cell(Struct.(char(Pages(i)))'); 
        end
        Raw=[Fields,Raw];
       warning off MATLAB:xlswrite:AddSheet 
      [status, message]= xlswrite(File,Raw',char(Pages(i)));
     end
       

