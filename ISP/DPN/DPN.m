classdef DPN < handle
    properties
        high_threshold
        low_threshold
        InputPixel = [20, 30, 31, 200]
        LocusA = [0.3, 0.5]
        LocusB = [0.5, 0.3]
    end
    properties
        DPNWB_ZONE_SIZE_HOR
        DPNWB_SATUR_THRESH
        DPNWB_DARKBITS_THRESH
        DPNWB_RED_LOCUS
        DPNWB_BLUE_LOCUS
        DPNWB_COS
        DPNWB_SIN
        DPNWB_LOCUS_LENGTH
        DPNWB_CLIPNEAR
        DPNWB_CLIPFAR
        DPNWB_MINWEIGHT
        DPNWB_RED_ENERGY
        DPNWB_GREEN1_ENERGY
        DPNWB_GREEN2_ENERGY
        DPNWB_BLUE_ENERGY
        DPNWB_TOTAL_PIXELS
        DPNWB_DFV
    end
    methods
        function GetDistanceFromLocus(obj,CH1,CH2,CH3,CH4)
            %%
            % returns the Distance of the macropixel (4 channels) it is passed from the user defined
            % plausibility locus
            Norm = obj.PixelVal2RBNorm(InputPixel)
        end
        function weight = CalcWeightFromDistance(obj,Distance)
            %%
            % returns the weight
            % applied for an input distance value (this in essence is defined by a transfer curve defined by
            % the user).
            Distance = 5
            clipNear =  0.4 %This defines simply the distance value which clips off the maximum threshold.
                            %All distances below this value receive a weighting of 1.0
            clipFar =   1.0 %This defines the distance value which ends the user defined transform. Any
                            %distance between clipnear and clipfar recieves a weighting calculated by linearly
                            %interpolating between clipnear/far and a weighting of 1.0->0.
            minweight = 0.1 %This defines a low threshold for output weighting. If the returned weight is
                            %less than minweight, the actual weighting applied is set to minweight.
        end
        function Norm = PixelVal2RBNorm(obj,InputPixel)
             %%
             r = InputPixel(1);
             gr = InputPixel(2);
             gb = InputPixel(3);
             b = InputPixel(4);
             gavg = mean([gr,gb]);
             
             R = r/(r + gavg + b);
             B = b/(r + gavg + b);
             
             Norm(1) = R;
             Norm(2) = B;
        end
    end
end