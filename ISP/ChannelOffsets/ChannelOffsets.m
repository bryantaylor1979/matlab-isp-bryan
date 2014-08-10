classdef ChannelOffsets <   handle & ...
                            FeederObject
    properties (SetObservable = true)
        Enable = true;
        RedOffset = 64 %In 10bit space
        GreenOffset = 64 %In 10bit space
        BlueOffset = 64 %In 10bit space
        MIN
        imageIN
        imageOUT
        inputImageCLASS
    end
    methods
        function RUN(obj)
            obj.imageOUT = []; %Save Memory
            if obj.Enable == true
                obj.imageOUT = obj.imageIN;
                [obj.imageOUT.image] = obj.Process(obj.imageIN.image);
            else
                obj.imageOUT = obj.imageIN;
            end
        end
    end
    methods (Hidden = true)
        function obj = ChannelOffsets(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end   
            if not(isempty(obj.InputObject))
                obj.ClassType = 'image';
                obj.LinkObjects;
                obj.UpdateLink;
            end
        end
        function [image] = Process(obj,image)
            % Channel Gains
            obj.inputImageCLASS = class(image);
            switch class(image)
                case {'double','uint16'}
                    if obj.imageIN.fsd == 1023
                        RedOffset = obj.RedOffset;
                        GreenOffset = obj.GreenOffset;
                        BlueOffset = obj.BlueOffset;  
                    end
                otherwise
            end
            image(:,:,1) = image(:,:,1) - RedOffset;
            image(:,:,2) = image(:,:,2) - GreenOffset;
            image(:,:,3) = image(:,:,3) - BlueOffset;
            obj.MIN = min(min2(image));
        end
    end
end