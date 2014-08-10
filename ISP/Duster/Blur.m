classdef Blur < handle
    % Example Blur 
    properties
        Size = 7
        Sigma = 10;
        plotcorMask = true
    end
    properties %Status properties
       mask_PSF 
    end
    methods
        function [image_out] = RUN(obj,image_in)
            %%
            PSF = fspecial('gaussian',obj.Size,obj.Sigma);
            image_out = imfilter(image_in,PSF,'symmetric','conv');
            if obj.plotcorMask == true
                figure
                surf(PSF)
            end
            obj.mask_PSF = PSF;
        end
    end
end
