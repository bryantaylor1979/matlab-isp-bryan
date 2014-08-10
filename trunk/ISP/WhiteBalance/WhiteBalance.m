classdef WhiteBalance <  handle & ...
                         ChannelGains %& ...
   %                      FeederObject
    %Calculates grey world energies from image. 
    properties (SetObservable = true)
        ClearVars = true
        Enable = true;
        Thresh = [0,60000]
        RedEnergy
        GreenEnergy
        BlueEnergy
        RedNorm
        BlueNorm
        Mode = 'automatic'; %automatic or manual
        ManualRedGain
        ManualGreenGain
        ManualBlueGain
        imageIN
        imageOUT
        InputObject = [];
    end
    properties (Hidden = true, SetObservable = true)
        Mode_LUT = {  'automatic'; ...
                      'manual'};
    end
    methods (Hidden = false)
        function Example(obj)
            %%
            
        end
        function RUN(obj)
            %%
            
            if obj.Enable == true
                obj.imageOUT.image = []; %Save memory
                imagein = obj.imageIN.image;
                if strcmpi(obj.Mode,'automatic')
                    [obj.RedEnergy,obj.GreenEnergy,obj.BlueEnergy] = obj.GreyWorldEnergies(imagein);
                    [obj.RedGain,obj.GreenGain,obj.BlueGain] = obj.CalculateGains(obj.RedEnergy,obj.GreenEnergy,obj.BlueEnergy);
                else
                    obj.RedGain = obj.ManualRedGain;
                    obj.GreenGain = obj.ManualGreenGain;
                    obj.BlueGain = obj.ManualBlueGain;

                end
                obj.RedNorm = obj.RedGain/(obj.RedGain + obj.GreenGain + obj.BlueGain);
                obj.BlueNorm = obj.BlueGain/(obj.RedGain + obj.GreenGain + obj.BlueGain);
                
                %%
                obj.imageOUT.image = obj.CG(imagein);
                obj.imageOUT.type = obj.imageIN.type;
                obj.imageOUT.fsd = obj.imageIN.fsd;
                obj.imageOUT.bitdepth = obj.imageIN.bitdepth;
                obj.imageOUT.class = obj.imageIN.class;
                
                %%
                if obj.ClearVars == true
                    obj.imageIN.image = [];
                end
            else
                obj.imageOUT = obj.imageIN;
            end
        end
    end
    methods (Hidden = true)
        function obj = WhiteBalance(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end   
            if not(isempty(obj.InputObject))
                obj.ClassType = 'image';
                obj.LinkObjects;
                obj.UpdateLink;
            end            
        end
        function [RedEnergy,GreenEnergy,BlueEnergy] = GreyWorldEnergies(obj,image)
            %% Traditional White Balance
            %TODO: Simulate Low and High Threshold
            [ThresImage] = obj.ThresholdedImage(image,obj.Thresh);
            RedEnergy = mean(mean(ThresImage(:,1)));
            GreenEnergy = mean(mean(ThresImage(:,2)));
            BlueEnergy = mean(mean(ThresImage(:,3)));
        end
        function [LowAndHighThresholdedImage] = ThresholdedImage(obj,image,Range)
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
            disp(max(MaxVal))
            n = find(MaxVal<HighThreshold);
            LowAndHighThresholdedImage = LowThresholdedImage(n,:);
        end
        function [RedGain,GreenGain,BlueGain] = CalculateGains(obj,RedEnergy,GreenEnergy,BlueEnergy)
            %% Calculate Desired Gains
            Energies = [RedEnergy,GreenEnergy,BlueEnergy];
            MaxVal = max(Energies);
            RedGain = MaxVal/RedEnergy;
            GreenGain = MaxVal/GreenEnergy;
            BlueGain = MaxVal/BlueEnergy;
        end
    end
end