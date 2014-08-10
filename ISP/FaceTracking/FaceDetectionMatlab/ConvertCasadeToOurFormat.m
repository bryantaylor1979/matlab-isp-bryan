%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [NCas, NFlt, StrongTresh, Alphas, Flt] = ConvertCoacadeToOurFormat( FileName )

% FileName = 'cascade_22_newRange_120118.txt';
FileName = 'cascade_Orig.txt';

clear NCas NFlt Flt Alphas StrongTresh
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

% Save number of filters per cascade
fid = fopen( 'NFlt.txt', 'wb' );
for i = 1:length(NFlt)
    fprintf(fid,'%d, ',uint16(NFlt{i}));
end
fclose(fid);

% Save Alpha numbers
fid= fopen( 'Alphas.txt', 'wb' );
for i = 1:length(Alphas)
    for j = 1:length(Alphas{i})
        fprintf(fid,'%d, ',uint32(round(Alphas{i}(j)*2^18)));
    end
    for j = length(Alphas{i}): length(Alphas{length(Alphas)})-1
        fprintf(fid,'0, ');
    end
    fprintf(fid,'\n');
end
fclose(fid);

fid = fopen( 'StrongTresh.txt', 'wb' );
for i = 1:length(StrongTresh)
    fprintf(fid,'%d, ',uint32(round(StrongTresh{i}*2^18)));
end
fclose(fid);

% Save Flt numbers
fidFlt0 = fopen( 'Filter0.txt', 'wb' );
fidFlt1 = fopen( 'Filter1.txt', 'wb' );
fidFlt2 = fopen( 'Filter2.txt', 'wb' );
fidFlt3 = fopen( 'Filter3.txt', 'wb' );
fidFlt4 = fopen( 'Filter4.txt', 'wb' );
fidFlt5 = fopen( 'Filter5.txt', 'wb' );
fidFlt6 = fopen( 'Filter6.txt', 'wb' );
fidFlt7 = fopen( 'Filter7.txt', 'wb' );
fidFlt8 = fopen( 'Filter8.txt', 'wb' );
fidFlt9 = fopen( 'Filter9.txt', 'wb' );
fidWeakTresh = fopen( 'WeakTresh.txt', 'wb' );
fidWeakTreshSign = fopen( 'WeakTreshSign.txt', 'wb' );

for i = 1:length(Flt)
    for j = 1:length(Flt{i})
        
        if( Flt{i}{j}(2) == 0 )
            parityVal = 1;
        else
            parityVal = -1;
        end
        fprintf(fidFlt0,'%d, ', parityVal); 
        fprintf(fidFlt1,'%d, ', Flt{i}{j}(3)); 
        fprintf(fidFlt2,'%d, ', Flt{i}{j}(4)); 
        fprintf(fidFlt3,'%d, ', Flt{i}{j}(5)); 
        fprintf(fidFlt4,'%d, ', Flt{i}{j}(6)); 
        fprintf(fidFlt5,'%d, ', Flt{i}{j}(7)); 
        fprintf(fidFlt6,'%d, ', Flt{i}{j}(8)); 
        fprintf(fidFlt7,'%d, ', Flt{i}{j}(9)); 
        fprintf(fidFlt8,'%d, ', Flt{i}{j}(10)); 
        fprintf(fidFlt9,'%d, ', Flt{i}{j}(11)); 
                   
        weakSign = sign(Flt{i}{j}(1));
        weakSign(weakSign==0) = 1;
        weakTresh = round(weakSign*Flt{i}{j}(1)*Flt{i}{j}(1)*(2^8));
%        weakTresh = (weakSign*Flt{i}{j}(1)*Flt{i}{j}(1)*(2^8)); 
%        if(abs(weakTresh) < 1 && weakTresh ~= 0)
%            weakTresh = weakSign*1;
%        end
%        weakTresh = round(weakTresh);\        
        
       fprintf(fidWeakTresh,'%d, ', uint32(abs(weakTresh))); % Normalize the lerning process output to 24x24 window    
% %        fprintf(fidWeakTresh,'%d, ', uint32(floor(Flt{i}{j}(1)*Flt{i}{j}(1)*(2^8)*(25*25)/(24*24)))); % Normalize the lerning process output to 24x24 window    
    
        
% %         if( parityVal*sign(Flt{i}{j}(1)) == 1 )
% %             signVal = sign(floor(sign(Flt{i}{j}(1))*parityVal));
% %         else
% %             signVal = sign( ceil(sign(Flt{i}{j}(1))*parityVal));
% %         end
        
        signVal = sign( parityVal*sign(Flt{i}{j}(1)) );
        
        if(signVal == 0)
            signVal = parityVal;
        end
        
        fprintf(fidWeakTreshSign,'%d, ', signVal); 
         
% % %         if(sign(Flt{i}{j}(1)) < 0)
% % %             signVal = -1;
% % %         else
% % %             signVal = 1;
% % %         end
% % %         fprintf(fidWeakTreshSign,'%d, ', signVal); 
    end
    
    for j = length(Flt{i}): length(Flt{length(Flt)})-1
        fprintf(fidFlt0,'0, ');
        fprintf(fidFlt1,'0, ');
        fprintf(fidFlt2,'0, ');
        fprintf(fidFlt3,'0, ');
        fprintf(fidFlt4,'0, ');
        fprintf(fidFlt5,'0, ');
        fprintf(fidFlt6,'0, ');
        fprintf(fidFlt7,'0, ');
        fprintf(fidFlt8,'0, ');
        fprintf(fidFlt9,'0, ');
        fprintf(fidWeakTresh,'0, ');
        fprintf(fidWeakTreshSign,'0, ');
    end
    fprintf(fidFlt0,'\n');
    fprintf(fidFlt1,'\n');
    fprintf(fidFlt2,'\n');
    fprintf(fidFlt3,'\n');
    fprintf(fidFlt4,'\n');
    fprintf(fidFlt5,'\n');
    fprintf(fidFlt6,'\n');
    fprintf(fidFlt7,'\n');
    fprintf(fidFlt8,'\n');
    fprintf(fidWeakTresh,'\n');
    fprintf(fidWeakTreshSign,'\n');
end

fclose(fidFlt0);
fclose(fidFlt1);
fclose(fidFlt2);
fclose(fidFlt3);
fclose(fidFlt4);
fclose(fidFlt5);
fclose(fidFlt6);
fclose(fidFlt7);
fclose(fidFlt8);
fclose(fidFlt9);
fclose(fidWeakTresh);
fclose(fidWeakTreshSign);

return;