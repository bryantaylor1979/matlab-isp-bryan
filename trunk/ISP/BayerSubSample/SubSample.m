classdef SubSample < handle
    properties (SetObservable = true)
        imageIN
        imageOUT
        Enable = true;
        factor = 2;
    end
    methods
        function RUN(obj)
           %%
           obj.imageOUT = [];
           [x,y] = size(obj.imageIN.image);
           CLASS = class(obj.imageIN.image);
           factor = obj.factor;
           obj.imageOUT.image = feval(CLASS,(zeros(x/factor,y/factor)));
           
           
           if obj.Enable == true
                obj.imageOUT.image(1:2:end,  1:2:end) = obj.imageIN.image(    1:factor*2:end, 1:factor*2:end); %GR
                obj.imageOUT.image(2:2:end,  2:2:end) = obj.imageIN.image(    2:factor*2:end, 2:factor*2:end); %GB
                obj.imageOUT.image(2:2:end,  1:2:end) = obj.imageIN.image(    2:factor*2:end, 1:factor*2:end); %Reds
                obj.imageOUT.image(1:2:end,  2:2:end) = obj.imageIN.image(    1:factor*2:end, 2:factor*2:end); %Blue
                
           else
                obj.imageOUT.image = obj.imageIN.image;

           end
           obj.imageOUT.class = obj.imageIN.class;
           obj.imageOUT.type = obj.imageIN.type;
           obj.imageOUT.fsd = obj.imageIN.fsd ;
        end
    end
    methods (Hidden = true)
    end
end