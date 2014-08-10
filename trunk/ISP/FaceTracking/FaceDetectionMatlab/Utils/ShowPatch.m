function ShowPatch(filename)
fid = fopen( filename, 'rb' );
Img1 = fread( fid, [24, 24], 'uint8' )'; 
fclose(fid);
imshow(uint8(Img1));