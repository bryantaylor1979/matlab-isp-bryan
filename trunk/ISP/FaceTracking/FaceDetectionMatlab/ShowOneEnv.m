function ShowOneEnv()

[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'Cascade.txt' );

fid = fopen('D:\DF_STW\Zoran\STS3_105_070214\STS\Main\Sightic\FaceDetection\24x24_2', 'rt')
c = fscanf(fid, '%d');
fclose(fid);

ImgPrt = zeros(24);
k=1;
for i=1:24
   ImgPrt(i,:)=c(k:k+24-1);
   k=k+24;
end

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
figure, image(ImgPrt), colormap(Map)

% [pass, failCas] = ValidateFaceByVJ( ImgPrt, NCas, NFlt, StrongTresh, Alphas, Flt );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( FileName )

   fid = fopen( FileName );

   tline = fgetl( fid );
   NCas = str2num( tline );
   for n = 1:NCas,
      tline = fgetl( fid );
      if( isempty( tline ) ),
         tline = fgetl( fid );
      end
      NFlt{n} = str2num( tline );
      tline = fgetl( fid );
      StrongTresh{n} = str2num( tline );
      tline = fgetl( fid );
      Alphas{n} = str2num( tline );
      for k = 1:NFlt{n},
         tline = fgetl( fid );
         Flt{n}{k} = str2num( tline );
      end
   end
   
   fclose( fid );

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Pass, failCas] = ValidateFaceByVJ( ImgPrt, NCas, NFlt, StrongTresh, Alphas, Flt )

   Nvj = 25;
   Pass=0;
   MeanMin = 12348;
   MeanMax = 140065;
   SqMin = 591320;
   VarMin = 18.0123;
   paddedSize = 1/(Nvj*Nvj);
   NvjInc = size(ImgPrt,1);
   WinSize = NvjInc-Nvj+1;

   ImgPrt = [zeros(1,NvjInc); ImgPrt];
   ImgPrt = [zeros(NvjInc+1,1), ImgPrt];
   I  = cumsum( cumsum( ImgPrt' )' );
   II = cumsum( cumsum( (ImgPrt.^2)' )' );


   Pass = 1;
   I1 = I(Nvj,Nvj)+I(1,1)-I(Nvj,1)-I(1,Nvj);
   if( I1 < MeanMin | I1 > MeanMax ),
      Pass = 0;
      return;
   end

   I2 = II(Nvj,Nvj)+II(1,1)-II(Nvj,1)-II(1,Nvj);
   if( I2 < SqMin ),
      Pass = 0;
      return;
   end

   I1 = I1*paddedSize;
   I1 = I1*I1;
   I2 = I2*paddedSize;
   I3 = I2-I1;
   if(I3>0), I3 = sqrt(I3); else I3 = 1.0; end

   if( I3 < VarMin ),
      Pass = 0;
      return;
   end
   WinI = [I(1:end, :)];

   failCas = NCas;
   for n = NCas:-1:1,
      Val = 0;
      for k = 1:NFlt{n},
         x1 = Flt{n}{k}(4)+1;
         x2 = Flt{n}{k}(5)+1;
         x3 = Flt{n}{k}(6)+1;
         x4 = Flt{n}{k}(7)+1;
         y1 = Flt{n}{k}(8)+1;
         y2 = Flt{n}{k}(9)+1;
         y3 = Flt{n}{k}(10)+1;
         y4 = Flt{n}{k}(11)+1;

         switch( Flt{n}{k}(3) ), % Filter type
            case( 0 ),
               f1 = WinI(x1,y3) - WinI(x1,y1) + WinI(x3,y3) - WinI(x3,y1) + 2*(WinI(x2,y1) - WinI(x2,y3));
            case( 1 ),
               f1 = WinI(x3,y1) + WinI(x3,y3) - WinI(x1,y1) - WinI(x1,y3) + 2*(WinI(x1,y2) - WinI(x3,y2));
            case( 2 ),
               f1 = WinI(x1,y1) - WinI(x1,y3) + WinI(x4,y3) - WinI(x4,y1) + 3*(WinI(x2,y3) - WinI(x2,y1) + WinI(x3,y1) - WinI(x3,y3));
            case( 3 ),
               f1 = WinI(x1,y1) - WinI(x1,y4) + WinI(x3,y4) - WinI(x3,y1) + 3*(WinI(x3,y2) - WinI(x3,y3) + WinI(x1,y3) - WinI(x1,y2));
            case( 4 ),
               f1 = WinI(x1,y1) + WinI(x1,y3) + WinI(x3,y1) + WinI(x3,y3) - 2*(WinI(x2,y1) + WinI(x2,y3) + WinI(x1,y2) + WinI(x3,y2)) + 4*WinI(x2,y2);
         end

         if( Flt{n}{k}(2) ~=0 ), % Parity
            if( f1 < I3*Flt{n}{k}(1) ),   % Weak treshold
               Val = Val + Alphas{n}(k);
            end
         else
            if( f1 >= I3*Flt{n}{k}(1) ),
               Val = Val + Alphas{n}(k);
            end
         end
      end
      if( Val < StrongTresh{n} ),
         failCas = n;
         Pass = 0;
         break;
      end
   end
   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%