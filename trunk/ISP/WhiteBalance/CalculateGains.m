function [RedGain,GreenGain,BlueGain] = CalculateGains(RedEnergy,GreenEnergy,BlueEnergy)
%% Calculate Desired Gains
Energies = [RedEnergy,GreenEnergy,BlueEnergy];
MaxVal = max(Energies);
RedGain = MaxVal/RedEnergy;
GreenGain = MaxVal/GreenEnergy;
BlueGain = MaxVal/BlueEnergy;
end