classdef Grid_LensShading < handle
    properties (SetObservable = true)
        ClearVars = true
        Enable
        method
        imageIN
        imageOUT
        ls_tables
    end
    methods
        function RUN(obj)
            obj.imageOUT = obj.imageIN;
            
            if obj.Enable == true
                obj.imageOUT.image = [];
                [x,y,z] = size(obj.imageIN.image);

                %%
                exp_ls_tables = zeros(x,y,z); %pre-allocate memory
                exp_ls_tables(:,:,1) = imresize(obj.ls_tables(:,:,1),[x,y]);
                exp_ls_tables(:,:,2) = imresize(obj.ls_tables(:,:,2),[x,y]);
                exp_ls_tables(:,:,3) = imresize(obj.ls_tables(:,:,3),[x,y]);


                obj.imageOUT.image = zeros(x,y,z); %pre-allocate memory
                obj.imageOUT.image = double(obj.imageIN.image) .* exp_ls_tables;    
                clear exp_ls_tables
                if obj.ClearVars == true
                    obj.imageIN.image = [];
                end
            end
        end
    end
end