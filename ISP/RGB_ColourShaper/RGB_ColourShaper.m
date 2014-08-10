classdef RGB_ColourShaper < handle
    % RGB colour space
    properties
    end
    methods
        function obj = Saturation_ColourShaper()
            %%
            close all
            clear classes
            obj = RGB_ColourShaper;
            
            %%
            PixelVal = [10, 100, 255];
            CodeMaxValue = 255;    
            saturation = 1.25;
            PixelVal = PixelVal./CodeMaxValue
            LuminanceFactor = 1.1;
            
            %% Normal
            mode = 'Normal'; % Normal or Smart
            PixelVal_out = obj.AddSmartSaturation(PixelVal,saturation,mode);
            obj.imagePlot(PixelVal,PixelVal_out,['Norm Sat: ',num2str(uint8(PixelVal_out*CodeMaxValue))]);
            
            %% Smart
            mode = 'Smart'; % Normal or Smart
            PixelVal_out = obj.AddSmartSaturation(PixelVal,saturation,mode);
            obj.imagePlot(PixelVal,PixelVal_out,['Smart Sat: ',num2str(uint8(PixelVal_out*CodeMaxValue))]);    
            
            %% what happens when luminance is clipped? this will cause a hue change.
            LumMode = 'Smart';  %Smart, NormalClipped, NormalUnclipped
            PixelVal_out = obj.AddLuminance(PixelVal,LuminanceFactor,LumMode)
            obj.imagePlot(PixelVal,PixelVal_out,['Luminance: ',num2str(uint8(PixelVal_out*CodeMaxValue))]);    

            
            %% 
            hue = HuePlot
            
            %%
            PixelVal = [255, 50, 100];
            CodeMaxValue = 255; 
            Hue = 174.65;
            PixelVal = PixelVal./CodeMaxValue
            Correction = obj.AddHue(Hue,PixelVal);
            hue.SetRGB(Correction)   
        end
        function PixelVal = AddLuminance(obj,PixelVal,LuminanceFactor,mode)
            % 0 is black
            % 1 is white
            % NormalUnclipped -Value can be beyond white (i.e >1)
            % NormalClipped   -The new value is worked out then clipped to 1
            % Smart           -The luminance is capped to ensure it does
            %                  not go above 1.
           
            if strcmpi(mode,'Smart')
                maxfactor = 1/max(PixelVal);
                LuminanceFactor = min(LuminanceFactor,maxfactor);
            elseif strcmpi(mode,'NormalUnclipped')
                PixelVal = PixelVal.*LuminanceFactor;
            elseif strcmpi(mode,'NormalClipped')
                PixelVal = PixelVal.*LuminanceFactor;
                n = find(PixelVal > 1)
                PixelVal(n) = 1;
            end
        end
        function PixelVal = AddSmartSaturation(obj,PixelVal,saturation,mode)
            %%
            log = true
            if log == true
               disp('INPUTS')
               disp('======')
               disp(['PixelVal: ',num2str(PixelVal)]) 
               disp(['saturation: ',num2str(saturation)]) 
               disp(['mode: ',mode]) 
               disp(' ')
            end
            
            PixelVal_Sorted = sort(PixelVal,'descend');
            a = PixelVal_Sorted(1); %Max
            b = PixelVal_Sorted(2); %Mid
            c = PixelVal_Sorted(3); %Min 
            
            % Saturation Factor Calc
            if strcmpi(mode,'Smart') 
                maxfactor = a /(a - c);
                factor = min(saturation,maxfactor);
            elseif strcmpi(mode,'Normal')
                maxfactor = 'N/A';
                factor = saturation;
            end
            if log == true
               disp('Sat Factor Calc')
               disp('===========')
               disp(['maxfactor: ',num2str(maxfactor)]) 
               disp(['saturation: ',num2str(saturation)]) 
               disp(['factor: ',num2str(factor)])  
               disp(' ')
            end 
            
            d = a - (a - b) * factor;
            e = a - (a - c) * factor;
            
            if log == true
               disp('Pixel Calc')
               disp('===========')
               disp(['d: ',num2str(d)]) 
               disp(['e: ',num2str(e)]) 
            end            
            
            %%
            MidLoc = find(b == PixelVal)
            PixelVal(MidLoc) = d;
            MinLoc = find(c == PixelVal);
            PixelVal(MinLoc) = e;        
            
            % Clip data
%             n = find(PixelVal<0);
%             PixelVal(n) = 0;
            
            if log == true
               disp(['PixelVal: ',num2str(PixelVal)]) 
            end
        end
        function StartVal = AddHue(obj,angle,Pixel_Value)
            %% Swapping channels
            [Zone,Factor] = obj.Angle2ZoneAndFactor(angle);
            
            %% Swap Start End
            switch Zone
                case {'r->y','y->g'} % No Swap 
                    SwapStart(1) = Pixel_Value(1);
                    SwapStart(2) = Pixel_Value(2);
                    SwapStart(3) = Pixel_Value(3);
                    SwapEnd(1) = Pixel_Value(2);
                    SwapEnd(2) = Pixel_Value(1);
                    SwapEnd(3) = Pixel_Value(3); 
                case {'g->c','c->b'} % Swapping 1 & 2
                    SwapStart(1) = Pixel_Value(2);
                    SwapStart(2) = Pixel_Value(1);
                    SwapStart(3) = Pixel_Value(3);
                    SwapEnd(1) = Pixel_Value(2);
                    SwapEnd(2) = Pixel_Value(3);
                    SwapEnd(3) = Pixel_Value(1);
                case {'b->m','m->r'} % Swapping 2 & 3
                    SwapStart(1) = Pixel_Value(2);
                    SwapStart(2) = Pixel_Value(3);
                    SwapStart(3) = Pixel_Value(1);  
                    SwapEnd(1) = Pixel_Value(1);
                    SwapEnd(2) = Pixel_Value(2);
                    SwapEnd(3) = Pixel_Value(3);                    
                otherwise
            end
            
            disp(['SwapStart:  [',num2str(SwapStart)])
            disp(['SwapEnd:  [',num2str(SwapEnd)])
            
            %% Start Val
            StartVal = SwapStart; 
            switch Zone
                case 'y->g'
                    StartVal(2) = SwapEnd(2);                                
                case 'c->b'           
                    StartVal(3) = SwapEnd(3);              
                case 'm->r'             
                    StartVal(1) = SwapEnd(1);                     
                otherwise
            end
            disp(['Start Pixel Value:  [',num2str(StartVal)])
            
            %% Cal Value
            switch Zone
                case 'r->y'
                    SwapIndex = 2;
                case 'y->g'
                    SwapIndex = 1;
                case 'g->c'
                    SwapIndex = 3;
                case 'c->b'
                    SwapIndex = 2;
                case 'b->m'
                    SwapIndex = 1;
                case 'm->r'
                    SwapIndex = 3;
                otherwise
            end
            Val1 = SwapStart(SwapIndex);
            Val2 = SwapEnd(SwapIndex);    
            StartVal(SwapIndex) = obj.CalPixValue(Val2,Val1,Factor);
            
            disp(['Corrected:  [',num2str(StartVal)])
        end
        function [Zone,Factor] = Angle2ZoneAndFactor(obj,angle)
            %%
            angle = rem(angle,360);
            if angle < 60
                Zone = 'r->y';
            elseif angle < 120
                Zone = 'y->g';
            elseif angle < 180
                Zone = 'g->c';
            elseif angle < 240
                Zone = 'c->b';
            elseif angle < 300
                Zone = 'b->m';
            elseif angle < 360
                Zone = 'm->r';
            end
            angleFromDatum = rem(angle,60);
            Factor = angleFromDatum/60;
        end
        function PixOut = CalPixValue(obj,Val1,Val2,factor)
            %%
            diff = Val2-Val1;
            PixOut = Val2 - diff*factor;          
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
end