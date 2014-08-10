function  RGB = Yuv2Rgb( Y, U, V )
YUV = zeros( size(Y,1), size(Y,2), 3 );
YUV(:,:,1) = double( Y );
YUV(:,:,2) = double( U-128 );
YUV(:,:,3) = double( V-128 );
RGB = uint8( ycbcr_2_rgb( YUV ) );
RGB = reshape( RGB, [size(Y,1), size(Y,2), 3] );
return;
