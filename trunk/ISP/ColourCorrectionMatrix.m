classdef ColourCorrectionMatrix < handle % subclass hgsetget
    properties (SetObservable = true)
        ClearVars = [];
        Enable = true
        Reverse = false;
        imageIN
        imageOUT
        Matrix =  [ 2.55, -1.49, -0.06; ...
                   -0.58,  1.83, -0.25; ...
                    0.09, -0.75,  1.66];                                 
    end
    methods (Hidden=false)
        function RUN(obj)
             obj.imageOUT = obj.imageIN;
             if obj.Enable == true
                 obj.imageOUT.image = [];
                 input2 = obj.imageIN.image;
                 [height width depth] = size( input2 );

                 % Reshape 3-D array into a 2-D array to allow
                 % matrix multiplication
                 rsinput  = reshape( input2,  height*width,  depth ); 

                 % Apply colour correction matrix
                 % - note the ccm is transposed
                 if obj.Reverse == true
                 output = rsinput / obj.Matrix';    
                 else
                 output = rsinput * obj.Matrix';
                 end

                 % Reshape 2-D array back into a 3-D array
                 output = reshape( output, height, width, depth );

                 obj.imageOUT.image = output;
                 clearvars rsinput output
                 if obj.ClearVars == true
                    obj.imageIN.image = [];
                 end
             end  
        end
    end
    methods (Hidden=true)
        function [obj] = ColourCorrectionMatrix(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
    end
end