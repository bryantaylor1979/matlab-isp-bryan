%% Ring Corrector
classdef RingCorrector < handle
    properties
        log = true
    end
    methods
        function [] = Main(obj)
            %%
            safethreshold = 50;
            mode = 'duster'; %arctic and duster
            
            %% 1 defect in ring
            close all
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  50,   NaN,  48,  NaN; ...
                      53,   NaN,  50,   NaN,  48; ...
                      NaN,  50,   NaN,  200, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
            pixels = obj.corrector(pixels,safethreshold,mode);
              
            %% 2 defects in ring together (flaw that does not matter)
            close all
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  50,   NaN,  48,  NaN; ...
                      53,   NaN,  50,   NaN,  200; ...
                      NaN,  50,   NaN,  200, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
            pixels = obj.corrector(pixels,safethreshold,mode);
            
            %% 2 defects in ring not together
            close all
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  200,  NaN,  48,  NaN; ...
                      53,   NaN,  50,   NaN,  48; ...
                      NaN,  50,   NaN,  200, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
            pixels = obj.corrector(pixels,safethreshold,mode);
            
            %% NO defects in ring 
            close all
            pixels = [NaN,  NaN,  51,   NaN, NaN; ...
                      NaN,  50,  NaN,  48,  NaN; ...
                      53,   NaN,  50,   NaN,  48; ...
                      NaN,  50,   NaN,  50, NaN; ...
                      NaN,  NaN,  47,   NaN, NaN];
            pixels = obj.corrector(pixels,safethreshold,mode);
        end
        function ring_pixels = GetRingPixels(obj,pixels)
            %%
            ring_pixels(1) = pixels(2,2); %P0
            ring_pixels(2) = pixels(3,1); %P1
            ring_pixels(3) = pixels(4,2); %P2
            ring_pixels(4) = pixels(5,3); %P3
            ring_pixels(5) = pixels(4,4); %P4
            ring_pixels(6) = pixels(3,5); %P5
            ring_pixels(7) = pixels(2,4); %P6
            ring_pixels(8) = pixels(1,3); %P7           
        end
        function ring_pixels_diff = GetRingDiff(obj,ring_pixels)
            ring_pixels_diff(1) = abs(ring_pixels(8) - ring_pixels(1));
            ring_pixels_diff(2) = abs(ring_pixels(1) - ring_pixels(2));
            ring_pixels_diff(3) = abs(ring_pixels(2) - ring_pixels(3));
            ring_pixels_diff(4) = abs(ring_pixels(3) - ring_pixels(4));
            ring_pixels_diff(5) = abs(ring_pixels(4) - ring_pixels(5));
            ring_pixels_diff(6) = abs(ring_pixels(5) - ring_pixels(6));
            ring_pixels_diff(7) = abs(ring_pixels(6) - ring_pixels(7));
            ring_pixels_diff(8) = abs(ring_pixels(7) - ring_pixels(8));           
        end
        function [pixels] = corrector(obj,pixels,safethreshold,mode)

            %%
            ring_pixels = obj.GetRingPixels(pixels);
            ring_pixels_diff = obj.GetRingDiff(ring_pixels);
            Correction = obj.correction_Required(ring_pixels_diff,safethreshold,mode);
            pixels = obj.correct_ring(Correction,ring_pixels_diff,ring_pixels,pixels)
            
            %%
            obj.plot_ring_selection(ring_pixels_diff,safethreshold);
            handles = obj.plot_ring_values(ring_pixels,[0.3,0.7,0.3]);
            ring_pixels = obj.GetRingPixels(pixels);
            obj.plot_corrected_ring(handles,ring_pixels,[0.7,0.3,0.3])
            
        end
        function [Correction] = correction_Required(obj,ring_pixels_diff,safethreshold,mode)
            %% 
            if strcmpi(mode,'arctic')        
                d_i_counter = size(find(ring_pixels_diff<safethreshold),2);
            else %duster improvement
                % Improves the detection. Previously two defects in the
                % ring beside one another would have been corrected (this
                % should not be corrected as it's a triplet. 
                numberOfDefectsInRing = 0;
                con_flag = false;
                x = max(size(ring_pixels_diff));
                for i = 1:x
                    val = ring_pixels_diff(i);
                    if val > safethreshold
                        if con_flag == 0
                            con_flag = true;
                        else
                            numberOfDefectsInRing = numberOfDefectsInRing + 1;
                            con_flag = false;
                        end
                    else
                        if con_flag == true;
                            numberOfDefectsInRing = numberOfDefectsInRing + 1;
                        end
                    end
                end
                d_i_counter = 7 - numberOfDefectsInRing;
            end            
            
            disp(['d_i_counter: ',num2str(d_i_counter)])
            disp(['Number Of Defective Pixel in Ring: ',num2str(numberOfDefectsInRing)])
            
            if d_i_counter == 6
                Correction = 'TRUE';
            elseif d_i_counter == 7
                Correction = 'FALSE';
            else
                Correction = 'FALSE';
            end
            disp(['Correction Required: ',Correction])
        end
        function pixels = correct_ring(obj,Correction,ring_pixels_diff,ring_pixels,pixels)
            %%
            if strcmpi(Correction,'TRUE')
                loc = find(max(ring_pixels_diff)==ring_pixels_diff);
                correctedvalue = (ring_pixels(loc-1) + ring_pixels(loc+1))/2;
                switch loc - 1
                    case 0
                        pixels(2,2) = correctedvalue; %P0
                    case 1
                        pixels(3,1) = correctedvalue; %P1
                    case 2
                        pixels(4,2) = correctedvalue; %P2
                    case 3
                        pixels(5,3) = correctedvalue; %P3
                    case 4
                        pixels(4,4) = correctedvalue; %P4 
                    case 5
                        pixels(3,5) = correctedvalue; %P5 
                    case 6 
                        pixels(2,4) = correctedvalue; %P6 
                    case 7
                        pixels(1,3) = correctedvalue; %P7 
                end
            end
        end
    end
    methods %plots
        function handles = plot_ring_values(obj,ring_pixels,color)
            handles.figure = figure;
            handles.bar = bar(ring_pixels);
            set(gca,'XTickLabel',{'P0','P1','P2','P3','P4','P5','P6','P7'});
            set(handles.bar,'FaceColor',color);
            ylim([0,255]);
            title('Pixel Values in Ring');
            xlabel('Pixel Location');
            ylabel('Pixel Value');         
        end
        function plot_corrected_ring(obj,handles,ring_pixels,color)
            handles.figure
            hold on
            handles.bar2 = bar(ring_pixels);
            set(handles.bar2,'FaceColor',color,'BarWidth',0.5);
            legend({'uncorrected','corrected'});
        end
        function plot_ring_selection(obj,ring_pixels_diff,safethreshold)
            figure;
            h = bar(ring_pixels_diff);
            set(gca,'XTickLabel',{'d0n','d1n','d2n','d3n','d4n','d5n','d6n','d7n'});
            set(h,'FaceColor',[0.5,0.5,1]);
            ylim([0,255]);
            title('Pixel Diff in Ring');
            xlabel('Pixel Location');
            ylabel('Pixel Diff');
            hold on
            sf(1:10) = safethreshold;
            plot([0:1:9],sf,'r:');
            legend({'Diff','SafeThreshold'});
        end        
    end
end
