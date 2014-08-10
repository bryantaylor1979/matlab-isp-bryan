classdef SigmaEstimation <  handle
    properties
    end
    methods
        function Main(obj)
            %%
            close all
            I = imread('cameraman.tif');
            % I = checkerboard(8);
            figure;imshow(I);title('Original Image');

            %%
%             obj = BayerSplit;
%             [newimage] = obj.RUN(image,1);

            %%
%             close all
            Edge = obj.EdgeFilter(I);
            SigmaOrg = obj.NoiseEstimation(Edge);
            
            figure;imshow(Edge);title('Edge Image');
            obj.plotHist(Edge);
            
            %%
            coring = 0.03;
            widenControl = 2;
            WEIGHT = obj.WeightToEdges(I,coring,widenControl);
            figure, imshow(WEIGHT);title('Edge Rejection Image');
            
            %% Remove Edge Data
            Edge_out = obj.RemoveEdgesFromDiffData(WEIGHT,Edge);
            obj.plotHist(Edge_out);
            SigmaCor = obj.NoiseEstimation(Edge_out);
            
            disp('Sigma Estimation')
            disp('================')
            disp(['SigmaOrg: ',num2str(SigmaOrg)])
            disp(['SigmaCor: ',num2str(SigmaCor)])
            disp(' ')
            
        end 
        function Edge_out = RemoveEdgesFromDiffData(obj,WEIGHT,Edge)
            %%
            [x,y] = size(WEIGHT);
            WEIGHT_out = reshape(WEIGHT,x*y,1);
            n = find(WEIGHT == 1);
            Edge_out = reshape(Edge,x*y,1);
            Edge_out = Edge_out(n);            
        end
        function rHist = plotHist(obj,image,marker)
            %%
            NoOfBins = max(max(image))-min(min(image));
            [x,y] = size(image);
            data = reshape(image,x*y,1);
            [rHist,xdata] = hist(data,NoOfBins);
            x = max(size(rHist));
            figure;
            h = plot(xdata, rHist,marker);
            
            xlabel('Pixel Deviation')
            ylabel('Number of Pixels')
            title('Edge (Hopefully Noise) Histogram')            
        end
        function image_out = EdgeFilter(obj,image_in)
            %% 
            mask = [-1,1]; %Difference Mask
            image_out = imfilter(double(image_in),mask,'symmetric','conv');
        end
        function Sigma = NoiseEstimation(obj,image_in)
            %%
            [x,y] = size(image_in);
            data = reshape(image_in,x*y,1);
            Sigma = std(data);
        end
        function WEIGHT = WeightToEdges(obj,imagein,coring,widenControl)
            % The ringing in the restored image, J3, occurs along the areas of sharp 
            % intensity contrast in the image and along the image borders. This example 
            % shows how to reduce the ringing effect by specifying a weighting function. 
            % The algorithm weights each pixel according to the WEIGHT array while 
            % restoring the image and the PSF. In our example, we start by finding the 
            % "sharp" pixels using the edge function. By trial and error, we determine 
            % that a desirable threshold level is 0.3
            WEIGHT = edge(imagein,'sobel',coring);
            
            se = strel('disk',widenControl);
            WEIGHT = 1-double(imdilate(WEIGHT,se));
        end            
    end
end

