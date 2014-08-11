classdef SimplePipe <  handle
    % dls.m
    %
    % deform base to fit img.
    properties (SetObservable = true) %INPUTS
        rawfile = 'IMG_20130923_121257.raw';
        Mode
        BayerOrder = 2;
        BL = 2;
        DG = 1;
        ColourSaturation = 115;
        Enable_ChannelOffset = true;
        Enable_SubSample = true;
        Enable_LensShading = true;
        Enable_WhiteBalance = true;
        Enable_Clipper = true;
        Enable_CCM = true;
        Enable_Gamma = true;
        Enable_Saturation = true;
        Enable_Contrast = true;
        rawReader
        SubSample_OBJ
        Demosaic_OBJ
        ChannelOffsets_OBJ 
        DLS_OBJ
        WhiteBalance_OBJ
        Clipper_OBJ
        CCM_OBJ
        OutputEncoder_OBJ
        DATASET_MEM = dataset([]);
    end
    properties (SetObservable = true, Hidden = false)
        Mode_LUT
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            
            %%
            obj = SimplePipe();
            ObjectInspector(obj);       
        end
        function RUN(obj)
            %%
            obj.rawReader.imageOUT = []; 
            obj.SubSample_OBJ.imageOUT = [];
            obj.ChannelOffsets_OBJ.imageOUT = [];
            obj.Demosaic_OBJ.imageOUT = [];
            obj.WhiteBalance_OBJ.imageOUT = [];
            obj.DLS_OBJ.imageOUT = [];
            obj.CCM_OBJ.imageOUT = [];
            obj.OutputEncoder_OBJ.imageOUT = [];
            
            
            %%
            [StartMemStr,StartMem] = obj.GetMemoryUsed();
            
            % Get raw image. 
            obj.rawReader.filename = obj.rawfile;
            obj.rawReader.RUN();
            imageOUT = obj.rawReader.imageOUT;
            
            [rawMemStr,rawMem] = obj.GetMemoryUsed();
            
            % Sub Sample to save mem
            obj.SubSample_OBJ.imageIN = imageOUT;
            obj.SubSample_OBJ.Enable = obj.Enable_SubSample;
            obj.SubSample_OBJ.RUN();
            imageOUT = obj.SubSample_OBJ.imageOUT;
            
            [ssMemStr,ssMem] = obj.GetMemoryUsed();

            % NEW demosaic
            obj.Demosaic_OBJ.imageIN = imageOUT;
            obj.Demosaic_OBJ.BayerOrder = obj.BayerOrder;
            obj.Demosaic_OBJ.RUN();
            imageOUT = obj.Demosaic_OBJ.imageOUT;
            
            [dmMemStr,dmMem] = obj.GetMemoryUsed();
                       
            % remove black level
            obj.ChannelOffsets_OBJ.Enable = obj.Enable_ChannelOffset;
            obj.ChannelOffsets_OBJ.imageIN = imageOUT;
            obj.ChannelOffsets_OBJ.RedOffset = obj.BL;
            obj.ChannelOffsets_OBJ.GreenOffset = obj.BL;
            obj.ChannelOffsets_OBJ.BlueOffset = obj.BL;
            obj.ChannelOffsets_OBJ.RUN();
            imageOUT = obj.ChannelOffsets_OBJ.imageOUT;
            
            [blMemStr,blMem] = obj.GetMemoryUsed();

            %% DLS Calc
            obj.DLS_OBJ.imageIN = imageOUT;
            obj.DLS_OBJ.Enable = obj.Enable_LensShading;
            obj.DLS_OBJ.RUN();
            imageOUT = obj.DLS_OBJ.imageOUT;
            
            [ls_MemStr,ls_Mem] = obj.GetMemoryUsed(); 

            % Digital Gain
            imageOUT.image = double(imageOUT.image.*obj.DG);
            
            % White Balance
            obj.WhiteBalance_OBJ.imageIN = imageOUT;
            obj.WhiteBalance_OBJ.Enable = obj.Enable_WhiteBalance;
            obj.WhiteBalance_OBJ.RUN();
            imageOUT = obj.WhiteBalance_OBJ.imageOUT;
            [wb_MemStr,wb_Mem] = obj.GetMemoryUsed(); 
            
            % Clipper
            obj.Clipper_OBJ.imageIN = imageOUT;
            obj.Clipper_OBJ.Enable = obj.Enable_Clipper;
            obj.Clipper_OBJ.RUN();
            imageOUT = obj.Clipper_OBJ.imageOUT;
            
            % CCM
            obj.CCM_OBJ.imageIN = imageOUT;
            obj.CCM_OBJ.Enable = obj.Enable_CCM;
            obj.CCM_OBJ.RUN();
            imageOUT = obj.CCM_OBJ.imageOUT;
            [ccm_MemStr,ccm_Mem] = obj.GetMemoryUsed(); 
            
            % Output Encoder
            obj.OutputEncoder_OBJ.imageIN = imageOUT;
            obj.OutputEncoder_OBJ.Enable_Gamma = obj.Enable_Gamma;
            obj.OutputEncoder_OBJ.Enable_Saturation = obj.Enable_Saturation;
            obj.OutputEncoder_OBJ.Enable_Contrast = obj.Enable_Contrast;
            obj.OutputEncoder_OBJ.saturation = obj.ColourSaturation;
            obj.OutputEncoder_OBJ.RUN();
            [oe_MemStr,oe_Mem] = obj.GetMemoryUsed();
            
            blockNames = {  'start'; ...
                            'rawReader'; ...
                            'subsample'; ...
                            'channel offsets'; ...
                            'demosaic'; ...
                            'lenshading'; ...
                            'whitebalance'; ...
                            'colour matrix'; ...
                            'output encoder'};
                        
            totalMem =  {   StartMemStr; ...
                            rawMemStr; ...
                            ssMemStr; ...
                            blMemStr; ...
                            dmMemStr; ...
                            ls_MemStr; ...
                            wb_MemStr; ...
                            ccm_MemStr; ...
                            oe_MemStr};
                        
            diffMem =   [   0; ...
                            rawMem-StartMem; ...
                            ssMem-rawMem; ...
                            blMem-ssMem; ...
                            dmMem-blMem; ...
                            ls_Mem-dmMem; ...
                            wb_Mem-ls_Mem; ...
                            ccm_Mem-wb_Mem; ...
                            oe_Mem-ccm_Mem];
                        
            obj.DATASET_MEM = dataset(  {blockNames,    'Stage Memory'}, ...
                                        {totalMem,      'Total Memory'}, ...
                                        {diffMem,       'Diff Memory'} );  
            
        end
    end
    methods (Hidden = true)
        function obj = SimplePipe(varargin)
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.rawReader = rawReader('filename',obj.rawfile);  
            obj.Mode = obj.rawReader.Mode;
            obj.Mode_LUT = obj.rawReader.Mode_LUT;
            
            obj.SubSample_OBJ = SubSample;
            obj.ChannelOffsets_OBJ = ChannelOffsets;
            obj.Demosaic_OBJ = Demosaic;
            obj.DLS_OBJ = DLS;
            obj.WhiteBalance_OBJ = WhiteBalance;
            obj.Clipper_OBJ = Clipper;
            obj.CCM_OBJ = ColourCorrectionMatrix;
            obj.OutputEncoder_OBJ = OutputEncoder;
        end
        function [MemStr,Mem] = GetMemoryUsed(obj)
            [s] = memory;
            Mem = s.MemUsedMATLAB/1000000;
            MemStr = [num2str(Mem,3),' MB'];            
        end
    end
end