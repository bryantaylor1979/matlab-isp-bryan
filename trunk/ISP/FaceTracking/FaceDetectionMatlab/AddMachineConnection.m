function AddMachineConnection()

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'c:\Projects\FaceTracking\FaceDetect_V1.3\data\cascade_15to22_0_995.txt' );
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
            points = [points; [x1,x2,x3,-1,n,k]];
         case 1
            points = [points; [x1,-1,x3,-1,n,k]];
         case 2
            points = [points; [x1,x2,x3,x4,n,k]];
         case 3
            points = [points; [x1,-1,x3,-1,n,k]];
         case 4
            points = [points; [x1,x2,x3,-1,n,k]];
      end
   end
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
counter(c) = 1;
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
%counterArr x1 x2 x3 x4 numOfInstances in the same cascade , cascade
%number, example: 1    -1     2    -1     3    20, feature that his x1..x4
%are 1 -1 2 -2, appears 3 times in cascade 20, this feature appears also in
%other cascades but in the maximumnumber of appearnces is in cascade number
%20


%6= max legs number , 24-for each cascade.
MaxFeatures = 200;
MachineArr = zeros(size(MaxFeatures,1), NCas);
MachineLegsArr = zeros(size(MaxFeatures,1), 8);

for i=1:NFlt{NCas-8}
   legsArr = Flt{NCas-8}{i}(4:7);
   noRelevantPoints = 4;
   if (legsArr(2)==-1 && legsArr(4)==-1)
      noRelevantPoints = 2;
      legsArr = [legsArr(1),legsArr(3)]+1;
      MachineLegsArr(i,1)=legsArr(1);
      MachineLegsArr(i,2)=legsArr(2);
   elseif (legsArr(4)==-1)
      noRelevantPoints = 3;
      legsArr = legsArr(1:3)+1;
      MachineLegsArr(i,1)=legsArr(1);
      MachineLegsArr(i,2)=legsArr(2);
      MachineLegsArr(i,3)=legsArr(3);
   else
      legsArr = legsArr+1;
      MachineLegsArr(i,1)=legsArr(1);
      MachineLegsArr(i,2)=legsArr(2);
      MachineLegsArr(i,3)=legsArr(3);
      MachineLegsArr(i,4)=legsArr(4);
   end
   MachineArr(i,NCas-8)= NCas;
end

for cascade=NCas-9:-1:1
   for i=1:NFlt{cascade}
      legsArr = Flt{cascade}{i}(4:7);
      noRelevantPoints = 4;
      if (legsArr(2)==-1 && legsArr(4)==-1)
         noRelevantPoints = 2;
         legsArr = [legsArr(1),legsArr(3)]+1;
      elseif (legsArr(4)==-1)
         noRelevantPoints = 3;
         legsArr = legsArr(1:3)+1;
      else
         legsArr = legsArr+1;
      end
      MaxIntersectPoints = 0;
      for j=1:MaxFeatures
         currJLegsArr = MachineLegsArr(j,find(MachineLegsArr(j,:)));
         IntersectPoints = intersect(legsArr,currJLegsArr);
         InEnrey = size(legsArr,2)+size(currJLegsArr,2)-size(IntersectPoints,2);
         if(MaxIntersectPoints<size(IntersectPoints,2) && InEnrey<8)
            MaxIntersectPoints = size(IntersectPoints,2);
            MaxIntersectEntry = j;
            if(MaxIntersectPoints == noRelevantPoints)
               break;
            end
         end
      end
      if(noRelevantPoints == MaxIntersectPoints)
         MachineArr(MaxIntersectEntry,cascade) = cascade;
      else
         currJLegsArr = MachineLegsArr(MaxIntersectEntry,find(MachineLegsArr(MaxIntersectEntry,:)));
         newGroup = union(currJLegsArr,legsArr);
         newGroupSize = size(newGroup,2);
         if(newGroupSize>8)
            newGroupSize
         end
         MachineLegsArr(MaxIntersectEntry,1:newGroupSize)=newGroup;
         MachineArr(MaxIntersectEntry,cascade) = cascade;
      end
   end
end

legsEntries = size(find(MachineLegsArr~=0),1);
for cascade=15:1:22
   for i=1:NFlt{cascade}
      legsArr = Flt{cascade}{i}(4:7);
      noRelevantPoints = 4;
      if (legsArr(2)==-1 && legsArr(4)==-1)
         noRelevantPoints = 2;
         legsArr = [legsArr(1),legsArr(3)]+1;
      elseif (legsArr(4)==-1)
         noRelevantPoints = 3;
         legsArr = legsArr(1:3)+1;
      else
         legsArr = legsArr+1;
      end
      MaxIntersectPoints = 0;
      for j=1:MaxFeatures
         currJLegsArr = MachineLegsArr(j,find(MachineLegsArr(j,:)));
         IntersectPoints = intersect(legsArr,currJLegsArr);
         InEnrey = size(legsArr,2)+size(currJLegsArr,2)-size(IntersectPoints,2);
         if(MaxIntersectPoints<size(IntersectPoints,2) && InEnrey<8)
            MaxIntersectPoints = size(IntersectPoints,2);
            MaxIntersectEntry = j;
            if(MaxIntersectPoints == noRelevantPoints)
               break;
            end
         end
      end
      if(noRelevantPoints == MaxIntersectPoints)
         MachineArr(MaxIntersectEntry,cascade) = cascade;
      else
         currJLegsArr = MachineLegsArr(MaxIntersectEntry,find(MachineLegsArr(MaxIntersectEntry,:)));
         newGroup = union(currJLegsArr,legsArr);
         newGroupSize = size(newGroup,2);
         if(newGroupSize>8)
            newGroupSize
         end
         MachineLegsArr(MaxIntersectEntry,1:newGroupSize)=newGroup;
         MachineArr(MaxIntersectEntry,cascade) = cascade;
      end
   end
end
legsEntries = size(find(MachineLegsArr~=0),1);
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
% x1=points(1,1);
% x2=points(1,2);
% x3=points(1,3);
% x4=points(1,4);
% noLegs = size(find(MachineLegsArr(1,:)),2);
% noRelevantPoints = 4;
% if(x2==-1 && x4==-1)
%       noRelevantPoints = 2;
%       values=[points(1,1),points(1,3)];
%    elseif(x2==-1)
%       noRelevantPoints = 3;
%       values=[points(1,1),points(1,3),points(1,4)];
%    end
% MachineLegsArr(1,1:noRelevantPoints) = values;
%
% for i=2:size(points,1)
%    x1=points(i,1);
%    x2=points(i,2);
%    x3=points(i,3);
%    x4=points(i,4);
%    noRelevantPoints = 4;
%    if(x2==-1 && x4==-1)
%       noRelevantPoints = 2;
%      values=[points(1,1),points(1,3)];
%    elseif(x2==-1)
%       noRelevantPoints = 3;
%       legs=[points(1,1),points(1,3),points(1,4)];
%    end
%
%    for leg=legs(1):size(legs,2)
%       for j=1:i-1
%          currentLegsArr = MachineLegsArr(j);
%
%       end
%    end
% end

