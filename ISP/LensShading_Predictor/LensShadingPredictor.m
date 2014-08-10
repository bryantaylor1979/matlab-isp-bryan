classdef LensShadingPredictor <     handle & ...
                                    ReadSettings
    properties
        Rev = 1
    end
    methods
        function Example(obj)
            %%
            close all
            clear all
            
            %
            obj = LensShadingPredictor
            root = 'C:\sourcecode\matlab\Programs\LensShading_Predictor\profiles\';
            modNum = [1,3,7,8,14,22];
            PartNum = modNum(1);
            
            NVM = obj.ReadNVM(root,PartNum);
            v = obj.ReadAverageTables(root,'High');
            Diff_LowCT = obj.ReadAverageTables(root,'Low');
            Diff_HighCT = obj.ReadAverageTables(root,'High');
            
            %
            figure, obj.PlotLensShading(Diff_LowCT,0,'lens_profile')
            title('Low CT Average Table')
            figure, obj.PlotLensShading(Diff_HighCT,0,'lens_profile')
            title('High CT Average Table')
            figure, obj.PlotLensShading(NVM,0,'lens_profile')
            title('NVM Lens Shading')
            
            %
            ALS_Tables = obj.Generate(NVM,Diff_LowCT,Diff_HighCT);
            figure, obj.PlotLensShading(ALS_Tables.LowCT,0,'lens_profile')
            title('Low CT Predicted')
            
            %
            figure, obj.PlotLensShading(ALS_Tables.HighCT,0,'lens_profile')
            title('High CT Predicted')
            
            %
            ALS_Tables.LowCT = obj.ConvertData(ALS_Tables.LowCT);
            ALS_Tables.HighCT = obj.ConvertData(ALS_Tables.HighCT);
            writeAdaptiveLensShading(obj,ALS_Tables,['mod',num2str(PartNum),'_AdpativeLensShading.txt'])
        end
        function ALS_Tables = Generate(obj,NVM,Diff_LowCT,Diff_HighCT)
            %%
            ALS_Tables.LowCT.r = NVM.r .* Diff_LowCT.r;
            ALS_Tables.LowCT.gr = NVM.gr .* Diff_LowCT.gr;
            ALS_Tables.LowCT.gb = NVM.gb .* Diff_LowCT.gb;
            ALS_Tables.LowCT.b = NVM.b .* Diff_LowCT.b;
            
            %%
            ALS_Tables.HighCT.r = NVM.r .* Diff_HighCT.r;
            ALS_Tables.HighCT.gr = NVM.gr .* Diff_HighCT.gr;
            ALS_Tables.HighCT.gb = NVM.gb .* Diff_HighCT.gb;
            ALS_Tables.HighCT.b = NVM.b .* Diff_HighCT.b;
        end
        function struct = ReadNVM(obj,root,modNum)
            %%
            filename = ['mod',num2str(modNum),'_factory.txt'];
            struct = obj.ReadLS_TablesPartialsID([root,filename],0);
            struct = obj.Gains2Float(struct);
        end
        function struct = ReadAverageTables(obj,root,CT)
            %%
            filename = ['difftable_',CT,'CT.txt'];
            struct = obj.ReadLS_TablesPartialsID([root,filename],0);    
            struct = obj.Gains2Float(struct);
        end
        function writeAdaptiveLensShading(obj,ALS_Tables,filename)
            %%
            fid = fopen(filename,'w');
            obj.writeTable(fid, ALS_Tables.LowCT.r,  'cv_r0');
            obj.writeTable(fid, ALS_Tables.LowCT.gr, 'cv_gr0');
            obj.writeTable(fid, ALS_Tables.LowCT.gb, 'cv_gb0');
            obj.writeTable(fid, ALS_Tables.LowCT.b,  'cv_b0');
            obj.writeTable(fid, ALS_Tables.HighCT.r,  'cv_r1');
            obj.writeTable(fid, ALS_Tables.HighCT.gr, 'cv_gr1');
            obj.writeTable(fid, ALS_Tables.HighCT.gb, 'cv_gb1');
            obj.writeTable(fid, ALS_Tables.HighCT.b,  'cv_b1');
            fclose(fid)
        end
        function PlotLensShading(obj,struct,Lum,MODE)
            %%  
            obj = LensShadingViewer(    ['r0'],struct(Lum+1).r, ...
                                        ['b0'],struct(Lum+1).b, ...
                                        ['gb0'],struct(Lum+1).gr, ...
                                        ['gr0'],struct(Lum+1).gb, ...
                                        'MODE',MODE); 
        end
    end
end