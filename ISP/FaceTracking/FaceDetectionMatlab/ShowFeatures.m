function [points, counterArr] = ShowFeatures()

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'Cascade.txt' );

% fig=ones(25*15);
% Row = {};
% for i=1:25
%    Row{i}=[];
% end
points=[];

for n=1:NCas
   i=1; j=1;
   for k=1:NFlt{n}
      feature=ones(24);
      x1 = Flt{n}{k}(4)+1;
      x2 = Flt{n}{k}(5)+1;
      x3 = Flt{n}{k}(6)+1;
      x4 = Flt{n}{k}(7)+1;
      y1 = Flt{n}{k}(8)+1;
      y2 = Flt{n}{k}(9)+1;
      y3 = Flt{n}{k}(10)+1;
      y4 = Flt{n}{k}(11)+1;

      switch (Flt{n}{k}(3))
         case 0
            feature(x1:x2-1,y1:y3-1)=0.5;
            feature(x2:x3-1,y1:y3-1)=0;
            points = [points; [x1,x2,x3,-1,n,k]];
            %            Row{x1}=[Row{x1}(1:end), [n,k]];
            %            Row{x3}=[Row{x3}(1:end), [n,k]];

         case 1
            feature(x1:x3-1,y1:y2-1)=0.5;
            feature(x1:x3-1,y2:y3-1)=0;
            points = [points; [x1,-1,x3,-1,n,k]];
            %             Row{x1}=[Row{x1}(1:end), [n,k]];
            %             Row{x3}=[Row{x3}(1:end), [n,k]];

         case 2
            feature(x1:x2-1,y1:y3-1)=0;
            feature(x2:x3-1,y1:y3-1)=0.5;
            feature(x3:x4-1,y1:y3-1)=0;
            points = [points; [x1,x2,x3,x4,n,k]];
            %             Row{x1}=[Row{x1}(1:end), [n,k]];
            %             Row{x2}=[Row{x2}(1:end), [n,k]];
            %             Row{x3}=[Row{x3}(1:end), [n,k]];
            %             Row{x4}=[Row{x4}(1:end), [n,k]];
         case 3
            feature(x1:x3-1,y1:y2-1)=0;
            feature(x1:x3-1,y2:y3-1)=0.5;
            feature(x1:x3-1,y3:y4-1)=0;
            points = [points; [x1,-1,x3,-1,n,k]];
            %             Row{x1}=[Row{x1}(1:end), [n,k]];
            %             Row{x3}=[Row{x3}(1:end), [n,k]];
         case 4
            feature(x1:x2-1,y1:y2-1)=0;
            feature(x1:x2-1,y2:y3-1)=0.5;
            feature(x2:x3-1,y1:y2-1)=0.5;
            feature(x2:x3-1,y2:y3-1)=0;
            points = [points; [x1,x2,x3,-1,n,k]];
            %             Row{x1}=[Row{x1}(1:end), [n,k]];
            %             Row{x2}=[Row{x2}(1:end), [n,k]];
      end
      fig(i:i+23,j:j+23)=feature;
      fig(i:i+24,j+24)=0.75;
      fig(i+24,j:j+24)=0.75;
      if(mod(k,15)==0)
         i=i+25;
         j=1;
      else
         j=j+25;
      end
   end
    figure, image(uint8(255*fig)), colormap(Map)
   fig=ones(25*15);
end
points = unique(points, 'rows');
tmpPoints = points(:,1:4);
tmpPoints = unique(tmpPoints,'rows');
noe = size(tmpPoints,1);
counterArr = zeros(noe,6);
counterArr(:,1:4) = tmpPoints;

x1=points(1,1);
x2=points(1,2);
x3=points(1,3);
x4=points(1,4);
n1=points(1,5);
k1=points(1,6);
index=1;
c=1;
counter(c) = 1;;
tmpCounter(index)=1;
tmpCascade(index)=1;

for i=2:size(points,1)
   y1=points(i,1);
   y2=points(i,2);
   y3=points(i,3);
   y4=points(i,4);
   n2=points(i,5);
   k2=points(i,6);
   if(x1==y1 && x2==y2 && x3==y3 && x4==y4 && n1==n2)
      counter = counter+1;
      tmpCounter(index)=counter;
      tmpCascade(index) = n1;
   elseif(x1==y1 && x2==y2 && x3==y3 && x4==y4 && n1~=n2 )
      tmpCounter(index) = counter;
      tmpCascade(index) = n1;
      x1=points(i,1);
      x2=points(i,2);
      x3=points(i,3);
      x4=points(i,4);
      n1=points(i,5);
      k1=points(i,6);
      index = index+1;
      counter = 1;
      tmpCounter(index)=1;
      tmpCascade(index)=n2;
   elseif(x1~=y1 || x2~=y2 || x3~=y3 || x4~=y4 )
      counterArr(c,5) = max(tmpCounter);
      counterArr(c,6) = tmpCascade(find(tmpCounter==max(tmpCounter),1));
      counter = 1;
      c=c+1;
      index = 1;
      tmpCounter = [];
      tmpCascade = [];
      tmpCounter(1)=1;

      x1=points(i,1);
      x2=points(i,2);
      x3=points(i,3);
      x4=points(i,4);
      n1=points(i,5);
      k1=points(i,6);
      tmpCascade(1) = n1;
   end  
end
      

% fid = fopen( 'GroupRows.txt', 'wt' );
% for i=1:25
%    fprintf(fid, 'Row %d participate %d times:\n', i,size(Row{i},2));
%    for j=1:2:size(Row{i},2)
%       fprintf(fid, '%d %d\n', Row{i}(j), Row{i}(j+1));
%    end
% end
% fclose(fid);

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

