%% sigmaChar
classdef sigmaChar < handle
    properties
    end
    methods
        function Main(obj)
            %% 25 Lux
            % Q. How is the sigma calculated from the image? 
            close all
            Exposure = [5,5,5,5,5,5,10,10,10,10,10,10,50,50,50,50,50,50,100,100,100,100,100,100,150,150,150,150,150,150];
            Gain = [1,2,4,8,12,16,1,2,4,8,12,16,1,2,4,8,12,16,1,2,4,8,12,16,1,2,4,8,12,16];
            Sigma = [8,8,8,16,16,32,8,8,8,16,24,32,8,8,16,32,32,56,8,16,16,32,48,56,8,16,24,40,40,16];
            obj.Plot(Exposure,Gain,Sigma)
        end
        function Plot(obj,Exposure,Gain,Sigma)
            %%
            ExposureVals = [5,10,50,100,150];
            x = size(ExposureVals,2);
            figure;
            colours = 'rbgkm';
            markers = '.oxsd';
            for i = 1:x
                ExposureVal = ExposureVals(i);
                n = find(Exposure == ExposureVal);

                % Filter on expsosure val
                Gains = Gain(n);
                Sigmas = Sigma(n);
                hold on
                plot(Gains,Sigmas,['-',colours(i),markers(i)]);
                LegendsString{i} = ['int: ',num2str(ExposureVals(i)),' ms']
            end
            xlabel('Analogue Gain');
            ylabel('Sigma');
            title('Sigma vs gain on different light conditions');
            h = legend(LegendsString)
            set(h,'Location','NorthWest')
        end
    end
end