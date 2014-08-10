classdef BlackLevelSim
    properties
        ImageDim = 
    end
    methods
        function Example(obj)
           %%
           obj = BlackLevelSim;
           obj.RUN
        end
        function RUN(obj)
            %% Int Objects
            % Params
            width = 2016;
            height = 1512;
%             height = 200;
            WB_Gains = [3,1,1.4];
            
            ErrorMode = 'global'; %global or vertdroop
            Error_Offset = -5/1024;
            Error_Offset_Range = [-5/1024,  5/1024];
            
            ExpGain = 8;
            Sub_Offset =0/1024;
            WBmode = 'greyworld'; %preset or greyworld
            
            % Gen test image
            image = obj.GreyScale(width,height,20);
            
            % Inverse Gamma
            %
            imageout = obj.Gamma(image,2.2); , figure, imshow(imageout);      
            
            % Inverse WB % Exp  
            CG = WB_Gains.*ExpGain;
            Gains = 1./(CG);
            bayerimage = obj.ChannelGains(imageout,Gains); 
            
            % Fake black level error
            if strcmpi(ErrorMode,'global')    
                bayerimageC0 = obj.Offset(bayerimage,Error_Offset);
            else
                DroopImage = obj.DroopTestPattern(width,height,Error_Offset_Range);
                bayerimageC0 = imsubtract(bayerimage,DroopImage);
            end
            %
            
            % Clip
            bayerimageC0 = obj.Clip(bayerimageC0,[0,1]);
            
            if strcmpi(WBmode,'greyworld')
                % Grey world WB
                WBGains2 = obj.WBGainsGreyWorld(bayerimageC0);
            else
                WBGains2 = WB_Gains;
            end
            
            % WB & Exp
            Gains = WBGains2.*ExpGain;
            imageout = obj.ChannelGains(bayerimageC0,Gains);
            
            % Gamma
            imageout = obj.Gamma(imageout,(1/2.2));  
            
            % Subjective black level 
            imageout = obj.Offset(imageout,Sub_Offset);
            figure, imshow(imageout);
            title(['WB Gains: [',num2str(WB_Gains(1)),',',num2str(WB_Gains(2)),',',num2str(WB_Gains(3)),']'])
        end
        function Gains = WBGainsGreyWorld(obj,imagein)
            Energy(1) = mean2(imagein(:,:,1));
            Energy(2) = mean2(imagein(:,:,2));
            Energy(3) = mean2(imagein(:,:,3));
            Gains = max(Energy)./Energy;
        end
        function imageout = ChannelGains(obj,imagein,Gains)
            CG = ChannelGains;
            CG.RedGain = Gains(1);
            CG.GreenGain =  Gains(2);
            CG.BlueGain = Gains(3);
            imageout = CG.CG(imagein);            
        end
        function imageout = Offset(obj,imagein,offset)
            CO = ChannelOffsets;
            CO.RedOffset = offset;
            CO.GreenOffset = offset;
            CO.BlueOffset = offset;    
            imageout = CO.Process(imagein);
        end
        function imageout = Clip(obj,imagein,range)
            Red = imagein(:,:,1);
            Green = imagein(:,:,2);
            Blue = imagein(:,:,3);
            
            Red( Red > range(2) ) = range(2);
            Green( Green > range(2) ) = range(2);
            Blue( Blue > range(2) ) = range(2);
            
            Red( Red < range(1) ) = range(1);
            Green( Green < range(1) ) = range(1);
            Blue( Blue < range(1) ) = range(1);
            
            imageout(:,:,1) = Red;
            imageout(:,:,2) = Green;
            imageout(:,:,3) = Blue;            
        end
        function imageout = Gamma(obj,imagein,val)
            imageout = imagein.^(val);
        end
    end
end