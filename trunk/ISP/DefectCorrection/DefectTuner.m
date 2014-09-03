classdef DefectTuner <  handle & ...
                        SigmaEstimation
    properties
    end
    methods
        function Main(obj)
            %%
            close all
            
            %% Read image
            I = imread('3_D65_Rubik_Corrected.pgm');
            imshow(I)

            %% channel split
            objBS = BayerSplit;
            BayerOrder = 1
            image4CH = objBS.RUN(I,BayerOrder);

            %% Red
            RingWt = 2;
            Channel = 1;
            obj.plotChannel(image4CH,Channel,RingWt,'r');   
            
            %% GreenR
            RingWt = 2;
            Channel = 2;
            obj.plotChannel(image4CH,Channel,RingWt,'g');  
            
            %% Blue
            RingWt = 2;
            Channel = 4;
            obj.plotChannel(image4CH,Channel,RingWt,'b');  
        end
        function plotChannel(obj,image4CH,Channel,RingWt,marker)
            Edge = obj.EdgeFilter(image4CH(:,:,Channel));
            figure;imshow(Edge);title('Edge Image');

            %%
            
            Sigma = obj.NoiseEstimation(Edge);
            SafeThreshold = Sigma*RingWt;
            obj.PlotGaussian(Edge,SafeThreshold,marker);

            %% Dection Image
            dection_image = obj.DetectionImage(Edge,SafeThreshold);
            figure, imshow(dection_image);                
        end
        function PlotGaussian(obj,Edge,SafeThreshold,marker)
            %%
            data = obj.plotHist(Edge,marker);
            hold on
            plot([SafeThreshold,SafeThreshold],[0,max(data)],'b:');
            plot([-SafeThreshold,-SafeThreshold],[0,max(data)],'b:');
        end
        function dection_image = DetectionImage(obj,imagein,SafeThreshold)
            %%
            n = find(imagein>SafeThreshold);
            [x,y] = size(imagein);
            dection_image = zeros(x,y);
            dection_image(n) = 1;           
        end
    end
end



