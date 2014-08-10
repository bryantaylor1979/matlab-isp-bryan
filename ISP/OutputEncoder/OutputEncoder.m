classdef OutputEncoder < handle
    properties (SetObservable = true)
        ClearVars = true;
        Enable_Gamma = true;
        Enable_Saturation = true;
        Enable_Contrast = true;
        imageIN
        imageOUT
        gamma = 2.2;
        contrast = 100;
        saturation = 100;
    end
    methods (Hidden=false)
        function RUN(obj)   
            obj.imageOUT = obj.imageIN;
            obj.imageOUT.image = [];
            
            image = obj.imageIN.image/obj.imageIN.fsd;
            image( image < 0.0 ) = 0.0; %Stop negative numbers
            
            if obj.Enable_Gamma == true
                image = obj.imgamma(image);
            end
            image = rgb2ycbcr(image);
            
            if obj.Enable_Saturation == true
                image = obj.imsaturation(image);
            end
            if obj.Enable_Contrast == true
                image = obj.imcontrast(image);
            end
            image = ycbcr2rgb(image);
            
            obj.imageOUT.image = image.*obj.imageIN.fsd;
            
            
            if obj.ClearVars == true
                obj.imageIN.image = [];
            end
        end
    end
    methods (Hidden=true)
        function obj = OutputEncoder()
        end
        function output = imgamma(obj,input)
        output = input.^(1/obj.gamma);
        end
        function output = imcontrast(obj,input)
%         ycbcrinput = rgb2ycbcr(input);
        output(:,:,1) = (input(:,:,1)-0.5).*(obj.contrast/100)+0.5;
        output(:,:,2) = input(:,:,2);
        output(:,:,3) = input(:,:,3); 
%         output = ycbcr2rgb(ycbcrinput1);
        end
        function output = imsaturation(obj,input)
%         ycbcrinput = rgb2ycbcr(input);
        output(:,:,1) = input(:,:,1);
        output(:,:,2) = (input(:,:,2)-0.5).*(obj.saturation/100)+0.5;
        output(:,:,3) = (input(:,:,3)-0.5).*(obj.saturation/100)+0.5; 
%         output = ycbcr2rgb(ycbcrinput1);
        end
    end
end