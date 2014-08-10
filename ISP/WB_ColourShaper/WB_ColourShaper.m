classdef WB_ColourShaper < handle
    properties
    end
    methods
        function obj = Main()
            %%
            close all
            PixelVal = [10, 200, 246];
            CodeMaxValue = 255;
            WhiteBlanceGains = [1.3,1,1.8];

            PixelVal = PixelVal./CodeMaxValue;
            WB_PixelVal = PixelVal.*WhiteBlanceGains;
            

            WB_PixelVal_Clipped = obj.Clip(WB_PixelVal);
            
            % smart gain
            WB_PixelVal_ClippedMod = WB_PixelVal/max(WB_PixelVal)
            
            
            %
            obj.PlotPixelCompare(   PixelVal, ...
                                    WB_PixelVal, ...
                                    WB_PixelVal_Clipped, ...
                                    WB_PixelVal_ClippedMod);
                                
            obj.imagePlot(  WB_PixelVal_Clipped, ...
                            WB_PixelVal_ClippedMod, ...
                            'White Balance Ideal Colour')
                        
        end
        function PlotPixelCompare(obj,PixelVal,WB_PixelVal,WB_PixelVal_Clipped,WB_PixelVal_ClippedMod)
            %%
            obj.PlotPixelVal(PixelVal,0);
            obj.PlotPixelVal(WB_PixelVal,4);
            obj.PlotPixelVal(WB_PixelVal_Clipped,8);
            obj.PlotPixelVal(WB_PixelVal_ClippedMod,12);
            Size = 15;
            Labels(1:Size) = {''}
            Labels{2} = 'Pre-WB';
            Labels{6} = 'Post-WB';
            Labels{10} = 'Post-WB Clip';
            Labels{14} = 'Post-WB SmGain';
            set(gca,'XTick',[1:Size])
            set(gca,'XTickLabel',Labels)               
        end
        function PlotPixelVal(obj,PixelVal,Offset)
            %%         
            XDATA = [1+Offset:3+Offset];
            YDATA = zeros(1,3);
            
            Red = YDATA;
            Red(1) = PixelVal(1);
            H = bar(XDATA,Red);
            set(H,'FaceColor',[1,0,0])
            hold on

            % Green
            Green = YDATA;
            Green(2) = PixelVal(2);
            
            H = bar(XDATA,Green);
            set(H,'FaceColor',[0,1,0]);
            get(H)
            hold on
            

            % Blue
            Blue = YDATA;
            Blue(3) = PixelVal(3);
            
            H = bar(XDATA,Blue);
            set(H,'FaceColor',[0,0,1]);
            hold on
            ylim([0,1.5]);  
            
            set(gca,'XTickLabel',{'','Post-WB',''})
        end
        function WB_PixelVal = Clip(obj,WB_PixelVal)
            %%
            n = find( WB_PixelVal >1 );
            WB_PixelVal(n) = 1;
        end
        function imagePlot(obj,PixelVal1,PixelVal2,description)
            %%
            image(1:200,1:100,1) = PixelVal1(1);
            image(1:200,1:100,2) = PixelVal1(2);
            image(1:200,1:100,3) = PixelVal1(3);
            
            image(1:200,101:200,1) = PixelVal2(1);
            image(1:200,101:200,2) = PixelVal2(2);
            image(1:200,101:200,3) = PixelVal2(3);
            
            figure, imshow(image); title(description)
        end
    end
end%% Effect of clipping
