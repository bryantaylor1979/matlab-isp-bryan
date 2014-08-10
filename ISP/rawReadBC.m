classdef rawReadBC < handle
    properties
    end
    methods 
        function Example(obj)
            %%
            imageName = 'C:\images\demo kit\imx060_v1_m7878006f76353634_4032x3024_0.raw';
            data = obj.raw2matlab(imageName,8); %8 or 16
            imshow(data)
        end
        function data = raw2matlab(obj,imageName,mode)
            %%  mode = 8; % 8 or 16
            VDim = 2448;
            HDim = 3264;
            raw = obj.ReadRawData(imageName);
            raw = obj.HeaderRemoval(raw,'8001');
            stride = obj.StrideEstimator(raw,VDim)
            data = reshape(raw,stride,VDim)';
            data = obj.cropStride(data,HDim);
            if mode == 16
                data = obj.Unpack(data);
            else
                data = obj.RemoveLSBs(data);
            end
                       
        end
    end
    methods (Hidden = true)
        function raw = ReadRawData(obj,imageName)
            %%
            fid = fopen(imageName, 'rb' );
            raw=uint8(fread( fid, 'uint8'));            
        end
        function raw = HeaderRemoval(obj,raw,start)
            %%
            p = hex2dec(start);
            raw = raw(p:end);
        end
        function stride = StrideEstimator(obj,raw,VDim)
            stride = size(raw,1)/VDim;
        end
        function data = cropStride(obj,data,HDim)
            data = data(:,1:HDim*5/4);
        end
        function data = Unpack(obj,data)
            %% index of MSB's
            MSBdata = obj.RemoveLSBs(data);
            LSBdata = obj.RemoveMSBs(data);
            
            %% Expand LSB
            LSBimage = obj.ExpandLSB(LSBdata);
            data = obj.CombineLSB_MSB(MSBdata,LSBimage);
        end
        function image16 = CombineLSB_MSB(obj,MSBdata,LSBimage)
            MSBdata = double(MSBdata).*4;
            data2 = MSBdata + LSBimage;
            image16 = uint16(data2.*2^6);            
        end
        function LSBimage = ExpandLSB(obj,LSBdata)
            [x,y] = size(LSBdata);
            binary = dec2bin(LSBdata);
            Bit12_image = obj.GetPixelLSB(binary,x,y,[1:2]);
            Bit34_image = obj.GetPixelLSB(binary,x,y,[3:4]);
            Bit56_image = obj.GetPixelLSB(binary,x,y,[5:6]);
            Bit78_image = obj.GetPixelLSB(binary,x,y,[7:8]);
            
            %%
            LSBimage = zeros(x,y*4);
            LSBimage(:,1:4:y*4) = Bit12_image;
            LSBimage(:,2:4:y*4) = Bit34_image;
            LSBimage(:,3:4:y*4) = Bit56_image;
            LSBimage(:,4:4:y*4) = Bit78_image;           
        end
        function Bit12_image = GetPixelLSB(obj,binary,x,y,index)
            %%       
            Bit12 = binary(:,index);
            Bit12dec = bin2dec(Bit12);
            Bit12_image = reshape(Bit12dec,x,y);        
        end
        function data = RemoveMSBs(obj,data)
            data = data(:,[5:5:end]);
        end
        function data = RemoveLSBs(obj,data)
            %%
            END = size(data,2);
            All_index = [0:3];
            All_index = repmat(All_index,1,(END/5)); 
            %
            offsets = [1:(END/5)] - 1;   
            offset2 = repmat(offsets,4,1);
            offset3 = reshape(offset2,1,(END/5*4))*5;
            % combine
            index = All_index + offset3+1;
            data = data(:,index);            
        end
    end
end
