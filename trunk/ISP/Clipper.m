classdef Clipper < handle
    properties (SetObservable = true)
        Enable = true
        imageIN
        imageOUT
    end
    methods
        function RUN(obj)
            if obj.Enable == true
                obj.imageOUT = obj.imageIN;
                input2 = obj.imageIN.image;
                input2( input2 > obj.imageIN.fsd ) = obj.imageIN.fsd;
                input2( input2 < 0.0 ) = 0.0;
                obj.imageOUT.image = input2;
            else
                obj.imageOUT = obj.imageIN;
            end
        end
    end
end