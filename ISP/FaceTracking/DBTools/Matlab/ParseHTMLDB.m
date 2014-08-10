function [DB,Source]=ParseHTMLDB(FileName)

%text =fileread('C:\Temp\DB\report\Report.html');
text =fileread(FileName);
 p1='<tr><td>Source:</td><td>';
 p2='</td></tr>';
exp=[p1,'(.*?)',p2];
[s e tok ] = regexp(text,exp,'once') ;
Source=text(tok(1):tok(2));

 p1='<tr><td>File name:</td><td>';
 p2='</td></tr>';
exp=[p1,'(.*?)',p2];
[s e tok ] = regexp(text,exp) ;
s(end+1)=length(text);
DB=[];
for i=1:length(s)-1
    TmpStr=text(tok{i}(1):tok{i}(2));
    
    %%%%%%%%%%%%%%%% Clean special chars from File Name
    Find=strfind(TmpStr,'&amp;');
    while ~isempty(Find)
      TmpStr=[TmpStr(1:Find(1)),TmpStr(Find(1)+5:end)];
      Find=strfind(TmpStr,'&amp;');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DB{i}.FileName=TmpStr;
    p3='<tr><td>File size:';
    p4='</table>';
    exp1=[p3,'(.*?)',p4];
    text1=text(s(i):s(i+1));
    [s1 e1 tok1 ] = regexp(text1,exp1) ;
    text2=text1(s1:e1);
    p5='<tr><td>';
    p6='</td><td>';
    p7='</td></tr>';
    exp2=[p5,'(.*?)',p6,'(.*?)',p7];
    [s2 e2 tok2 ] = regexp(text2,exp2) ;
    for j=1:length(tok2)
        DB{i}.Param(j).Name=text2(tok2{j}(1,1):tok2{j}(1,2)-1);
        DB{i}.Param(j).Val=text2(tok2{j}(2,1):tok2{j}(2,2));
        switch  (DB{i}.Param(j).Name)
            
            case ('facerect')
                    Val=DB{i}.Param(j).Val;
                    Left=hex2dec(Val(1:4))/2^16;
                   Top=hex2dec(Val(5:8))/2^16;
                    Right=hex2dec(Val(9:12))/2^16;
                    Butom=hex2dec(Val(13:16))/2^16;
                    DB{i}.Param(j).Decode.Box=[Left,Top,Right-Left,Butom-Top];
            case  'facerectdata'
                   Val=[DB{i}.Param(j).Val,'End'];
                   pt1='conf';
                   pt2=',pan';
                   pt3=',leye';
                   pt31=',';
                   pt4=',reye';
                    pt41=',';
                   pt5=',mouth';
                    pt51=',';
                   pt6='End';
                    expt=[pt1,'(.*?)',pt2,'(.*?)',pt3,'(.*?)',pt31,'(.*?)',pt4,'(.*?)',pt41,'(.*?)',pt5,'(.*?)',pt51,'(.*?)',pt6];
                   tmp=regexp(Val,expt,'tokens');
                   if ~isempty(tmp) && length(tmp{1})==8;
                       DB{i}.Param(j).Decode.conf=str2num(tmp{1}{1});
                       DB{i}.Param(j).Decode.pan=str2num(tmp{1}{2});
                       DB{i}.Param(j).Decode.leye=[str2num(tmp{1}{3}(2:end)),str2num(tmp{1}{4}(1:end-1))];
                       DB{i}.Param(j).Decode.reye=[str2num(tmp{1}{5}(2:end)),str2num(tmp{1}{6}(1:end-1))];
                       DB{i}.Param(j).Decode.mouth=[str2num(tmp{1}{7}(2:end)),str2num(tmp{1}{8}(1:end-1))];
                       
                   end
                       
                   
                
        end
    end
    p8='<img src="';
    p9='" width="';
    p10='" height="';
    p11='" alt="" />';
     exp3=[p8,'(.*?)',p9,'(.*?)',p10,'(.*?)',p11];
     text3=text1(s1:end);
      [s3 e3 tok3 ] = regexp(text3,exp3) ;
    
     for j=1:length(tok3)
        DB{i}.Thumb(j).File=text3(tok3{j}(1,1):tok3{j}(1,2));
        DB{i}.Thumb(j).Width=text3(tok3{j}(2,1):tok3{j}(2,2));
        DB{i}.Thumb(j).Height=text3(tok3{j}(3,1):tok3{j}(3,2));
    end
     
     
end

