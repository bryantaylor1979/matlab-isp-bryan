function BuildSet()


Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
NCas = round(20+rand()*10);

NFlt = {7, 15 ,30 ,30 ,50 ,50 ,50 ,100 ,120 ,140,160 ,180 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200 ,200};

for n=1:NCas
   for k=1:NFlt{n}
      type = round(rand()*4);
      switch(type)
         case 0
            startPnt = round(rand()*22)+1;
            diff = round(rand()*(24-startPnt)/2);
            Flt{n}{k} = [1,1,0,startPnt,startPnt+diff,startPnt+2*diff,-1,1,1,1,1];
         case 1
            startPnt = round(rand()*23)+1;
            diff = round(rand()*(24-startPnt));
            Flt{n}{k} = [1,1,1,startPnt,-1,startPnt+diff,-1,1,1,1,1];
         case 2
            startPnt = round(rand()*21)+1;
            diff = round(rand()*(24-startPnt)/3);
            Flt{n}{k} = [1,1,2,startPnt,startPnt+diff,startPnt+2*diff,-1,1,1,1,1];
         case 3
            startPnt = round(rand()*23)+1;
            diff = round(rand()*(24-startPnt));
            Flt{n}{k} = [1,1,3,startPnt,-1,startPnt+diff,-1,1,1,1,1];
         case 4
            startPnt = round(rand()*22)+1;
            diff = round(rand()*(24-startPnt)/2);
            Flt{n}{k} = [1,1,4,startPnt,startPnt+diff,startPnt+2*diff,-1,1,1,1,1];

      end
   end
end

    
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