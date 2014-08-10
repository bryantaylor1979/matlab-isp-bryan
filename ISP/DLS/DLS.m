classdef DLS < handle
    properties (SetObservable = true)
        Enable = true
        imageIN
        imageOUT
        DLS_OBJ
        LensShading_OBJ
    end
    methods
        function RUN(obj)
            %%
            obj.DLS_OBJ.imageIN = obj.imageIN;
            obj.DLS_OBJ.RUN();
            ls_tables = obj.DLS_OBJ.ls_tables;
            
            %% Downscale
            obj.LensShading_OBJ.ls_tables = ls_tables;
            obj.LensShading_OBJ.imageIN = obj.imageIN;
            obj.LensShading_OBJ.Enable = obj.Enable;
            obj.LensShading_OBJ.RUN();
            obj.imageOUT = obj.LensShading_OBJ.imageOUT;
        end 
    end
    methods (Hidden  = true)
        function obj = DLS()
            obj.DLS_OBJ = DLS_Calc;
            obj.LensShading_OBJ = Grid_LensShading;           
        end
    end
end