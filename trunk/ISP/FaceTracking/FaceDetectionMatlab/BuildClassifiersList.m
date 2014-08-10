function BuildClassifiersList()

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
dirName = 'c:\Projects\FaceTracking\FaceDetect_V1.3\data\';

fid = fopen([dirName, 'classifiers.txt']);
fidOut = fopen([dirName, 'classifiers12x12.txt'], 'w');

tline = fgetl(fid);
while ischar(tline)
    
    line = str2num( tline );
    tresh = line(1);
    parity = line(2);
    type = line(3);
    x1 = line(4);
    x2 = line(5);
    x3 = line(6);
    x4 = line(7);
    y1 = line(8);
    y2 = line(9);
    y3 = line(10);
    y4 = line(11);
   
    if((x1<12) && (x2<12) && (x3<12) && (x4<12) && (y1<12) && (y2<12) && (y3<12) && (y4<12))
        fprintf(fidOut, '%d ', line);
        fprintf(fidOut, '\n');
    end
    
    tline = fgetl(fid);
end

fclose(fid);
fclose(fidOut);

return;