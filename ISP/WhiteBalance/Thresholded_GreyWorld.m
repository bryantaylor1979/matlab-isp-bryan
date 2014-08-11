classdef Thresholded_GreyWorld < handle
    properties (SetObservable = true)
        imageOUT = imageCLASS
        RI_OBJ
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = Thresholded_GreyWorld();
            obj.RUN();
            ObjectInspector(obj)  
        end
        function RUN(obj)
            %%
            obj.RI_OBJ.RUN();
            obj.imageOUT = obj.RI_OBJ.imageOUT;
        end
    end
    methods (Hidden = true)
        function obj = Thresholded_GreyWorld()
           obj.RI_OBJ = ReadImage2( 'imageName',    '/projects/IQ_tuning_data/bryant/run/2014_Jun_18_14_25_47_ideal_gains/001-Baffin-BRCM_20120203_040821_ps_wg.tiff');
        end
    end
end