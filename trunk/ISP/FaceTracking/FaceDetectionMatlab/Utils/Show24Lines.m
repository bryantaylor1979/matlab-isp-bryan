function Show24Lines(filename)
fid = fopen( filename, 'rb' );
Img1 = fread( fid, [640, 24], 'uint8' )'; 
fclose(fid);
imshow(uint8(Img1));