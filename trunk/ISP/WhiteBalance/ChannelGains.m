classdef ChannelGains < handle
    properties (SetObservable = true)
        RedGain
        GreenGain
        BlueGain
        PixelClip = []; %If empty pixel clip is automatic
    end
    methods (Hidden = true)
        function [image] = CG(obj,image)
            % Channel Gains
            Red = image(:,:,1).*obj.RedGain;
            Green = image(:,:,2).*obj.GreenGain;
            Blue = image(:,:,3).*obj.BlueGain;
            
            %Auto clip
            switch class(image)
                case 'uint8'
                    obj.PixelClip = 2^8 - 1;
                case 'uint16'
                    obj.PixelClip = 2^16 - 1;
                case 'double'
                    obj.PixelClip = 1;
                otherwise
                    error('image class not supported')
            end

            %Clip output
            Red( Red > obj.PixelClip ) = obj.PixelClip;
            Green( Green > obj.PixelClip ) = obj.PixelClip;
            Blue( Blue > obj.PixelClip ) = obj.PixelClip;

            image(:,:,1) = Red;
            image(:,:,2) = Green;
            image(:,:,3) = Blue;
        end
    end
end