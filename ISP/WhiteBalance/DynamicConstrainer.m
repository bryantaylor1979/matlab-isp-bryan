%%
classdef DynamicConstrainer <       handle & ...
                                    StructureManagement
                                
    properties
        lutval
    end
    methods
        function Range_Lux2Compiled(obj)
            %%
            
            LuxRange = [5000, 6000];
            
            IntTime(1) = obj.Lux2IntegrationTime( LuxRange(1) );
            IntTime(2) = obj.Lux2IntegrationTime( LuxRange(2) );
            
            disp([num2str(LuxRange(1)),' Lux (',num2str(IntTime(1)),'us) to ',num2str(LuxRange(2)),' Lux (',num2str(IntTime(2)),'us)'])
            
        end
        function Range_Compiled2Lux(obj)
            %%
            IntTime = [6944, 8192];
            
            LuxRange(1) = obj.IntegrationTime2Lux( IntTime(1) );
            LuxRange(2) = obj.IntegrationTime2Lux( IntTime(2) );
            
            disp([num2str(LuxRange(1)),' Lux (',num2str(IntTime(1)),'us) to ',num2str(LuxRange(2)),' Lux (',num2str(IntTime(2)),'us)'])            
        end
        function LuxVsCompileInt(obj)
            %%
            Lux = [1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000];
            x = size(Lux,2);
            for i = 1:x
                IntTime(i) = obj.Lux2IntegrationTime(Lux(i))
            end
            plot(Lux, IntTime, 'r')
            xlabel('Lux')
            ylabel('Compiled Intergration (us)')            
        end
        function GetLux_interpolatedValue(obj,Val,Lux,CompiledIntergration)
            %%
            LineEq = polyfit(Lux,CompiledIntergration,1);
        end
        function IntTime = Lux2IntegrationTime(obj, Lux)
            %%
            Luxs = obj.GetField(obj.lutval,'Lux');
            CompiledIntergration = obj.GetField(obj.lutval,'CompiledIntergration');
            n = find(Luxs == Lux);
        end
        function Lux = IntegrationTime2Lux(obj, IntTime)
            %%
            Luxs = obj.GetField(obj.lutval,'Lux');
            CompiledIntergration = obj.GetField(obj.lutval,'CompiledIntergration');
            n = find(CompiledIntergration == IntTime);
            
            if isempty(n)
                n = find(CompiledIntergration > IntTime);
                Value(1)  = min(CompiledIntergration(n));
                
                m = find(CompiledIntergration < IntTime);
                Value(2)  = max(CompiledIntergration(m));
                
                LuxVal(1) = obj.IntegrationTime2Lux(Value(1));
                LuxVal(2) = obj.IntegrationTime2Lux(Value(2));
                
                eq = polyfit(Value,LuxVal,1);
                Lux = polyval(eq,IntTime);
            else
                Lux = Luxs(n);
            end
        end
    end
    methods
        function obj = DynamicConstrainer()
            %%
            obj.lutval = obj.LUT()
        end 
        function lut = LUT(obj)
            %%
            lut(1).Lux = 1500
            lut(1).CompiledIntergration = 24612.35893

            lut(2).Lux = 2000
            lut(2).CompiledIntergration = 18927.10421

            lut(3).Lux = 2500
            lut(3).CompiledIntergration = 15438.50815

            lut(4).Lux = 3000
            lut(4).CompiledIntergration = 13071.12157

            lut(5).Lux = 3500
            lut(5).CompiledIntergration = 11355.08619

            lut(6).Lux = 4000
            lut(6).CompiledIntergration = 10051.79881

            lut(7).Lux = 4500
            lut(7).CompiledIntergration = 9026.960338

            lut(8).Lux = 5000
            lut(8).CompiledIntergration = 8199.076630

            lut(9).Lux = 5500
            lut(9).CompiledIntergration = 7515.769008

            lut(10).Lux = 6000
            lut(10).CompiledIntergration = 6941.805926            
        end
    end
end

