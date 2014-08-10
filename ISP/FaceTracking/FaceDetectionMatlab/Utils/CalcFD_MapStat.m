Map = linspace(0, 1, 256)'*ones(1, 3);

XSize = 640;
YSize = 480;
NumOfScales = 8;
NumOfMachines = 16;

disp(datestr(now))

cd c:\Projects\FaceDetection\FaceDetection\Images\AllTestImages\FaceMaps;
FileNames = dir('*FD_FaceMap_0.bmp'); 
NumOfFiles = length(FileNames);
Cascades = [7, 15, 30, 30, 50, 50, 50, 100, 120, 140, 160, 180, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200];

AllIdx = zeros(length(Cascades), NumOfFiles);
RunTimes = zeros(length(Cascades), NumOfFiles);

for i = 1:NumOfFiles     
    Img = imread(FileNames(i).name);
    CurrIdx = zeros(length(Cascades), 1);
    for k = 1:length(Cascades)
        AllIdx(k,i) = AllIdx(k,i) + length(Img(Img>=k*10));
        CurrIdx(k) = CurrIdx(k) + length(Img(Img>=k*10));
    end
    
    res1 = zeros(1,length(Cascades));
    res2 = zeros(1,length(Cascades));
    if( NumOfMachines == 32 )
        FeaturesPerClock = [7, 15, 32*ones(1,length(Cascades)-2)];
    else
        FeaturesPerClock = [7, 16*ones(1,length(Cascades)-1)];
    end

    for j = 1:length(Cascades)
        res1(j) = uint64(sum(Cascades(1:j) ./ FeaturesPerClock(1:j))*640*480*30*2);
        res2(j) = uint64(sum(double(Cascades(j+1:end)).*double(CurrIdx(j:end-1)') ./ FeaturesPerClock(j+1:end))*30*24*2); 
    end

    RunTimes(:, i) = (res1 + res2);
    
% % %     disp('                                                                 ');
% % %     disp(['File name: ' FileNames(i).name]);
% % %     disp( uint64([res1', res2', (res1 + res2)'] ));
% % %     disp(['Min run time: ' num2str(uint64(RunTimes(i))) ' for file: ' FileNames(i).name]);

end

MeanAllIdx = uint32( mean(AllIdx,2));
% MaxAllIdx = uint32( max(AllIdx'))';

res1 = zeros(1,length(Cascades));
res2 = zeros(1,length(Cascades));
if( NumOfMachines == 32 )
    FeaturesPerClock = [7, 15, 32*ones(1,length(Cascades)-2)];
else
	FeaturesPerClock = [7, 16*ones(1,length(Cascades)-1)];
end


for j = 1:length(Cascades)
    res1(j) = uint64(sum(double(Cascades(1:j)) ./ double(FeaturesPerClock(1:j)))*640*480*30*2);
    res2(j) = uint64(sum(double(Cascades(j+1:end)).*double(MeanAllIdx(j:end-1)') ./ FeaturesPerClock(j+1:end))*30*24*2); 
end

disp('  ')
disp('--------------------------------------------------------------------')
disp('  ')
disp(['Number of machines: ' num2str(NumOfMachines)]);
disp('  ')
disp(['Number of files: ' num2str(NumOfFiles)]);
disp( uint64([res1', res2', (res1 + res2)'] ));
disp('  ')
disp('Hist of minimum runtime when swap method (per cascade):');
[Y,I] = min(RunTimes,[],1);
histTime = hist([I 1:10]) - 1;
disp(histTime);

return;

