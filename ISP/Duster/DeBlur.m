classdef DeBlur < handle
    %
    % Author: Bryan Taylor
    % Author: 17th May 2012
    
    % TODO: Look at relationship with noise and the damper value. 
    %   Suggestion: 
    %       V = .0001;
    %       
    properties % Variables
        init_PSF = [1,1,1,1,1,1,1; ...
                    1,1,1,1,1,1,1; ...
                    1,1,1,1,1,1,1;
                    1,1,1,1,1,1,1;
                    1,1,1,1,1,1,1;
                    1,1,1,1,1,1,1];
                
        % Adaptive WT
        PSF_adaptive_wt = true %true or false 
                         %false -  even weighting for all pixels.
                         %true  -  add a weight off 1 to edges and dismiss
                         %         flat areas.  This char of this correction can be
                         %         controlled by edge_coring, and edge_widenControl
        edge_coring = 0.3;
        edge_widenControl = 2;
        
        % Adaptive Size        
        NoOfIterations = 30; % is the number of iterations, typically you need to increase 
                             % the number if your using the edge weighting scheme. 
                             
        damper = 0; % is an array that specifies the threshold deviation
                    % of the resulting image from the image I (in terms of the standard 
                    % deviation of Poisson noise) below which the damping occurs. The 
                    % iterations are suppressed for the pixels that deviate within the 
                    % DAMPAR value from their original value. This suppresses the noise 
                    % generation in such pixels, preserving necessary image details
                    % elsewhere. Default is 0 (no damping).
                    
        Readout = 0  % is an array (or a value) corresponding to the
                     % additive noise (e.g., background, foreground noise) and the variance 
                     % of the read-out camera noise. READOUT has to be in the units of the
                     % image. Default is 0.
        auto_border_wt_removal = true;
    end
    properties %Status properties
        mask_PSF % The resulting PSF is a positive array of
                 % the same size as the INITPSF, normalized so its sum adds to 1. The
                 % PSF restoration is affected strongly by the size of its initial
                 % guess, INITPSF, and less by its values (an array of ones is a safer
                 % guess).                 
        plotcorMask = true       
        pixelwt = []; % is assigned to each pixel to reflect its recording
                      % quality in the camera. A bad pixel is excluded from the solution by
                      % assigning it zero weight value. Instead of giving a weight of one for
                      % good pixels, you can adjust their weight according to the amount of
                      % flat-field correction. Default is a unit array of the same size as 
                      % input image I.
        borderSize = []; %Lock to PSF size.
    end
    methods
        function [image_out] = RUN(obj,image_in)
            %%
            if obj.PSF_adaptive_wt == true
                disp('PSF_adaptive wt mode: TRUE')
                obj.pixelwt = obj.WeightToEdges(image_in,obj.edge_coring,obj.edge_widenControl);
            else
                disp('PSF_adaptive wt mode: FALSE')
                obj.pixelwt = ones(size(image_in)); 
            end
            
            
            if obj.auto_border_wt_removal == true
                obj.borderSize = (size(obj.init_PSF,1)-1)/2
            else
                obj.borderSize = 0;
            end
            if not(obj.borderSize == 0)
                obj.pixelwt = obj.ZeroWeightBorder(obj.pixelwt,obj.borderSize);
            end
            figure;imshow(obj.pixelwt);title('Weight array');
            
            %Make sure the dampers is the correct class
            classDamper =  class(image_in)
            obj.damper = feval(classDamper,obj.damper);
            obj.Readout = feval(classDamper,obj.Readout);
            
            [image_out, PSF] = deconvblind( image_in, ...
                                            obj.init_PSF, ...
                                            obj.NoOfIterations, ...
                                            obj.damper, ...
                                            obj.pixelwt, ...
                                            obj.Readout);
            if obj.plotcorMask == true
                figure
                subplot(121); surf(PSF)
                subplot(122); imshow(PSF,[],'InitialMagnification','fit');
            end
            obj.mask_PSF = PSF;
        end
    end
    methods %Pixel Weighting Structure
        function WEIGHT = ZeroWeightBorder(obj,WEIGHT,borderSize)
                %%
                WEIGHT([1:borderSize end-[0:borderSize-1]],:) = 0;
                WEIGHT(:,[1:borderSize end-[0:borderSize-1]]) = 0;
        end
        function WEIGHT = WeightToEdges(obj,imagein,coring,widenControl)
            % The ringing in the restored image, J3, occurs along the areas of sharp 
            % intensity contrast in the image and along the image borders. This example 
            % shows how to reduce the ringing effect by specifying a weighting function. 
            % The algorithm weights each pixel according to the WEIGHT array while 
            % restoring the image and the PSF. In our example, we start by finding the 
            % "sharp" pixels using the edge function. By trial and error, we determine 
            % that a desirable threshold level is 0.3
            WEIGHT = edge(imagein,'sobel',coring);
            
            se = strel('disk',widenControl);
            WEIGHT = 1-double(imdilate(WEIGHT,se));
        end
    end
    methods %PSF constrainsts
        % TODO: PSF_forceSymetry by using FUN?  
        function FUN = PSF_forceSymetry(obj,PSF)
            %%
            FUN = @(PSF) ...
                  padarray(PSF(Step+1:end-Step,Step+1:end-Step),[Step,Step]); ...
                  disp('hello')
        end
    end
end