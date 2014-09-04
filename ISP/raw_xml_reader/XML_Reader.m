classdef XML_Reader < handle
    properties (SetObservable = true)
        filename = 'V:\imx175\images_rev3\Suwon_2012_10_28\imx175_Baffin-Photoshoot7_24.xml'
        IdealColorGains_Red
        IdealColorGains_Green = 1;
        IdealColorGains_Blue
        GreyPatchCoords_X
        GreyPatchCoords_Y
        GreyPatchCoords_Width
        GreyPatchCoords_Height
        AwbExp
    end
    properties (Hidden = true)
        struct_out
    end
    methods
        function Example(obj)
           %%
           close all
           clear classes
           obj = XML_Reader;
           ObjectInspector(obj)
           
           %%
           theStruct = parseXML(obj.filename);
           struct = obj.DecodeBranch(theStruct);
           struct_out = obj.FlattenStruct(struct);
        end
        function RUN(obj)
           theStruct = parseXML(obj.filename);
           struct = obj.DecodeBranch(theStruct);
           obj.struct_out = obj.FlattenStruct(struct);   
           obj.IdealColorGains_Red = obj.struct_out.IdealColorGain_Red;
           obj.IdealColorGains_Blue = obj.struct_out.IdealColorGain_Blue;
           obj.GreyPatchCoords_X = obj.struct_out.GreyPatchCoords_X;
           obj.GreyPatchCoords_Y = obj.struct_out.GreyPatchCoords_Y;
           obj.GreyPatchCoords_Width = obj.struct_out.GreyPatchCoords_Width;
           obj.GreyPatchCoords_Height = obj.struct_out.GreyPatchCoords_Height;
           obj.AwbExp = obj.struct_out.AwbExp;
        end
    end
    methods (Hidden = true)
        function obj = XML_Reader(varargin)
           x = size(varargin,2);
           for i = 1:2:x
               obj.(varargin{i}) = varargin{i+1};
           end
           
           theStruct = parseXML(obj.filename);
           struct = obj.DecodeBranch(theStruct);
           obj.struct_out = obj.FlattenStruct(struct);    
           obj.IdealColorGains_Red = obj.struct_out.IdealColorGain_Red;
           obj.IdealColorGains_Blue = obj.struct_out.IdealColorGain_Blue;
           obj.GreyPatchCoords_X = obj.struct_out.GreyPatchCoords_X;
           obj.GreyPatchCoords_Y = obj.struct_out.GreyPatchCoords_Y;
           obj.GreyPatchCoords_Width = obj.struct_out.GreyPatchCoords_Width;
           obj.GreyPatchCoords_Height = obj.struct_out.GreyPatchCoords_Height;
           obj.AwbExp = obj.struct_out.AwbExp;
        end
        function struct_out = FlattenStruct(obj,struct)
            %%
            names = fieldnames(struct);
            x = size(names,1);
            for i = 1:x
               if isstruct(struct.(names{i}))
                   names2 = fieldnames(struct.(names{i}));
                   y = size(names2,1);
                   for j = 1:y
                       struct_out.([names{i},'_',names2{j}]) = struct.(names{i}).(names2{j});
                   end
               else
                   struct_out.(names{i}) = struct.(names{i});
               end
            end
        end
        function struct = DecodeBranch(obj,theStruct)
            %%
            x = size(theStruct.Children,2);
            for i = 2:2:x 
                Name = theStruct.Children(i).Name;
                disp(['Name: ',Name])
                if not(isempty(theStruct.Children(i).Children))
                    if max(size(theStruct.Children(i).Children)) == 1
                        Data = theStruct.Children(i).Children.Data;
                    else
                        Data = obj.DecodeLeaf(theStruct.Children(i).Children);
                    end
                else
                    Data = theStruct.Children(i).Data; 
                end
                try
                NumData = str2num(Data);
                catch
                NumData = [];    
                end
                if isempty(NumData)
                    struct.(Name) = Data;
                else
                    struct.(Name) = NumData;
                end
            end
        end
        function struct_out = DecodeLeaf(obj,struct)
            x = size(struct,2);
            for i = 2:2:x 
                %%
                Name = struct(i).Name;
                Data = struct(i).Children.Data;
                struct_out.(Name) = str2num(Data);
            end
        end
    end
end





