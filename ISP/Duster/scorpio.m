%Scorpio is used to correct green imbalance mismatches. It works look ahead of
%ARCTIC-COMBO and filter remaining Gr/Gb mismatch. It works also in Recursive
%mode.
classdef scorpio < handle
    properties
        % Odd row
        % Even row
        % Odd row
        GRBG = [ 49,  NaN,   51; ...
                NaN,   60,  NaN; ...
                 52,  NaN,   50]
        % Scorpio coring level
        %Range 0,255
        %Default = 32
        Scorpio_Coring_Level = 32
        % Scorpio ceiling ones
        %Range 0,255
        %Default = 6
        Scorpio_Ceiling_Ones = 6
        log = true
    end
    methods
        function pixels = corrector(obj,pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            %%
            centre_pixel = pixels(2,2);
            ring_pixels = pixels(1:2:3,1:2:3);
            [angle, ga_status] = obj.Gradient_Analysis(centre_pixel,ring_pixels,stripeThreshold);
            [estimate, ac_status] = obj.Adaptive_Cositing(ring_pixels,angle);
            [nyquist_cored_centre_signal,nc_status] = obj.Nyquist_Coring(centre_pixel,estimate,coring_level,maximum_signal);
            [roughness,arm_status] = obj.Adaptive_roughness_measure(ring_pixels,ceiling);
            [output,ss_status] = obj.Soft_Switch(maximum_signal,roughness,angle,nyquist_cored_centre_signal,centre_pixel);
            
            pixels(2,2) = output;
            
            if obj.log == true
                obj.Log_Gradient_Analysis(ga_status);
                obj.Log_Adaptive_Cositing(ac_status);
                obj.Log_Nyquist_Coring(nc_status);
                obj.Log_Adaptive_roughness_measure(arm_status);
                obj.Log_Soft_Switch(ss_status);
                disp(' ')
                disp(' ')
            end
        end
        function [] = Main(obj)
            %%
            stripeThreshold = 20
            maximum_signal = 255 
            coring_level = 10
            ceiling = 20
            
            %% No stripe - Some ~ 15 code green imbalance
            pixels = [ 49,  NaN,   51; ...
                      NaN,   55,  NaN; ...
                       52,  NaN,   50]
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
              
            %% No stripe - Some ~ 30 code green imbalance
            % Beyond the stripeThreshold so this is not feasibly green
            % imbalance. Should not correct. 
            pixels = [  49,  NaN,   51; ...
                       NaN,   80,  NaN; ...
                        52,  NaN,   50]
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            
            %% NE stripe - Type 1
            pixels = [ 200,  NaN,   60; ...
                       NaN,   70,  NaN; ...
                        60,  NaN,   60]
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            
            %% NE stripe - Type 2
            pixels = [ 200,  NaN,   200; ...
                       NaN,  200,   NaN; ...
                       200,  NaN,    60];
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            
            %% SE stripe - Type 1
            pixels = [ 49,  NaN,   51; ...
                      NaN,   46,  NaN; ...
                      100,  NaN,   50]
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            
            %% SE stripe - Type 2
            pixels = [ 100,   NaN,    51; ...
                       NaN,   100,   NaN; ...
                       100,   NaN,   100];
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
            
            %% NE stripe that actually noise
            pixels = [ 81,  NaN,   60; ...
                      NaN,   60,  NaN; ...
                       60,  NaN,   60];
            pixels = obj.corrector(pixels,stripeThreshold,coring_level,ceiling,maximum_signal)
        end
        function [angle,status] = Gradient_Analysis(obj,centre_pixel,ringpixels,stripeThreshold)
            %%
            NW = ringpixels(1,1);
            SE = ringpixels(2,2);
            NE = ringpixels(1,2);
            SW = ringpixels(2,1);
            %%
            NW_SE_average = sum([NW,SE])/2;
            NE_SW_average = sum([NE,SW])/2;
            Ring_Average = sum([NE,NW,SE,SW])/4;
            
            %%
            ortho_stripe = abs(centre_pixel-Ring_Average);
            %ne_stripe = abs((CTR*2)+NE_SW_average-NW_SE_average)
            %se_stripe = abs((CTR*2)-NE_SW_average+NW_SE_average)
            ne_stripe = abs(centre_pixel-NE_SW_average)*2;
            se_stripe = abs(centre_pixel-NW_SE_average)*2;
            
            stripes = [ne_stripe,se_stripe,ortho_stripe];
            
            Comp = stripeThreshold < abs(stripes);
            if sum(Comp) == 0
                angle = NaN;
                status.ortho_stripe  = ortho_stripe;
                status.ne_stripe = ne_stripe;
                status.se_stripe = se_stripe;
                status.angle = angle;
                return
            end
            n = find(max(stripes) == stripes);
            if n == 1
                angle = 'SE';
            elseif n == 2
                angle = 'NE';
            elseif n == 3
                angle = NaN;                
            else
                error('angle not assigned') 
            end
            status.ortho_stripe  = ortho_stripe;
            status.ne_stripe = ne_stripe;
            status.se_stripe = se_stripe;
            status.angle = angle;
        end
        function [estimate,status] = Adaptive_Cositing(obj,ringpixels,angle)
            %%
            NW = ringpixels(1,1);
            SE = ringpixels(2,2);
            NE = ringpixels(1,2);
            SW = ringpixels(2,1);

            %% costing filter
            if strcmpi(angle,'NE')
               estimate = sum([NE,SW])/2;
               status.Type = 'NE_SW_average';
            elseif strcmpi(angle,'SE')
               estimate = sum([NW,SE])/2;
               status.Type = 'NW_SE_average';
            else
               Ring_Average = sum([NE,NW,SE,SW])/4;
               estimate = Ring_Average;
               status.Type = 'Ring_Average';
            end
            status.estimate = estimate;
        end
        function [nyquist_cored_centre_signal,status] = Nyquist_Coring(obj,centre_pixel,estimate,coring_level,maximum_signal)
            %%
            
            %It's a gain relationship! 
            %If full scale deflection the green imbalance is off by the coring_level
            %If it was less bright you need to scale down by the estimate
            %value fraction of the full scale. 
            
            weighted_coring_level = round((estimate / maximum_signal) * coring_level); 
            
            
            difference = estimate - centre_pixel;
            
            if abs(difference) < weighted_coring_level
                cored_difference = abs(difference);
            else
                cored_difference = weighted_coring_level;
            end
            if difference >= 0
                nyquist_cored_centre_signal = centre_pixel + cored_difference;
            else
                nyquist_cored_centre_signal = centre_pixel - cored_difference;
            end
            
            % Status
            status.centre_pixel = centre_pixel;
            status.weighted_coring_level = weighted_coring_level;
            status.difference = difference;
            status.cored_difference = cored_difference;
            status.coring_level = coring_level;
            status.nyquist_cored_centre_signal = nyquist_cored_centre_signal;
        end
        function [roughness,status] = Adaptive_roughness_measure(obj,ring_pixels,ceiling)
            %%
            NW = ring_pixels(1,1);
            SE = ring_pixels(2,2);
            NE = ring_pixels(1,2);
            SW = ring_pixels(2,1);
            
            ring_pixels = [NW, SE, NE, SW];
            roughness = max(ring_pixels) - min(ring_pixels);
            if roughness > ceiling
                roughness = ceiling;
            end
            
            status.max_ring_pixel =  max(ring_pixels);
            status.min_ring_pixel =  min(ring_pixels);
            status.delta = max(ring_pixels) - min(ring_pixels);
            status.ceiling = ceiling;
            status.roughness = roughness;
        end
        function [output,status] = Soft_Switch(obj,maximum_signal,roughness,angle,nyquist_cored_centre_pixel,centre_pixel)
            %%
            fader = roughness/ maximum_signal; 
            swing = nyquist_cored_centre_pixel - centre_pixel;
            if isnan(angle)
               output = centre_pixel + (fader * swing);
            else
               output = nyquist_cored_centre_pixel;
            end
            output = round(output);
            
            status.maximum_signal = maximum_signal;
            status.roughness = roughness;
            status.fader = fader;
            status.swing = swing;
            status.angle = angle;
            status.centre_pixel = centre_pixel;    
            status.nyquist_cored_centre_pixel = nyquist_cored_centre_pixel;
            status.output = output;
        end
    end
    methods %Loggging
        function Log_Gradient_Analysis(obj,status)
            %%
            disp('Gradient Analysis: ')
            disp('------------------ ')
            disp(['ortho_stripe: ',num2str(status.ortho_stripe)])
            disp(['ne_stripe: ',num2str(status.ne_stripe)])
            disp(['se_stripe: ',num2str(status.se_stripe)])
            if isnan(status.angle)
                disp('angle: NULL')
            else
                disp(['angle: ',status.angle])
            end
            disp(' ')            
        end
        function Log_Adaptive_Cositing(obj,status)
            %%
            disp('Adaptive Cositing: ')
            disp('------------------ ')
            disp(['Type: ',num2str(status.Type)])
            disp(['Estimate: ',num2str(status.estimate)])
            disp(' ')            
        end
        function Log_Nyquist_Coring(obj,status)
            %%
            disp('Nyquist Coring: ')
            disp('--------------- ')
            disp(['weighted_coring_level: ',num2str(status.weighted_coring_level)])
            disp(['difference: ',num2str(status.difference)])
            disp(['cored_difference: ',num2str(status.cored_difference)])
            disp(['coring_level: ',num2str(status.coring_level)])
            disp(['centre_pixel: ',num2str(status.centre_pixel)])
            disp(['nyquist_cored_centre_signal: ',num2str(status.nyquist_cored_centre_signal)]) 
            disp(' ') 
        end
        function Log_Adaptive_roughness_measure(obj,status)
            %%
            disp('Adaptive Roughness Measure: ')
            disp('--------------------------- ')
            disp(['max_ring_pixel: ',num2str(status.max_ring_pixel)])
            disp(['min_ring_pixel: ',num2str(status.min_ring_pixel)])
            disp(['delta: ',num2str(status.delta)])
            disp(['ceiling: ',num2str(status.ceiling)])
            disp(['roughness: ',num2str(status.roughness)])
            disp(' ') 
        end
        function Log_Soft_Switch(obj,status)
            %%
            disp('Soft Switch: ')
            disp('------------ ')
            disp(['maximum_signal: ',num2str(status.maximum_signal)])
            disp(['roughness: ',num2str(status.roughness)])
            disp(['fader: ',num2str(status.fader)])
            disp(['swing: ',num2str(status.swing)])
            disp(['angle: ',num2str(status.angle)])  
            disp(['centre_pixel: ',num2str(status.centre_pixel)])
            disp(['nyquist_cored_centre_pixel: ',num2str(status.nyquist_cored_centre_pixel)])
            disp(['output: ',num2str(status.output)])  
            disp(' ') 
        end
    end
end

    

    




