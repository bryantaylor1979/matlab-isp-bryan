%Hf - hieght of the face in meters
%Pv - resolution height in pixels
%Pf - face height in pixels
%Vfov - vertical field of view
%r - distance to face meters. 

%%
Hf = 0.45;    %45cms
Pv = 1536;    %3MP - 2048 x 1536
Pf = 1000;
Vfov = 57.55*2*pi/360;

%%
r = (Hf*Pv)/(Pf*Vfov)