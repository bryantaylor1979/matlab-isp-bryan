classdef CentreCorrector < handle
    properties
    end
    methods
        function Main(obj)
            %%
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  50,   NaN,  48,  NaN; ...
                      53,   NaN,  200,   NaN,  48; ...
                      NaN,  50,   NaN,  50, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
            pixels = obj.corrector(pixels);
        end
        function pixels = corrector(obj,pixels)
            %%
            ring_pixels = obj.GetRingPixels(pixels);
            centre_pixel = obj.GetCentrePixel(pixels);
            iavge = obj.AverageComputation(ring_pixels);
            idif = obj.centerdiff(centre_pixel,iavge);
            pixel_out = obj.pixel_output_comp(idif,iavge);
            
            pixels(3,3) = pixel_out
        end
        function pixel_out = pixel_output_comp(obj,idif,iavge)
            %%
            mindifDiag = min([idif(1),idif(3)]);
            mindifHV = min([idif(2),idif(4)]);
            Diag = min([mindifDiag,mindifHV]);
            
            if Diag == mindifDiag
                if mindifDiag == idif(1)
                    pixel_out = iavge(1);
                elseif mindifDiag == idif(3)
                    pixel_out = iavge(3);
                end    
            elseif Diag == mindifHV
                if mindifHV == idif(2)
                    pixel_out = iavge(2);
                elseif mindifHV == idif(4)
                    pixel_out = iavge(4);
                end   
            end     
            pixel_out = int8(pixel_out);
        end
        function idif = centerdiff(obj,centre_pixel,iavge)
            %%
            idif(1) = abs ( centre_pixel - iavge(1) );
            idif(2) = abs ( centre_pixel - iavge(2) );
            idif(3) = abs ( centre_pixel - iavge(3) );
            idif(4) = abs ( centre_pixel - iavge(4) );           
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
        function iavge = AverageComputation(obj,ring_pixels)
            %%
            iavge(1) = (ring_pixels(1) + ring_pixels(5)) / 2;
            iavge(2) = (ring_pixels(2) + ring_pixels(6)) / 2;
            iavge(3) = (ring_pixels(3) + ring_pixels(7)) / 2;
            iavge(4) = (ring_pixels(4) + ring_pixels(8)) / 2;            
        end
    end
end
