function YUV = rgb2yuv( imageIN )
   % Y = 0.3*Red + 0.6*Green + 0.1*Blue
   %%
   ConversionMatrix = [    0.299,    0.587,  0.114; ...
                        -0.14713, -0.28886,  0.436; ...
                           0.615, -0.51499, -0.10001];
   %%               
   YUV(:,:,1) = ConversionMatrix(1,1)*imageIN(:,:,1) + ConversionMatrix(1,2)*imageIN(:,:,2) + ConversionMatrix(1,3)*imageIN(:,:,3);
   YUV(:,:,2) = ConversionMatrix(2,1)*imageIN(:,:,1) - ConversionMatrix(2,2)*imageIN(:,:,2) - ConversionMatrix(2,3)*imageIN(:,:,3);
   YUV(:,:,3) = ConversionMatrix(3,1)*imageIN(:,:,1) - ConversionMatrix(3,2)*imageIN(:,:,2) - ConversionMatrix(3,3)*imageIN(:,:,3);
end