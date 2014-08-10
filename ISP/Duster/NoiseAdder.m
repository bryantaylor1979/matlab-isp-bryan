classdef NoiseAdder <  handle
    properties
        gaussian = [] %0 to 1
        localvar = [] %0 to 1
        singlets = [] %0 to 1
        speckle = []  %0 to 1
    end
    methods
        function [image_in] = RUN(obj,image_in)
            %%
            if not(isempty(obj.gaussian))
                image_in = imnoise( image_in, ...
                                    'gaussian', ...
                                    0, ...
                                    obj.gaussian);
            end
            if not(isempty(obj.localvar))
                image_in = imnoise( image_in, ...
                                    'localvar', ...
                                    [0,1], ...
                                    [obj.localvar,obj.localvar]); 
            end
            if not(isempty(obj.singlets))
                image_in = imnoise( image_in, ...
                                    'salt & pepper', ...
                                    obj.singlets);
            end
            if not(isempty(obj.speckle))
                image_in = imnoise( image_in, ...
                                    'speckle', ...
                                    obj.speckle);
            end
        end
    end
end

