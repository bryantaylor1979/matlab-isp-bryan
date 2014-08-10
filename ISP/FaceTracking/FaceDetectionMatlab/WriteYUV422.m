function WriteYUV422( Y, U, V, FileName, N, M )
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );

UV = U; 
UV(:,2:2:end) = V(:,2:2:end);

fid = fopen( FileName, 'wb' );
Y  = uint8( fwrite( fid, Y', 'uchar' )' );
UV = uint8( fwrite( fid, UV', 'uchar' )' );
fclose( fid );

return 