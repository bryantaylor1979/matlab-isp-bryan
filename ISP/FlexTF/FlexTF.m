%% 987 controls
classdef FlexTF
    properties
        Enable = 'ForAllRatios'     %Disable 
                                    %ForAllRatios 
                                    %ForAllRatiosAboveOnce
        Mode = 'auto'               %Auto
                                    %Manual
        LUTupdate = true            %true or false
        PixelInShift = 2            %[0:5]
        ModulationSelect            %USER_ANCHOR_X
                                    %MEDIA
                                    %MEAN
                                    
        AnchorYRatio1 = 0.4         %0.4
        AnchorYRatio2 = 0.4
        AnchorYRatio4 = 0.274
        AnchorYRatio8 = 0.4
        
        UserAnchorYRatio1 = 0.5
        UserAnchorYRatio2 = 0.5
        UserAnchorYRatio4 = 0.22
        UserAnchorYRatio8 = 0.5
        
        AnchorXminRatio1 = 0.01
        AnchorXminRatio2 = 0.05
        AnchorXminRatio4 = 0.25
        AnchorXminRatio8 = 0.0125
        
        AnchorXmaxRatio1 = 0.5
        AnchorXmaxRatio2 = 0.5
        AnchorXmaxRatio4 = 0.5
        AnchorXmaxRatio8 = 0.5  
        
        Shape = 0.3
        Scale = 4095
    end
    methods
        function Main(obj)
            %% 8 bit plot
            fsd = 255;
            input = [0:fsd]
            output = [0:fsd]
            obj.plotTransferFunction(input,output,fsd)
            
            %% 16 bit plot
            fsd = 1023;
            input = [0:fsd]
            output = [0:fsd]
            obj.plotTransferFunction(input,output,fsd)   
            
            %%
            fsd = 255;
            input = [0:fsd];
            output = [0:fsd];
            [output] = obj.Gamma(   [0:1/255:1]  ,   2.2);
            obj.plotTransferFunction(input,output*255,fsd); 
            
            %% 13 to 12 bits
            in_fsd = 2^13;
            out_fsd = 2^12;  
            input_pixel = [0:in_fsd];
            input = input_pixel/in_fsd;
            
            [output] = obj.LightnessCurve(input,0.05)  
            obj.plotTransferFunction(input_pixel,output*out_fsd)
            
            %% standard gamma
            input = [0:1/255:1];
            
            % Gamma 2.2
            [output] = obj.Gamma(   input  ,   0);
            obj.plotTransferFunction(input,output,1,'k');
            
            % Lightness 0.05
            [output] = obj.LightnessCurve(   input  ,  0);
            obj.plotTransferFunction(input,output,1,'r');
            
            % Linear
            output = [0:1/255:1];
            obj.plotTransferFunction(input,output,1,'c');
            
            % Gamma 
            gamma = [1.5,1.8,2.2,4]
            for i = 1:max(size(gamma))
                [output] = obj.Gamma(   input  ,   gamma(i));
                obj.plotTransferFunction(input,output,1,'k');
            end
            
            % LightnessCurve
            lightparam = [0.04,0.5,0.8,1]
            for i = 1:max(size(lightparam))
                [output] = obj.LightnessCurve(   input  ,   lightparam(i));
                obj.plotTransferFunction(input,output,1,'r');
            end
            
            % Gamma 4
            [output] = obj.Gamma(   input  ,   4);
            obj.plotTransferFunction(input,output,1,'k');
            
            legend({'Gamma function'; ...
                    'Simple Lightness Curve'; ...
                    'Linear'})
        end
        function [output] = LightnessCurve(obj,input,param)
            %%
            scaleFactor = param + 1;
            output = scaleFactor .* input ./ (param + input);
        end
        function GenerateExpandedLUT(obj)
            %%

        end
        function [output] = Gamma(obj,input,gamma)
            %%
            output = input.^(1/gamma);
            output( output > 1.0 ) = 1.0;
            output( output < 0.0 ) = 0.0;
        end
        function plotTransferFunction(obj,input,output,fsd,marker)
            %%
            hold on
            plot(input,output,marker)
            xlim([0,fsd])
            ylim([0,fsd])
            xlabel('Input Pixel')
            ylabel('Output Pixel')   
            title('Flexible Transfer Function')
        end
    end
end