classdef xmlRead < handle
    properties (Hidden = false, SetObservable = true)
        path = 'N:\tuning\ov5693_HTC\images_rev1\HTC\131007_AWBtuning\cloudy\';
        imagename = 'ov5693_IMAG0277.xml';
        Name = 'Aperture';
        Value = NaN;
        Log = true;
        Error = 0;
    end
    properties (Hidden = true, SetObservable = true)
        imagename_Active = [];
        Name_LUT = {'Aperture'; ...
                    'Exposure'; ...
                    'IdealColorGain.Red'; ...
                    'LightSource'; ...
                    'IdealColorGain.Blue'; ...
                    'IdealColorGain_CTT.Red'; ...
                    'IdealColorGain_CTT.Blue'; ...
                    'GreyPatchCoords.X'; ...
                    'GreyPatchCoords.Y'; ...
                    'GreyPatchCoords.Width'; ...
                    'GreyPatchCoords.Height'; ...
                    'SensorSens.Red'; ...
                    'SensorSens.Green'; ...
                    'SensorSens.Blue'; ...
                    'LongDescription'; ...
                    'ShortDescription'; ...
                    'ColorTemp'; ...
                    'AwbExp'; ...
                    'Module'; ...
                    'Scene'};
        handles
    end
    methods
        function Example(obj)
            %%
            close all
            clear classes
            obj = ImageIO(  'Path', 'Z:\projects\IQ_tuning_data\bgentles\run\2014_Mar_25_10_23_58_89f78b5\', ...
                            'ImageType', '.xml');
            obj.RUN();
            ObjectInspector(obj)
            %%
            close all
            clear classes
            path = '//projects/IQ_tuning_data/sensors/Sony/imx214/140717_sinna_part2part/';
            imagename = 'imx214_Flat_D65_161.xml';
            obj = xmlRead(  'path',      path, ...
                            'imagename', imagename);
            ObjectInspector(obj);
            
            %%
            close all
            clear classes
            path = '//projects/IQ_tuning_data/sensors/Sony/imx175/Blackbody_curve_Images/';
            imagename = 'IMG_20140430_111733.xml';
            obj = xmlRead(  'path',      path, ...
                            'imagename', imagename);
            ObjectInspector(obj);
        end
        function RUN(obj)
            %%     
            tic
            if not(strcmpi(obj.imagename_Active,obj.imagename))
                obj.OpenXML();
            else
                disp('XML file already opened');
            end
            obj.ReadValue();
            obj.imagename_Active = obj.imagename;
            toc
        end
    end
    methods (Hidden = true)
        function obj = xmlRead(varargin)
            %%
            x = size(varargin,2);
            for i = 1:2:x
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        function OpenXML(obj)
            if obj.Log == true
                disp('Opening XML file for reading');
            end
            filename = fullfile(obj.path,obj.imagename);
            try
                obj.handles.xDoc = xmlread(filename);
                obj.Error = 0;
            catch
                disp('No XML file found')
                obj.Error = -1;
            end
        end
        function GetSingleItem(obj)
            allListitems = obj.handles.xDoc.getElementsByTagName(obj.Name);
            thisElement = allListitems.item(0);
            switch obj.Name
                case {'LongDescription','ShortDescription','LightSource','Module'}
                    try
                    Value = char(thisElement.getFirstChild.getData);
                    catch
                    Value = '';    
                    end
                case 'Scene'
                    Value = char(thisElement.getFirstChild.getData);
                otherwise
                    Value = str2num(thisElement.getFirstChild.getData);
            end
            obj.Value = Value;     
        end
        function ReadValue(obj)
            n = findstr(obj.Name,'.');
            if isempty(n)
                obj.GetSingleItem();
            else
                GroupName = obj.Name(1:n-1);
                ItemName = obj.Name(n+1:end);
                allListitems = obj.handles.xDoc.getElementsByTagName(GroupName);
                thisElement = allListitems.item(0);
                item = thisElement.getElementsByTagName(ItemName);
                thisElement = item.item(0);
                
                switch obj.Name
                    case {'LongDescription','ShortDescription','LightSource','Module'}
                        try
                        Value = char(thisElement.getFirstChild.getData);
                        catch
                        Value = '';    
                        end
                    case 'Scene'
                        Value = char(thisElement.getFirstChild.getData); 
                    otherwise
                        %%
                        Value = str2num(thisElement.getFirstChild.getData);
                        disp(['Reading: ',GroupName,'.',ItemName,': ',num2str(Value)])
                end
                obj.Value = Value; 
            end            
        end
    end
end