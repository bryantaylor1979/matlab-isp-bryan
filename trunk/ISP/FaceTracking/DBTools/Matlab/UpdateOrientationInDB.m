% maintanance utility for DB


% add/ updtae the field of Exif rotation for jpg files
BaseBackupDir='C:\Broadcom\FaceDB';
ImageFile=[BaseBackupDir,'\DB_Images_TempSum'];
FaceDBFile=[BaseBackupDir,'\DB_Faces_TempSum'];

ImageFileFull=[ImageFile,'.xls'];
FaceDBFileFull=[FaceDBFile,'.xls'];

%Backup Files
copyfile(ImageFileFull,[ImageFile,'_Back.xls']);
copyfile(FaceDBFileFull,[FaceDBFile,'_Back.xls']);

StructMatch.All=[];
StructIn.All=[];

ImgDataSum=ExelInt('Get',ImageFile,StructIn,StructMatch,[]);

Temp=cell(length(ImgDataSum.ImgFiles),1);
[Temp{:}]=ImgDataSum.ImgFiles.FileName;
Img.FileName=Temp;
[Temp{:}]=ImgDataSum.ImgFiles.Dir;
Img.Dir=Temp;

FaceDataSum=ExelInt('Get',FaceDBFile,StructIn,StructMatch,[]);

Temp=cell(length(FaceDataSum.FaceDat),1);
[Temp{:}]=FaceDataSum.FaceDat.FileName;
Face.FileName=Temp;
[Temp{:}]=FaceDataSum.FaceDat.Dir;
Face.Dir=Temp;




for i=1:length(ImgDataSum.ImgFiles)
    if strcmp(ImgDataSum.ImgFiles(i).FileName(end-2:end),'jpg') ||...
            strcmp(ImgDataSum.ImgFiles(i).FileName(end-2:end),'JPG') ||...
            strcmp(ImgDataSum.ImgFiles(i).FileName(end-2:end),'PEG') ||...
            strcmp(ImgDataSum.ImgFiles(i).FileName(end-2:end),'peg')
        
        try
          info = imfinfo([BaseBackupDir,ImgDataSum.ImgFiles(i).Dir(2:end),'\',ImgDataSum.ImgFiles(i).FileName]);
          %info = exifread([BaseBackupDir,ImgDataSum.ImgFiles(i).Dir(2:end),'\',ImgDataSum.ImgFiles(i).FileName]);
        catch
            info=[];
        end
        if isfield(info,'Orientation');
            ImgDataSum.ImgFiles(i).Orientation=info.Orientation;
            MatchF=strcmp(Face.FileName,ImgDataSum.ImgFiles(i).FileName);
            MatchD=strcmp(Face.Dir,ImgDataSum.ImgFiles(i).Dir);
            MatchF(MatchD==0)=0;
            Idx=find(MatchF==1);
            for j=length(Idx)
                FaceDataSum.FaceDat(j).Orientation=info.Orientation;
            end
        end
    end
    
end

delete(ImageFileFull);
delete(FaceDBFileFull);
ExelInt('Update',ImageFile,ImgDataSum,StructMatch,[]);
ExelInt('Update',FaceDBFile,FaceDataSum,StructMatch,[]);
            


% http://sylvana.net/jpegcrop/exif_orientation.html
% Exif Orientation Tag (Feb 17 2002)
% 
% Questions:
% Your patch is incomplete. The Exif spec describes an Orientation Tag. Shouldn't this be updated, too, by the jpegtran patch?
% My digital camera alters the Exif Orientation Tag to indicate the orientation of the captured scene. Isn't it possible to automatically correct the indicated images with jpegtran so that they come out in standard orientation?
% Answer & solution:
% The Exif specification defines an Orientation Tag to indicate the orientation of the camera relative to the captured scene. This can be used by the camera either to indicate the orientation automatically by an orientation sensor, or to allow the user to indicate the orientation manually by a menu switch, without actually transforming the image data itself.
% Here is an explanation given by TsuruZoh Tachibanaya in his description of the Exif file format:
% 
% The orientation of the camera relative to the scene, when the image was captured. The relation of the '0th row' and '0th column' to visual position is shown as below.
% 
% Value	0th Row	0th Column
% 1	top	left side
% 2	top	right side
% 3	bottom	right side
% 4	bottom	left side
% 5	left side	top
% 6	right side	top
% 7	right side	bottom
% 8	left side	bottom
% Read this table as follows (thanks to Peter Nielsen for clarifying this - see also below):
% Entry #6 in the table says that the 0th row in the stored image is the right side of the captured scene, and the 0th column in the stored image is the top side of the captured scene.
% Here is another description given by Adam M. Costello:
% 
% For convenience, here is what the letter F would look like if it were tagged correctly and displayed by a program that ignores the orientation tag (thus showing the stored image):
% 
%   1        2       3      4         5            6           7          8
% 
% 888888  888888      88  88      8888888888  88                  88  8888888888
% 88          88      88  88      88  88      88  88          88  88      88  88
% 8888      8888    8888  8888    88          8888888888  8888888888          88
% 88          88      88  88
% 88          88  888888  888888
% jpegtran does not change the Orientation Tag when performing lossless transformations. The reason is that it cannot rely on the validity of the stated information, and it could potentially confuse other applications if it would mistakenly rely on the information and change it appropriately.
% Furthermore, if you want automatic correction, then you must examine the field first to decide whether to call jpegtran at all and if yes with which transformation option.
% 
% Therefore, it has been found that the best solution to the problem would be to handle the examination and manipulation of the Exif Orientation field by separate utilities, not jpegtran.
% 
% To solve the task of automatic image orientation correction, we therefore provide two utility programs.
% 
% The first utility program is called jpegexiforient and is written in simple C. It only can read or write the Orientation Tag. It writes it out as ASCII character to stdout when called from the commandline.
% Here is the usage screen:
% 
% jpegexiforient reads or writes the Exif Orientation Tag in a JPEG Exif file.
% Usage: jpegexiforient [switches] jpegfile
% Switches:
%   --help     display this help and exit
%   --version  output version information and exit
%   -n         Do not output the trailing newline
%   -1 .. -8   Set orientation value 1 .. 8
% The second utility is a simple shell script called exifautotran which transforms Exif files so that Orientation becomes 1. It first calls jpegexiforient to examine the Orientation field, and then decides whether and how to call jpegtran so that Orientation becomes 1. It then calls jpegexiforient again to set the Orientation field accordingly to keep the information consistent.
% So if you run "exifautotran *.jpg" in a directory of JPEG files, all images will be automatically transformed. If all worked well and you would call it again, nothing more would happen because all Orientation values would have been set to 1 in the first run. This is exactly the desired behaviour. The script was tested on Linux and worked properly:
% 
% # exifautotran [list of files]
% #
% # Transforms Exif files so that Orientation becomes 1
% #
% for i
% do
%  case `jpegexiforient -n "$i"` in
%  1) transform="";;
%  2) transform="-flip horizontal";;
%  3) transform="-rotate 180";;
%  4) transform="-flip vertical";;
%  5) transform="-transpose";;
%  6) transform="-rotate 90";;
%  7) transform="-transverse";;
%  8) transform="-rotate 270";;
%  *) transform="";;
%  esac
%  if test -n "$transform"; then
%   echo Executing: jpegtran -copy all $transform $i
%   jpegtran -copy all $transform "$i" > tempfile
%   if test $? -ne 0; then
%    echo Error while transforming $i - skipped.
%   else
%    rm "$i"
%    mv tempfile "$i"
%    jpegexiforient -1 "$i" > /dev/null
%   fi
%  fi
% done
% This shell script as file here.
% The jpegexiforient.c source file here.
% Compile straightforward with "gcc -o jpegexiforient jpegexiforient.c".
% Thanks to Adam M. Costello and Peter Nielsen.
% 
% News (Aug 03 2002)
% 
% Nils Haeck (ABC-View) has incorporated the procedure in his ABC-View Manager application.
% See his article "Rotate JPG images losslessly using the EXIF orientation tag".
% Back to the Exif Patch Page 
% 
% J	P	E	G
% c	l	u	b
% .	o	r	g
% Back to the JPEGclub.org Jpegcrop & jpegtran page
% Peter Nielsen notes:
% It turns out that orientations #6 and #8 are 4-phase in contrast to all other orientations that are 2-phase. (In retrospective this should have been obvious because of the 90 degree rotation done in these orientations).
% 
% The 2-phase orientaions are of course bi-directional. The 4-phase ones are not.
% 
% Applying a 2-phase orientation on the viewed image gives the stored image and vice versa. However, this is NOT true for the 4-phase orientations.
% 
% (I did not realize this until now, and that's why I made the mistake of thinking that your page was wrong. I incorrectly assumed that all the transformations are 2-phase).
% 
% I have attached an illustration that shows this. I start off by the case you picture on your site as phase #0. Notice the interesting phase #3 where orientations #6 and #8 are 180 degrees off.
% 
%       1        2      3       4         5            6           7          8
% 
% Phase #0
%             
%    888888  888888      88  88      8888888888  88                  88  8888888888
%    88          88      88  88      88  88      88  88          88  88      88  88
%    8888      8888    8888  8888    88          8888888888  8888888888          88
%    88          88      88  88
%    88          88  888888  888888
%       
% Phase #1
%             
%    888888  888888  888888  888888    888888      888888      888888      888888
%    88      88      88      88        88          88          88          88
%    8888    8888    8888    8888      8888        8888        8888        8888
%    88      88      88      88        88          88          88          88
%    88      88      88      88        88          88          88          88
% 
% Phase #2
%    
%    888888  888888      88  88      8888888888  8888888888          88  88
%    88          88      88  88      88  88          88  88      88  88  88  88
%    8888      8888    8888  8888    88                  88  8888888888  8888888888
%    88          88      88  88
%    88          88  888888  888888
%      
% Phase #3
% 
%    888888  888888  888888  888888    888888          88      888888          88
%    88      88      88      88        88              88      88              88
%    8888    8888    8888    8888      8888          8888      8888          8888
%    88      88      88      88        88              88      88              88
%    88      88      88      88        88          888888      88          888888
% My mistake was that I started from Phase #1. (I took 8 EXIF images of an "F" and used the EXIF tag edit tool to change the orientation tag on each of the images to 1,2,3,4,5,6,7,8) I expected to get the Phase #0 images on your site. Big mistake! Of course I got the Phase #2 images instead and thought your site was wrong, since I knew for sure that PMView was doing this right :-) The only thing wrong was of course my failure to understand that this is a 4-phase transform and that I am not suppo
