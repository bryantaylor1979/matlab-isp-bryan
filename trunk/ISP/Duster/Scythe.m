classdef Scythe < handle
    properties
        rank = 0;
        smoothctrl = 0;
    end
    properties (Hidden = true)
        handles
    end
    methods
        function obj = Scythe(varargin)
            %%
            rank = 0;
            smoothctrl = 0;
            pixels = [ 51,  NaN,  56, NaN,  52; ...
                       NaN, NaN, NaN, NaN, NaN; ... 
                       49,  NaN, 100, NaN,  50; ...
                       NaN, NaN, NaN, NaN, NaN; ...
                       48,  NaN,  55, NaN,  54 ]; 

            [corrected_pixels,status] = obj.corrector(pixels,rank,smoothctrl);
            obj.plotpixels(pixels,corrected_pixels);
            obj.plotRank(status.rankedpxiels,rank);
        end
        function [pixels,status] = corrector(obj,pixels,rank,smoothctrl)
            %%
            centerpixel = pixels(3,3);
            ringpixels = [  pixels(1,1), ...
                            pixels(1,3), ...
                            pixels(1,5), ...
                            pixels(3,5), ...
                            pixels(5,5), ...
                            pixels(5,3), ...
                            pixels(5,1), ...
                            pixels(3,1)];
            rankedpxiels = obj.batcher_banyan_sort(ringpixels);
            correction_required = obj.IsCorrectionRequired(rankedpxiels,centerpixel);
            estimate1 = obj.estimate_pixel(rankedpxiels,correction_required,rank);
            estimate2 = obj.estimate_pixel(rankedpxiels,correction_required,rank+1);
            val = obj.softswitch(estimate1,estimate2,smoothctrl); 
            pixels(3,3) = val;
            
            %
            status.rankedpxiels = rankedpxiels;
        end
        function rankedpxiels = batcher_banyan_sort(obj,ringpixels)
            rankedpxiels = sort(ringpixels,'descend');
        end
        function logic = IsCorrectionRequired(obj,rankedpxiels,centerpixel)
            %% correction required
            if centerpixel > rankedpxiels(1)
                logic = 'HIGH';
            elseif centerpixel < rankedpxiels(8)
                logic = 'LOW';          
            else
                logic = 'NULL';
            end               
        end
        function pixel = estimate_pixel(obj,rankedpxiels,correction_required,rank)
            %%
            if strcmpi(correction_required,'HIGH');
                pixel = obj.GetHighRankedPixel(rankedpxiels,rank);
            elseif strcmpi(correction_required,'LOW');
                pixel = obj.GetLowRankedPixel(rankedpxiels,rank);
            else
                error('')
            end
        end
        function val = softswitch(obj,estimate1,estimate2,smoothctrl)
            %%
            val = estimate1 - (estimate1 - estimate2)*smoothctrl;
        end
        function pixel = GetHighRankedPixel(obj,rankedpxiels,rank)
            %%
            pixel = rankedpxiels(1+rank);
        end
        function pixel = GetLowRankedPixel(obj,rankedpxiels,rank)
            %%
            pixel = rankedpxiels(8-rank);
        end
    end
    methods % visulaisations
        function plotpixels(obj,pixels,corrected_pixels)
            corrected_color = [0.3,0.7,0.3];
            cor_FaceAlpha = 1;
            uncorrected_color = [1,1,1];
            uncor_FaceAlpha = 0.6;
            cor_LineStyle = '-';
            uncor_LineStyle = '--';
            %%
            h = obj.legends(corrected_color,uncorrected_color,cor_LineStyle,uncor_LineStyle);
            hold on
            obj.plotPixels(pixels,uncorrected_color,0.49,uncor_FaceAlpha,uncor_LineStyle);
            hold on
            obj.plotPixels(corrected_pixels,corrected_color,0.5,cor_FaceAlpha,cor_LineStyle);
            daspect([1,1,20]);
            xlim([0,6]);
            ylim([0,6]);
            grid off
            grid on
            zlabel('Pixel Val')   ; 
            set(h,'Position', [0.7110, 0.8362, 0.2250, 0.1000])
            set(gca,'Position',[0.09,0.1,0.84,0.81])
        end
        function h = legends(obj,corrected_color,uncorrected_color,cor_LineStyle,ucor_LineStyle)
            %%
            h = bar3(1,0.1,'detached');
            set(h,'FaceColor',uncorrected_color,'Visible','off','LineStyle',ucor_LineStyle);
            hold on;
            h = bar3(1,0.1,'detached');
            set(h,'FaceColor',corrected_color,'Visible','off','LineStyle',cor_LineStyle);         
            h = legend('uncorrected','corrected');
        end
        function plotPixels(obj,pixels,colour,Width,FaceAlpha,LineStyle)
            %%
            h = bar3(pixels,Width,'detached');
            for i = 1:5
                set(h(i),'FaceColor',colour,'FaceAlpha',FaceAlpha,'LineStyle',LineStyle);
            end
        end   
        function plotRank(obj,rankedpxiels,rank)
            %%
            figure;
            rankedfiltered = rankedpxiels;
            rankedfiltered([rank+1,rank+2]) = 0;
            
            selectedpixels = rankedfiltered;
            n = find(not(selectedpixels == 0));
            selectedpixels = rankedpxiels;
            selectedpixels(n) = 0;
            
            
            h = bar(rankedfiltered,'r');
            set(h,'FaceColor',[0.7,0.3,0.3]);
            
            hold on
            h = bar(selectedpixels,'r');
            set(h,'FaceColor',[0.3,0.3,0.7]);
            
            xlabel('Rank');
            ylabel('Pixel Value');
            legend('Ranked Pixels','Selected Based on Rank');
            
            set(gca,'XTickLabel',{'H0','H1','H2','H3','L3','L2','L1','L0'});          
        end
    end
end       

