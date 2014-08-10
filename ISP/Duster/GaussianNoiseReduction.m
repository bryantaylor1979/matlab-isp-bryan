classdef GaussianNoiseReduction < handle
    properties
    end
    methods
        function Main(obj)
            %%
            I = imread('cameraman.tif');
            imshow(I)
            
            %%
            FrameSigma = 10
            gaus_wt17 = 64
            
            %%
            Th1 = (FrameSigma * gaus_wt17 + 64) / 2^7
            Th2 = (2 * FrameSigma * gaus_wt17 + 64) / 2^7
            Th3 = (3 * FrameSigma * gaus_wt17 + 64) / 2^7
            %%
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  50,   NaN,  48,  NaN; ...
                      53,   NaN,  50,   NaN,  48; ...
                      NaN,  50,   NaN,  200, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
                  
            ring_pixels = obj.GetRingPixels(pixels)      
            centre_pixel = obj.GetCentrePixel(pixels)
            dg = obj.DiffFromCenter(ring_pixels,centre_pixel)
            Coeff_Px = obj.Diff2PixelWt(dg,Th1,Th2,Th3)
            pixel_out = obj.PixelComputation(ring_pixels,centre_pixel,Coeff_Px)
            
            pixels(3,3) = pixel_out;
        end
        function pixel_out = PixelComputation(obj,ring_pixels,centre_pixel,Coeff_Px)
            %%
            for i = 1:8
                pixelRingEnergy(i) = Coeff_Px(i)*ring_pixels(i)
            end
            pixelRingEnergy(9) = Coeff_Px(9)*centre_pixel 
            pixel_out = sum(pixelRingEnergy)
        end
        function Coeff_Px = Diff2PixelWt(obj,dg,Th1,Th2,Th3)
            %%
            for i = 1:8
                if dg(i) < Th1
                    Coeff_Px(i) = 8;
                elseif dg(i) < Th2
                    Coeff_Px(i) = 4;
                elseif dg(i) < Th3
                    Coeff_Px(i) = 2;  
                elseif dg(i) >= Th3
                    Coeff_Px(i) = 0;
                else
                    error('')
                end
            end
            Coeff_Px(9) = 8; %Center weight in middle is 1.
            Coeff_Px = Coeff_Px/sum(Coeff_Px);
        end
        function dg = DiffFromCenter(ring_pixels,centre_pixel)
            %%
            for i = 1:8
                dg(i) = abs(centre_pixel - ring_pixels(i));
            end
        end
        function Research(obj)
            %% Gaussian
            HSIZE = 7 %7x7 mask
            SIGMA = 1; %Width of the point spread function. 
            figure
            PSF = fspecial('gaussian',HSIZE,SIGMA);
            surf(PSF)
            sum(sum(PSF)) %Should sum to give 1. i.e this mask is a weighted average.
            figure
            Blurred = imfilter(I,PSF,'symmetric','conv');
            imshow(Blurred)
        end
        function ring_pixels = GetRingPixels(obj,pixels)
            %%
            ring_pixels(1) = pixels(2,2); %P0
            ring_pixels(2) = pixels(3,1); %P1
            ring_pixels(3) = pixels(4,2); %P2
            ring_pixels(4) = pixels(5,3); %P3
            ring_pixels(5) = pixels(4,4); %P4
            ring_pixels(6) = pixels(3,5); %P5
            ring_pixels(7) = pixels(2,4); %P6
            ring_pixels(8) = pixels(1,3); %P7           
        end
        function centre_pixel = GetCentrePixel(obj,pixels)
            centre_pixel = pixels(3,3); %P3
        end
    end
end