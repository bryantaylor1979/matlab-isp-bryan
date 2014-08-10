classdef TestPatterns   <   handle
    % Scale into double only.
    properties
        mode = 'greyscale' %greyscale or droop
        width  = 2016;
        height = 1512;
        droop_range = [-0.2,0.2]
    end
    properties
        image 
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = TestPatterns('mode','greyscale')
            imshow(obj.image)
            
            %%
            obj = TestPatterns('mode','droop')
            imshow(obj.image)
        end
    end
    methods      
        function image = GreyScale(obj,width,height)
            % create line
            Step = 1/(width-1);
            line = [0:Step:1];
            
            % create channel
            channel = repmat(line,height,1);
            
            % create image
            image(:,:,1) = channel;
            image(:,:,2) = channel;
            image(:,:,3) = channel;
        end
        function image = Droop(obj,width,height,range)
            % range is specified in percentage full scale deflection
            % 
            Step = (range(2) - range(1))/(height-1);
            Column = rot90([range(1):Step:range(2)]);
            Channel = repmat(Column,1,width);
            
            image(:,:,1) = Channel;
            image(:,:,2) = Channel;
            image(:,:,3) = Channel;
        end
        function obj = TestPatterns(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end

            switch lower(obj.mode)
                case 'greyscale'
                    image = obj.GreyScale(obj.width,obj.height); 
                case 'droop'
                    image = obj.Droop(obj.width,obj.height,obj.droop_range);  
                otherwise
                    error('test pattern not supported')
            end
            obj.image = image;
        end
    end
end