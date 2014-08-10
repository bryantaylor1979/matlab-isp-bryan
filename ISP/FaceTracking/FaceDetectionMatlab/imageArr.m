Map = linspace( 0, 1, 256 )' * ones( 1, 3 ); Map(256,2:3) = [0, 0];

clc
for i=1:2%410:2:5000
    fid = fopen(['C:\Efrat\face-detection\FaceDetectionTrail\ImgPrt', '_',num2str(i)]);
    %     fid = fopen(['C:\Efrat\face-detection\FaceDetectionTrail\24x24', '_',num2str(i)]);
    if(fid)
        I = fscanf(fid,'%d');
        fclose(fid);
        I=reshape(I,[24 24]);
        I=I';
        [Pass, cas] = Run1TimeFaceDetection(I);
        
        if(Pass)
            figure(10), image(uint8(I)), colormap(Map), title([num2str(i),' pass']);
            [num2str(i), ' Pass, cas:', num2str(cas)]
        else
            figure(10), image(uint8(I)), colormap(Map), title([num2str(i), ' fail', num2str(cas)]);
            [num2str(i), ' Fail cas:', num2str(cas)]
        end
        
        pause(0.5);
    end
end

