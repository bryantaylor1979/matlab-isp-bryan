function Str=FaceDBProcessBackup(ReportDir,BackupDir,BaseRelDir,OnlyFaces,BackupPicasa,BackupReport,hDisplay)



[OrgImageDir,Source]=ParseHTMLDBDir([ReportDir,'\Report.html']);


Uniq=datestr(now);
Uniq(Uniq==' ')='-';
Uniq(Uniq==':')='-';


ReportBackupDir=[BackupDir,'\Backups\',Uniq];



%backup Picasa Dir

if(BackupPicasa)
    mkdir([ReportBackupDir,'\','PicasaDB']);
    f=strfind(Source,'\');
    if ~isempty(f)
        Source=Source(1:f(end)-1);
    end
    copyfile([Source,'\*'],[ReportBackupDir,'\','PicasaDB']);
    DisplayMsg(['Picasa  DB backed up '],hDisplay);
else
    DisplayMsg(['Picasa  DB backed up skipped'],hDisplay);
end

%Create Exel report, and copy image files to backup dir
HtmlThumbReport2Exel(ReportDir,BackupDir,BaseRelDir,'DB',OnlyFaces,hDisplay);
%HtmlThumbReport2Exel([ReportBackupDir,'\','Report'],BackupDir,'DB',OnlyFaces,hDisplay);

%backup Report data
if ( BackupReport)
    mkdir([ReportBackupDir,'\','Report']);
    movefile([ReportDir,'\Report.html'],[ReportBackupDir,'\','Report']);
    movefile([ReportDir,'\Report_files'],[ReportBackupDir,'\','Report\Report_files']);
    DisplayMsg(['Report data backup '],hDisplay);
else
    DisplayMsg(['Report data backup skipped'],hDisplay);
end


Str=     sprintf('Image Dir %s  was proceesed to produce Exel Face DB\n ', OrgImageDir);
Str=[Str,sprintf('A backup dir was created in %s containing the Picasa DB \n', ReportBackupDir)];
Str=[Str,sprintf('Report file was moved to  %s ', [ReportBackupDir,'\','Report'])];
Str=[Str,sprintf('Operation Complted OK')];

