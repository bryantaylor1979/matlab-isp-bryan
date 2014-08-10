classdef NokiaSimplePipe
    properties
        InputImage
        OutputImage
        ColourMatrix = [ 2.562, -1.473, -0.089; ...
                        -0.509,  1.712, -0.203; ...
                         0.003, -0.721,  1.724 ];   % DayLight Matrix
        Gamma = 2.2;
        Contrast = 115;
        Saturation = 115;
        Ped = 64; %Value in 10-bit world. 
        FakeGain = false; %Workaround for AV comparison.
        WB_Mode = 'automatic'; %automatic or manual
        ManualRedGain = 1;
        ManualGreenGain = 1;
        ManualBlueGain = 1;
    end
    methods
        function [image,Gains] = Process(obj,bayerimage)
           %% 
%             bayerimage = obj.GetImages;
            bayerimage = double(bayerimage);
            image = obj.Demosaic(bayerimage);
%             h = DisplayImage(image,'Stage 1 - Demosaic');
            
            %% CO
            image = obj.ChannelOffset(image);
%             h = DisplayImage(image,'Stage 2 - Remove Pedastel');

            %% WB
            objWB = WhiteBalance;
            
            objWB.Mode = obj.WB_Mode; %automatic or manual
            objWB.ManualRedGain = obj.ManualRedGain;
            objWB.ManualGreenGain = obj.ManualGreenGain;
            objWB.ManualBlueGain = obj.ManualBlueGain; 
            
            image = objWB.RUN(image);
            
            RedGain = objWB.RedGain;
            GreenGain = objWB.GreenGain;
            BlueGain = objWB.BlueGain;
            Gains = [RedGain,GreenGain,BlueGain];
            disp(['RGB: [',num2str(RedGain),',',num2str(GreenGain),',',num2str(BlueGain),']'])

%             h = DisplayImage(image,'Stage 3 - White Balanced'); 
            
            %%
            [image] = obj.Matrix(image);
%             h = DisplayImage(image,'Stage 4 - Matrix') 
            
            %%
            [image] = obj.OutputEncoder(image);
%             imshow(image)
            %%
%             h = DisplayImage(image,'Stage 5 - Sat, Contrast') 
%             imwrite(image,obj.OutputImage);         
        end
    end
    methods (Hidden = false)
        function bayerimage = GetImages(obj)
%             currentdir = pwd;
%             cd(currentdir);
%             [name,path] = uigetfile('*.bmp','MultiSelect', 'on');
%             bayerimage = readimage([path,name]);
            bayerimage = obj.readimage(obj.InputImage);
        end
        function imageout = Matrix(obj,imagein)
            cmx = ColourMatrix();
            cmx.StaticMatrix = obj.ColourMatrix;
            [imageout] = cmx.Process(imagein);
        end
        function imageout = ChannelGains(obj,imagein,Gains)
            CG = ChannelGains();
            CG.RedGain = Gains(1);
            CG.GreenGain = Gains(2);
            CG.BlueGain = Gains(3);
            [imageout] = CG.Process(imagein);
        end
        function imageout = OutputEncoder(obj,imagein)
            OutEnc = OutputEncoder();
            OutEnc.gamma = obj.Gamma;
            OutEnc.contrast = obj.Contrast;
            OutEnc.saturation = obj.Saturation;
            imageout = OutEnc.Process(imagein);
        end
        function imageout = Demosaic(obj,imagein)
           Dem = Demosaic;
           Dem.BayerOrder = 3;
           imageout = Dem.Run(imagein);
        end
        function imageout = ChannelOffset(obj,imagein)
            CO = ChannelOffsets;
            CO.RedOffset = obj.Ped/1024;
            CO.GreenOffset = obj.Ped/1024;
            CO.BlueOffset = obj.Ped/1024;
            imageout = CO.Process(imagein);
        end       
        function GainsOut = CWB(obj,GainsIn)
            cwb = ConstrainedWhiteBalance();
            
            %% Constrained White Balance
            cwb.ConstrainerEnable = true;
            cwb.DynamicEnable = true;
            cwb.LocusA = [0.2245 0.5388];
            cwb.LocusB = [0.4009 0.319];
            cwb.MaximumDistanceFromLocus = 0.011;
            cwb.GainCeiling = 3.5;
            cwb.HighThreshold = 11008;
            cwb.LowThreshold = 6000;
            cwb.DynamicGain = 0.16;
            cwb.GainCeiling = 2.2;
            cwb.DesiredIntergrationTime = 2;
            
            [cwb,GainsOut] = cwb.Process([RedGain,GreenGain,BlueGain]);
        end
        function imageout = AV(obj,imagein)
            AV = FourChAntiVignetting();
            
             %% AV Parameters
            AV.Device = 725;
            AV.r2shift = 19;
            AV.UnityOffset_R = 64;
            AV.UnityOffset_GR = 64;
            AV.UnityOffset_GB = 64;
            AV.UnityOffset_B = 64;

            AV.HOffset_R = 22;
            AV.VOffset_R = 8;
            AV.r2_coeff_R = 60;
            AV.r4_coeff_R = -49;

            AV.HOffset_GR = 72;
            AV.VOffset_GR = -6;
            AV.r2_coeff_GR = 38;
            AV.r4_coeff_GR = -18;

            AV.HOffset_GB = 20;
            AV.VOffset_GB = -10;
            AV.r2_coeff_GB = 39;
            AV.r4_coeff_GB = -26;

            AV.HOffset_B = 98;
            AV.VOffset_B = 20;
            AV.r2_coeff_B = 35;
            AV.r4_coeff_B = -10;  
            
            %%
            [imageout] = AV.Process(imagein);
        end
        function [RedEnergy,GreenEnergy,BlueEnergy] = proMWWB(obj,imagein)
            mWWb = MWWBStats();
            
            mWWb.SaturationThreshold = 255;
            mWWb.BlueTilt = 1;
            mWWb.Green1Tilt = 1;
            mWWb.Green2Tilt = 1;
            mWWb.RedTilt = 1;
            
            [RedEnergy,GreenEnergy,BlueEnergy] = mWWb.Process(imagein.*256);  %Wb Energies
        end
        function [bayerimage] = readimage(obj,name)
        %Written by:    Bryan Taylor
        %Date Created:  23rd October 2008
        bayerimage = imread(name); %Read in image
        switch class(bayerimage)
            case 'uint8'
                bayerimage = double(bayerimage)./256;
            case 'uint16'
                bayerimage = double(bayerimage)./(2^16);
            otherwise
        
        end
        end
    end
end