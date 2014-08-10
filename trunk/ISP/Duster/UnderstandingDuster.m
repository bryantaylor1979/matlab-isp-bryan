% RING and CENTER control the selection critieria of the single and couplet
% correction.

%% Ring_Wt44
% Range 0, 240
% Default = 64
% 0 is not correction
% Selective pixel correction
% U44? 
Ring_Wt44 = 64
Float_Ring_Wt44 = Ring_Wt44/64

%% Cent_wt14
% Range 0,16
% 16 - Remove defect pixel
% 0 - No correction.
% Default = 16, 8 on the next slide?
% U14
Cent_wt14 = 16
Float_Cent_wt14 = Cent_wt14/16

%% Arctic_scyt_wt14
% Range 0,63
% 63 - remove pixel defect
% 0 - No correction
% Default = 0 (Switched off)
% U6?
Arctic_scyt_wt14 = 63

%% Arctic_sigm_wt14
% Range 0,16
% Default = 16
% 16 - high filter effect
% 0 - Low filter effect
% U14?
Arctic_sigm_wt14 = 16

%% Arctic_guass_wt17
% Range 0,128
% Default = 128
% high effect 128
% low effect 0
% U17? 
Arctic_guass_wt17 = 128


%% Loose Green
LooseGreen = true % true or false

%%
SafeThrld = (ring_wt44 * FrameSigma + 8) >> 4;
Thx = Arctic_sigm_wt14*FrameSigma
gnr_Sigma = Arctic_guass_wt17*FrameSigma

%%
FrameSigma = (FrameSigma x 0.7071);

%% Th1, Th2, Th3 are guassian noice reduction Thresholds 
Th1 = (FrameSigma*gaus_wt17 + 64) >> 7;
Th2 = (2 x FrameSigma x gaus_wt17 + 64) >> 7;
Th3 = (3 x FrameSigma x gaus_wt17 + 64) >> 7;

%% Sigma Estimator
T0 = nle_histo0; T1 = nle_histo1; T2 = SigmaSamples;
S0 = FrameSigma - 2; S1 = *FrameSigma + 2; S2 = (*FrameSigma + 2) x 3;
ZeroSamples => give the number of differences between each pixels equal to 0.
N = (0.68 x SigmaSamples);
(N < ZeroSamples) => FrameSigma = 1;
(N<T0) => FrameSigma = S0 x (N - ZeroSamples) / (T0 - ZeroSamples);
(N<T1) => FrameSigma = (S1 - S0) x (N - T0) / (T1 - T0) + S0;
Otherwise => FrameSigma = (S2 - S1) x (N - T1) / (T2 - T1) + S1;


