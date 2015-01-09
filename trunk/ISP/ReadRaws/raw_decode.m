function raw_decode()
%%
close all
clear classes
image = readraw('image_rfc.raw',[1920,1080]);

[rgbImage] = biDemosaic(double(image)./1024,4);
%rgbImage = demosaic(uint16(image),'grgb');
figure, imshow(rgbImage)
title('demosaic')

[RedEnergy,GreenEnergy,BlueEnergy] = GreyWorldEnergies(rgbImage,[0.01,0.99]);
[RedGain,GreenGain,BlueGain] = CalculateGains(RedEnergy,GreenEnergy,BlueEnergy)
[rgbImage] = CG(rgbImage,RedGain,GreenGain,BlueGain);
figure, imshow(rgbImage)
title('white balanced')

matrix =  [ 2.55, -1.49, -0.06; ...
           -0.58,  1.83, -0.25; ...
            0.09, -0.75,  1.66];  
rgbImage = colourmatrix(rgbImage,matrix);
figure, imshow(rgbImage)
title('colour matrix')

rgbImage = imgamma(rgbImage,2.2);
figure, imshow(rgbImage)
title('gamma')

rgbImage = imcontrast(rgbImage,120);
figure, imshow(rgbImage)
title('contrast')

rgbImage = imsaturation(rgbImage,120);
figure, imshow(rgbImage)
title('saturation')
end
function image = readraw(filename,imagesize)
id=fopen(filename);
image = fread(id,imagesize(1)*imagesize(2),'ubit10');
image = reshape(image,imagesize(1),imagesize(2));
image = rot90(image);
fclose(id);
end
function [rgbImage] = biDemosaic(image,config)

%Bilinear demosaicing for Bayer patterns
%
%config  : bayer order
%            config = 1  R G
%                        G B
%            config = 2  B G
%                        G R
%            config = 3  G R
%                        B G
%            config = 4  G B
%                        R G
[nRow nCol] = size(image);
rgbImage = zeros(nRow,nCol,3);

rbKernel = ...
    [ 0.25 0.5 0.25; ...
      0.50 1.0 0.50; ...
      0.25 0.5 0.25];

gKernel  = ...
    [0.00 0.25 0.00; ...
     0.25 1.00 0.25; ...
     0.00 0.25 0.00];

if config == 1,

  rRow = [1:2:nRow];
  rCol = [1:2:nCol];
  bRow = [2:2:nRow];
  bCol = [2:2:nCol];
  g1Row = [1:2:nRow];
  g1Col = [2:2:nCol];
  g2Row = [2:2:nRow];
  g2Col = [1:2:nCol];

elseif config == 2,

  rRow = [2:2:nRow];
  rCol = [2:2:nCol];
  bRow = [1:2:nRow];
  bCol = [1:2:nCol];
  g1Row = [1:2:nRow];
  g1Col = [2:2:nCol];
  g2Row = [2:2:nRow];
  g2Col = [1:2:nCol];

elseif config == 3,

  rRow = [1:2:nRow];
  rCol = [2:2:nCol];
  bRow = [2:2:nRow];
  bCol = [1:2:nCol];
  g1Row = [1:2:nRow];
  g1Col = [1:2:nCol];
  g2Row = [2:2:nRow];
  g2Col = [2:2:nCol];

else

  rRow = [2:2:nRow];
  rCol = [1:2:nCol];
  bRow = [1:2:nRow];
  bCol = [2:2:nCol];
  g1Row = [1:2:nRow];
  g1Col = [1:2:nCol];
  g2Row = [2:2:nRow];
  g2Col = [2:2:nCol];

end
rgbImage(rRow,rCol,1) = image(rRow,rCol);
rgbImage(bRow,bCol,3) = image(bRow,bCol);
rgbImage(g1Row,g1Col,2) = image(g1Row,g1Col);
rgbImage(g2Row,g2Col,2) = image(g2Row,g2Col);

% Interpolate the data here
rgbImage(:,:,1) = conv2(rgbImage(:,:,1),rbKernel,'same');
rgbImage(:,:,2) = conv2(rgbImage(:,:,2),gKernel,'same');
rgbImage(:,:,3) = conv2(rgbImage(:,:,3),rbKernel,'same');
   
end
function [LowAndHighThresholdedImage] = ThresholdedImage(image,Range)
LowThreshold = Range(1);  
HighThreshold = Range(2);

%% Reshape Image for processing
[x,y]= size(double(image(:,:,1)));
RedPixelReshape = reshape(image(:,:,1),x*y,1);
GreenPixelReshape = reshape(image(:,:,2),x*y,1);
BluePixelReshape = reshape(image(:,:,3),x*y,1);
[ReshapedImage] = [RedPixelReshape,GreenPixelReshape,BluePixelReshape];

%% If any of the MinVal is less than the low threshold then dismiss
MinVal = min(ReshapedImage,[],2);
n = find(MinVal>LowThreshold);
LowThresholdedImage = ReshapedImage(n,:);

%% If any data is above the high threshold then remove
MaxVal = max(LowThresholdedImage,[],2);
n = find(MaxVal<HighThreshold);
LowAndHighThresholdedImage = LowThresholdedImage(n,:);
end
function [RedEnergy,GreenEnergy,BlueEnergy] = GreyWorldEnergies(image,Thresh)
    %% Traditional White Balance
    %TODO: Simulate Low and High Threshold
    [ThresImage] = ThresholdedImage(image,Thresh);
    RedEnergy = mean(mean(ThresImage(:,1)));
    GreenEnergy = mean(mean(ThresImage(:,2)));
    BlueEnergy = mean(mean(ThresImage(:,3)));
end
function [RedGain,GreenGain,BlueGain] = CalculateGains(RedEnergy,GreenEnergy,BlueEnergy)
    %% Calculate Desired Gains
    Energies = [RedEnergy,GreenEnergy,BlueEnergy];
    MaxVal = max(Energies);
    RedGain = MaxVal/RedEnergy;
    GreenGain = MaxVal/GreenEnergy;
    BlueGain = MaxVal/BlueEnergy;
end
function [image] = CG(image,RedGain,GreenGain,BlueGain)
    % Channel Gains
    Red = image(:,:,1).*RedGain;
    Green = image(:,:,2).*GreenGain;
    Blue = image(:,:,3).*BlueGain;

    %Auto clip
    switch class(image)
        case 'uint8'
            PixelClip = 2^8 - 1;
        case 'uint16'
            PixelClip = 2^16 - 1;
        case 'double'
            PixelClip = 1;
        otherwise
            error('image class not supported')
    end

    %Clip output
    Red( Red > PixelClip ) = PixelClip;
    Green( Green > PixelClip ) = PixelClip;
    Blue( Blue > PixelClip ) = PixelClip;

    image(:,:,1) = Red;
    image(:,:,2) = Green;
    image(:,:,3) = Blue;
end
function output = imgamma(input,gamma)
output = input.^(1/gamma);
end
function output = imcontrast(input,contrast)
ycbcrinput = rgb2ycbcr(input);
ycbcrinput1(:,:,1) = (ycbcrinput(:,:,1)-0.5).*(contrast/100)+0.5;
ycbcrinput1(:,:,2) = ycbcrinput(:,:,2);
ycbcrinput1(:,:,3) = ycbcrinput(:,:,3);
output = ycbcr2rgb(ycbcrinput1);
end
function output = imsaturation(input,saturation)
ycbcrinput = rgb2ycbcr(input);
ycbcrinput1(:,:,1) = ycbcrinput(:,:,1);
ycbcrinput1(:,:,2) = (ycbcrinput(:,:,2)-0.5).*(saturation/100)+0.5;
ycbcrinput1(:,:,3) = (ycbcrinput(:,:,3)-0.5).*(saturation/100)+0.5;
output = ycbcr2rgb(ycbcrinput1);
end
function output = colourmatrix(input2,Matrix)
     [height width depth] = size( input2 )

     % Reshape 3-D array into a 2-D array to allow
     % matrix multiplication
     rsinput  = reshape( input2,  height*width,  depth );

     % Apply colour correction matrix
     % - note the ccm is transposed
     output = rsinput * Matrix';
     output(output > 1) = 1; %clip
     output(output < 0) = 0; %clip
     
     % Reshape 2-D array back into a 3-D array
     output = reshape( output, height, width, depth );
end