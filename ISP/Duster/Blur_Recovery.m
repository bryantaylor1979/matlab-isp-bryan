%% 
close all

%%
clear all
clear classes
objBlur = Blur;
objDeBlur = DeBlur;
objNoise = NoiseAdder;

%% Read in image
%
% Step 1: Read Image
% The example reads in an intensity image. 
% The deconvblind function can handle arrays of any dimension
I = imread('cameraman.tif');
% I = checkerboard(8);
figure;imshow(I);title('Original Image');

%% Simulate a Blur
objBlur.Sigma = 10;
objBlur.Size = 7;
objBlur.plotcorMask = true
I2 = objBlur.RUN(I);
figure;imshow(I2);title('Blurred Image');

%% Add gaussian noise
objNoise.gaussian = 0.001
I3 = objNoise.RUN(I2);
figure;imshow(I3);title('Blurred And Noisey Image');

%% Add localvar noise
objNoise.gaussian = []
objNoise.localvar = 0.001
I3 = objNoise.RUN(I2);
figure;imshow(I3);title('Blurred And Noisey Image');

%% Add singlets noise
objNoise.localvar = []
objNoise.singlets = 0.001
I3 = objNoise.RUN(I2);
figure;imshow(I3);title('Blurred And Noisey Image');

%% Add speckle noise
objNoise.singlets = [];
objNoise.speckle = 0.01
I3 = objNoise.RUN(I2);
figure;imshow(I3);title('Blurred And Noisey Image');

%% Restore the Blurred Image Using undersized PSFs
objDeBlur.PSF_adaptive_wt = false;
objDeBlur.init_PSF = ones(3)
objDeBlur.auto_border_wt_removal = false;
objDeBlur.NoOfIterations = 10;

I3 = objDeBlur.RUN(I2);
figure;imshow(I3);title('Deblurred Undersized PSF');

%% Restore the Blurred Image Using oversized PSFs
objDeBlur.init_PSF = ones(11);
I4 = objDeBlur.RUN(I2);
figure;imshow(I4);title('Deblurring with Oversized PSF')

%% Restore the Blurred Image Using correctly sized PSFs
PSF_Size = 7;
objDeBlur.init_PSF = ones(PSF_Size);
I4 = objDeBlur.RUN(I2);
figure;imshow(I4);title('Deblurring with correct PSF')

%% Remove border
objDeBlur.auto_border_wt_removal = true;
I4 = objDeBlur.RUN(I2);
figure;imshow(I4);title('Remove the edges by pixel Wt')

%% Weighting on edges.
objDeBlur.PSF_adaptive_wt = true;
objDeBlur.edge_coring = 0.07;
objDeBlur.edge_widenControl = 2;
objDeBlur.borderSize = (PSF_Size-1)/2;
objDeBlur.NoOfIterations = 30;
I4 = objDeBlur.RUN(I2);
figure;imshow(I4);title('Weigthing on edges');


