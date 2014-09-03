classdef extract_raw_Wrapper < handle
    properties (SetObservable = true)
        InstallDir = 'C:\sourcecode\matlab\Programs\ExtractRaws\';
        filename
        pathname
        dir = 'R:\AWB_variation\';
    end
    methods
        function Example(obj)
            
            %%
            close all 
            clear classes
            obj = extract_raw_Wrapper
            ObjectInspector(obj)
            
            %%
            [obj.filename, obj.pathname] = obj.GetFiles();
        end
        function RUN(obj)
            %%
            PWD = pwd;
            cd(obj.InstallDir);
            x = max(size(obj.filename));
            if not(iscell(obj.filename))
                x = 1;
            end
            for i = 1:x
                if not(iscell(obj.filename))
                    filename = fullfile(obj.pathname,obj.filename)
                else
                    filename = fullfile(obj.pathname,obj.filename{i})
                end
                string = ['extract_raw ',filename]
                dos(string);
            end   
            cd(PWD)
        end
    end
    methods (Hidden = true)
        function [filename, pathname] = GetFiles(obj)
            %%
            PWD = pwd;
            cd(obj.dir)
            [filename, pathname] = uigetfile( ...
                   {'*.jpg';'*.*'}, ...
                    'Pick a file', ...
                    'MultiSelect', 'on');
            cd(PWD)            
        end
    end
end