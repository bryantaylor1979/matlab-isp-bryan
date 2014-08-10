function [SubjectiveHandle] = WhiteBalanceSim(varargin);
%% Read image
currentdir = pwd;

% cd('C:\Documents and Settings\bryan taylor\Desktop\My Bayer Pictures');
% cd('C:\SourceSafe\Apps\Projects\Matlab\Toolboxes\ISP\725 Pipe');
cd(currentdir);
[name,path] = uigetfile('*.bmp','MultiSelect', 'on');

% Sort out the differences in inputs for different modes of operation
[IsSubjective,cwb,SubjectiveHandle] = parseinputs(varargin);

if iscell(name)
    [x] = size(name,2);
else
    x = 1;
end

if IsSubjective == 0
    for i = 1:x
        if iscell(name)
        Pipe(IsSubjective,path,name{i});
        else
        Pipe(IsSubjective,path,name);   
        end
    end
elseif IsSubjective == 1
    for i = 1:x
        if iscell(name)
        [SubjectiveHandle] = Pipe(IsSubjective,path,name{i},cwb,SubjectiveHandle);
        else
        [SubjectiveHandle] = Pipe(IsSubjective,path,name,cwb,SubjectiveHandle);   
        end
    end
end

cd(currentdir);


end

function [SubjectiveHandle] = Pipe(IsSubjective,path,name,cwb,SubjectiveHandle)

%% IQ Setttings
mode = 'auto'; %auto or man
ManRGB =  [1.83    1.04    1];
cwb.Enable = true;

if IsSubjective == 0
    cwb.LocusA = [0.253906, 0.429688];
    cwb.LocusB = [0.458496, 0.226807];
    cwb.MaximumDistanceFromLocus = 0.026;
    cwb.DynamicLocusGain = 0.20;
    cwb.HighThreshold = 11008;
    cwb.LowThreshold = 6000;
    %improvements
    % cwb.DynamicLocusGain = 0.15;
    cwb.MaximumDistanceFromLocus = 0.009;
    % cwb.LocusB = [0.435, 0.2368];
    
    DesiredIntergrationTime = 6000;
elseif IsSubjective == 1
    WBGainCeiling = cwb.WBGainCeiling;
%     Desired Integration time to be taken from results.xls file and if there is no
%     xls file then take it from a pop up GUI
    try
        [StructureOut] = xls2struct([path,'results.xls']);
%         Find the row associated with the name of the image
        AllNames = {StructureOut.Name};
        SizeAllNames = size(AllNames,2);
        for i = 1:SizeAllNames
            ComparisionValue(i) = strcmpi([AllNames{i},'.bmp'], name);
        end
        RowNumberForName = find(ComparisionValue);
        
        DesiredIntergrationTime = StructureOut(RowNumberForName).fpDesiredExposureTime_us;
    catch
        prompt = {'Enter Desired Integration Time:'};
        dlg_title = 'Entry Desired Integration Time';
        num_lines = 1;
        def = {'6000'};
        DesiredIntergrationTime = inputdlg(prompt,dlg_title,num_lines,def);
        DesiredIntergrationTime = str2double(DesiredIntergrationTime);
    end
end

%% Image Details
bayerimage = readimage([path,name]);

%% Demosaic
[image] = biDemosaic(bayerimage,3)*0.5;

%% Intialise Modules
AV = FourChAntiVignetting();
DynamicGain = Damper();
DynamicCWB = DynamicConstrainedWhiteBalance();
mWWb = MWWBStats();
CG = ChannelGains();
cwb = ConstrainedWhiteBalance();
OutEnc = OutputEncoder();
cmx = ColourMatrix();

%% ColourMatrix
cmx.matrix = [1.581, -0.212, -0.369; ...
             -0.643, 1.849, -0.206; ...
              0.013, -1.635, 2.622]; %2300K Matrix

cmx.matrix = [1.738, -0.491, -0.247; ...
             -0.508, 1.818, -0.310; ...
              0.047, -1.114, 2.067]; %3000K Matrix

cmx.matrix = [2.562, -1.473, -0.089; ...
             -0.509, 1.712, -0.203; ...
             -0.003, -0.721, 1.724]; %CoolWhite Matrix
     
cmx.matrix = [ 2.248   -1.048  -0.200; ...
              -0.319    1.849  -0.530; ...
               0.002   -0.595   1.593]; %DayLight Matrix


%% AV Parameters
AV.Device = 725;
AV.r2shift = 19;
AV.UnityOffset_R = 64;
AV.UnityOffset_GR = 64;
AV.UnityOffset_GB = 64;
AV.HOffset_B = 64;
AV.HOffset_R = 4;
AV.VOffset_R = -38;
AV.r2_coeff_R = 74;
AV.r4_coeff_R = -68;
AV.HOffset_GR = 40;
AV.VOffset_GR = -26;
AV.r2_coeff_GR = 42;
AV.r4_coeff_GR = -27;
AV.HOffset_GB = 12;
AV.VOffset_GB = -30;
AV.r2_coeff_GB = 45;
AV.r4_coeff_GB = -38;
AV.HOffset_B = 52;
AV.VOffset_B = -10;
AV.r2_coeff_B = 37;
AV.r4_coeff_B = -33;

%% Dynamic Constrained White Balance
DynamicGain.HighThreshold = 11008;
DynamicGain.LowThreshold = 6000;
DynamicGain.MaxVal = 1;
DynamicGain.MinimumGainOutput = 0.01;
DynamicCWB.Enable = true;
DynamicCWB.LocusA = [0.253906, 0.429688];
DynamicCWB.LocusB = [0.458496, 0.226807];

%% Constrained White Balance
cwb.Enable = true;
cwb.LocusA = [0.253906, 0.429688];
cwb.LocusB = [0.458496, 0.226807];
cwb.MaximumDistanceFromLocus = 0.09;
cwb.GainCeiling = 2.2;

%% MWWB
mWWb.SaturationThreshold = 255;
mWWb.BlueTilt = 1;
mWWb.Green1Tilt = 1;
mWWb.Green2Tilt = 1;
mWWb.RedTilt = 1;

%% Output Encoder
OutEnc.gamma = 2.2;
OutEnc.contrast = 115;
OutEnc.saturation = 120;

%% ChannelGains (The tilt is in here)
Tilt = [1.169922,1,1.960938];
CG.RedGain = Tilt(1);
CG.GreenGain = Tilt(2);
CG.BlueGain = Tilt(3);

%% Process
ActiveLocusGain = DynamicGain.Process(DesiredIntergrationTime);
DynamicLocusA = DynamicCWB.Process(ActiveLocusGain);
[image] = AV.Process(image);
[image] = CG.Process(image);    %Tilt Image
[RedEnergy,GreenEnergy,BlueEnergy] = mWWb.Process(image.*256);  %Wb Energies

%%
OrgLocusA = cwb.LocusA;
cwb.LocusA = DynamicLocusA;

[RedGain,GreenGain,BlueGain] = CalculateGains(RedEnergy,GreenEnergy,BlueEnergy)       %Calculate Corrective Gains
[ConstrainedGains] = cwb.Process([RedGain,GreenGain,BlueGain]);

if strcmpi(mode,'man')
    ClippedGain = ManRGB;
end

ConstrainedGains
CG.RedGain = ConstrainedGains(1);
CG.GreenGain = ConstrainedGains(1);
CG.BlueGain = ConstrainedGains(1);

[image] = CG.Process(image);
[image] = cmx.Process(image);
[image]= OutEnc.Process(image);

%% Load Constrainer Display module
pltCWB = PlotCWB();

%%
pltCWB.RedGain = RedGain;
pltCWB.BlueGain = BlueGain;
pltCWB.GreenGain = GreenGain;
pltCWB.ConstrainedGains = ConstrainedGains;
pltCWB.IsSubjective = IsSubjective;
pltCWB.DynamicLocusA = DynamicLocusA;
pltCWB.OrgLocusA = OrgLocusA;
pltCWB.LocusB = cwb.LocusB;
pltCWB.Plot();

DisplayImage(image,name);
end

function [IsSubjective,cwb,SubjectiveHandle] = parseinputs(varargin);
varargin = varargin{1};
if isempty(varargin)
    IsSubjective = 0;
    cwb = 'n/a';
    SubjectiveHandle = 'n/a';
else
    IsSubjective = 1;
    cwb = varargin{1};
    SubjectiveHandle = varargin{2};
end
end
