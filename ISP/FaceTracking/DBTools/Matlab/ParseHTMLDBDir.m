function [FileDir,Source]=ParseHTMLDBDir(FileName)

text =fileread(FileName);
 p1='<tr><td>Source:</td><td>';
 p2='</td></tr>';
exp=[p1,'(.*?)',p2];
[s e tok ] = regexp(text,exp,'once') ;
Source=text(tok(1):tok(2));

 p1='<tr><td>File name:</td><td>';
 p2='</td></tr>';
exp=[p1,'(.*?)',p2];
[s e tok ] = regexp(text,exp,'once') ;
File=text(tok(1):tok(2));

[FileDir, name, ext] = fileparts(File);
