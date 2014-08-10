%%
% min(min(rawBayerEDOF_off))/2^4
image = double(EDOF_off)./2^16;

%% double
% clear classes
figure;
obj = NokiaSimplePipe;
obj.Contrast = 130;
obj.Ped = 110;
obj.Process(image);