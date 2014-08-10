function [FeaturesArr,MachineLegsArr]=buildMachineConnectionFor20()

Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
[NCas, NFlt, StrongTresh, Alphas, Flt] = LoadCascade( 'c:\Projects\FaceTracking\FaceDetect_V1.3\data\cascade_15to22_0_995.txt' );
points=[];

for n=NCas:-1:NCas-1
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
tmpCascade(index)=n1;

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
      
%6= max legs number , 24-for each cascade.
MaxFeatures = 200;
MaxMachines = 16;
MaxFeaturesPerMachine = 13;
FeaturesArr = cell(MaxMachines, NCas);
MachineLegsArr = zeros(MaxMachines, 24);

for i=1:MaxMachines
   legsArr = Flt{NCas}{i}(4:7);
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
%    MachineArr(i,NCas)= NCas;
   FeaturesArr{i,NCas} = i;
end

for cascade=NCas:-1:1
   if(cascade==NCas)
      start=MaxMachines+1;
   else
      start = 1;
   end
   for i=start:NFlt{cascade}
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
      MaxIntersectEntry = 0;
      for j=1:MaxMachines
         currJLegsArr = MachineLegsArr(j,find(MachineLegsArr(j,:)));
         IntersectPoints = intersect(legsArr,currJLegsArr);
         InEnrey = size(legsArr,2)+size(currJLegsArr,2)-size(IntersectPoints,2);
         if(MaxIntersectPoints<size(IntersectPoints,2) && InEnrey<24 && size(FeaturesArr{j,cascade},2)<MaxFeaturesPerMachine) %InEnrey<8 &&
            MaxIntersectPoints = size(IntersectPoints,2);
            MaxIntersectEntry = j;    
            if(MaxIntersectPoints == noRelevantPoints)
               break;
            end
         end
      end
      if(MaxIntersectEntry==0)
         MinLegsArr = 10000;
         MinIndex = 300;
          for j=1:MaxMachines
             currJLegsArr = size(MachineLegsArr(j,find(MachineLegsArr(j,:))),2);
             if((MinLegsArr>currJLegsArr) && (length(FeaturesArr{j,cascade})<MaxFeaturesPerMachine))
                 MinLegsArr = currJLegsArr;
                 MinIndex = j;
             end
          end
          MaxIntersectEntry = MinIndex;
      end
      
%       if(MachineArr(MaxIntersectEntry,cascade)~=0)
%          MachineArr(MaxIntersectEntry,cascade);
%       end
%       MachineArr(MaxIntersectEntry,cascade) = cascade;
      if(noRelevantPoints == MaxIntersectPoints)       
      else
         currJLegsArr = MachineLegsArr(MaxIntersectEntry,find(MachineLegsArr(MaxIntersectEntry,:)));
         newGroup = union(currJLegsArr,legsArr);
         newGroupSize = size(newGroup,2);
         MachineLegsArr(MaxIntersectEntry,1:newGroupSize)=newGroup;     
      end  
      FeaturesArr{MaxIntersectEntry,cascade} = union(FeaturesArr{MaxIntersectEntry,cascade},[i]);   
   end
end

fid = fopen('FeaturesArr.txt', 'w')
for c = 1:22
    for m=1:16
        fprintf(fid, '%d,', FeaturesArr{m,c}-1);
    end
    fprintf(fid, ',\n');
end
fclose(fid);

%rows represent cascades and in each row every column represent machine.
%for example : line 1- {4,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,}, means that in
%cascade 1 machine 1 calculate 4 features and machine 2 calculates 3
%feaures. in featuesArr.txt we know exactly which ones are they. 

fid = fopen('NFltAll.txt', 'w')
for c = 1:22
    fprintf(fid, '{');
    for m=1:16
         fprintf(fid, '%d,',length(FeaturesArr{m,c}));
    end
    fprintf(fid, '},\n');
end
fclose(fid);

fid = fopen('CasAll.txt', 'w')
for c = 1:22
    fprintf(fid, '{');
    for m=1:16
        fprintf(fid, '{');
        fprintf(fid, '%d,',[FeaturesArr{m,c}-1, zeros(1, 13-length(FeaturesArr{m,c}))]);
        fprintf(fid, '},\n');
    end
    fprintf(fid, '},\n');
end
fclose(fid);


MuxesRegArr = zeros(NCas, MaxMachines, MaxFeaturesPerMachine, 4, 4);
MuxesRegOperatorsArr = zeros(NCas, MaxMachines, MaxFeaturesPerMachine, 4, 4);

Muxes = zeros(MaxMachines, 4, 25);
fid = fopen('c:\Projects\FaceTracking\FaceDetectionMatlab\Output\LegsPerFilter16.txt', 'wt');
fid1 = fopen('c:\Projects\FaceTracking\FaceDetectionMatlab\Output\Entries16.txt', 'wt');


for cascade=1:NCas%NCas-1:NCas
   for machine=1:MaxMachines
      for filter=1:size(FeaturesArr{machine,cascade},2)
         filterIndex = FeaturesArr{machine,cascade}(filter);
         legsArr = Flt{cascade}{filterIndex}(4:7);
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
         
         columnsArr = Flt{cascade}{filterIndex}(8:11);
         noRelevantPoints = 4;
         if (columnsArr(2)==-1 && columnsArr(4)==-1)
            noRelevantPoints = 2;
            columnsArr = [columnsArr(1),columnsArr(3)]+1;
         elseif (columnsArr(4)==-1)
            noRelevantPoints = 3;
            columnsArr = columnsArr(1:3)+1;
         else
            columnsArr = columnsArr+1;
         end

         switch(Flt{cascade}{filterIndex}(3))
            case 0
               Entries = [1,2,3];
               
               tmp = squeeze(Muxes(machine,1,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,1,1:size(union(tmp,legsArr(1)),2))=union(tmp,legsArr(1));
               
               tmp = squeeze(Muxes(machine,2,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,2,1:size(union(tmp,legsArr(2)),2))=union(tmp,legsArr(2));
               
               tmp = squeeze(Muxes(machine,3,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,3,1:size(union(tmp,legsArr(3)),2))=union(tmp,legsArr(3));
                 
               MuxesRegArr(cascade,machine,filter,1,1:2) = columnsArr;
               MuxesRegArr(cascade,machine,filter,2,1:2) = columnsArr;
               MuxesRegArr(cascade,machine,filter,3,1:2) = columnsArr;
                 
               MuxesRegOperatorsArr(cascade,machine,filter,1,1:2) = [-1 1];
               MuxesRegOperatorsArr(cascade,machine,filter,2,1:2) = [2 -2];
               MuxesRegOperatorsArr(cascade,machine,filter,3,1:2) = [-1 1];          
            case 1
               Entries = [2,3];

               tmp = squeeze(Muxes(machine,2,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,2,1:size(union(tmp,legsArr(1)),2))=union(tmp,legsArr(1));

               tmp = squeeze(Muxes(machine,3,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,3,1:size(union(tmp,legsArr(2)),2))=union(tmp,legsArr(2));
               
               MuxesRegArr(cascade,machine,filter,2,1:3) = columnsArr;
               MuxesRegArr(cascade,machine,filter,3,1:3) = columnsArr;
               
               MuxesRegOperatorsArr(cascade,machine,filter,2,1:3) = [-1 2 -1];
               MuxesRegOperatorsArr(cascade,machine,filter,3,1:3) = [1 -2 1];
            case 2
               Entries = [1,2,3,4];
               
               tmp = squeeze(Muxes(machine,1,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,1,1:size(union(tmp,legsArr(1)),2))=union(tmp,legsArr(1));
               
               tmp = squeeze(Muxes(machine,2,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,2,1:size(union(tmp,legsArr(2)),2))=union(tmp,legsArr(2));
               
               tmp = squeeze(Muxes(machine,3,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,3,1:size(union(tmp,legsArr(3)),2))=union(tmp,legsArr(3));
               
               tmp = squeeze(Muxes(machine,4,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,4,1:size(union(tmp,legsArr(4)),2))=union(tmp,legsArr(4));
               
               MuxesRegArr(cascade,machine,filter,1,1:2) = columnsArr;
               MuxesRegArr(cascade,machine,filter,2,1:2) = columnsArr;
               MuxesRegArr(cascade,machine,filter,3,1:2) = columnsArr;
               MuxesRegArr(cascade,machine,filter,4,1:2) = columnsArr;
               
               MuxesRegOperatorsArr(cascade,machine,filter,1,1:2) = [1 -1];
               MuxesRegOperatorsArr(cascade,machine,filter,2,1:2) = [-3 3];
               MuxesRegOperatorsArr(cascade,machine,filter,3,1:2) = [3 -3];
               MuxesRegOperatorsArr(cascade,machine,filter,4,1:2) = [-1 1];
            case 3
               Entries = [2,3];
               
               tmp = squeeze(Muxes(machine,2,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,2,1:size(union(tmp,legsArr(1)),2))=union(tmp,legsArr(1));
               
               tmp = squeeze(Muxes(machine,3,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,3,1:size(union(tmp,legsArr(2)),2))=union(tmp,legsArr(2));
               
               MuxesRegArr(cascade,machine,filter,2,1:4) = columnsArr;
               MuxesRegArr(cascade,machine,filter,3,1:4) = columnsArr;

               MuxesRegOperatorsArr(cascade,machine,filter,2,1:4) = [1 -3 3 -1];
               MuxesRegOperatorsArr(cascade,machine,filter,3,1:4) = [-1 3 -3 1];
            case 4
               Entries = [2,3,4];

               tmp = squeeze(Muxes(machine,2,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,2,1:size(union(tmp,legsArr(1)),2))=union(tmp,legsArr(1));

               tmp = squeeze(Muxes(machine,3,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,3,1:size(union(tmp,legsArr(2)),2))=union(tmp,legsArr(2));

               tmp = squeeze(Muxes(machine,4,:));
               tmp = tmp(find(tmp))';
               tmp = unique(tmp);
               Muxes(machine,4,1:size(union(tmp,legsArr(3)),2))=union(tmp,legsArr(3));

               MuxesRegArr(cascade,machine,filter,2,1:3) = columnsArr;
               MuxesRegArr(cascade,machine,filter,3,1:3) = columnsArr;
               MuxesRegArr(cascade,machine,filter,4,1:3) = columnsArr;
               
               MuxesRegOperatorsArr(cascade,machine,filter,2,1:3) = [1 -2 1];
               MuxesRegOperatorsArr(cascade,machine,filter,3,1:3) = [-2 4 -2];
               MuxesRegOperatorsArr(cascade,machine,filter,4,1:3) = [1 -2 1];
         end
         fprintf(fid,'[');
         fprintf(fid,'%d ' ,legsArr);
         fprintf(fid,']');
         fprintf(fid1,'[');
         fprintf(fid1,'%d ' ,Entries);
         fprintf(fid1,']');
      end
      fprintf(fid,'\n');
      fprintf(fid1,'\n');
   end
   fprintf(fid,'\n');
   fprintf(fid1,'\n');
end

fclose(fid);
fclose(fid1);
fid2 = fopen('c:\Projects\FaceTracking\FaceDetectionMatlab\Output\Muxes16.txt', 'wt');
fid3 = fopen('c:\Projects\FaceTracking\FaceDetectionMatlab\Output\Muxes16Columns.txt', 'wt');
fid4 = fopen('c:\Projects\FaceTracking\FaceDetectionMatlab\Output\Muxes16ColumnsOperators.txt', 'wt');


for machine=1:MaxMachines
   for mux=1:4
      fprintf(fid2,['Muxes{ ', num2str(4*(machine-1)+mux), '} = [']);
      tmp = squeeze(Muxes(machine,mux,:));
      tmp = tmp(find(tmp));
      tmp = sort(tmp);
      tmp = tmp-1;
      if(find(tmp==0))
          zeroFlag = 1;
          tmp = tmp(2:end);
      end
      fprintf(fid2,'%d ' ,tmp-1); %Notice!!!!!! Now the indicies are from 0-23
      fprintf(fid2,'];\n');
   end
   fprintf(fid2,'\n');
end
fprintf(fid2,'\n\n');
fclose(fid2);

zeroFlag = 0;
for cascade=1:2
    for machine=1:MaxMachines
        for filter=1:13
            for mux=1:4
                fprintf(fid3,'[');
                tmp=MuxesRegArr(cascade,machine,filter,mux,:);
                tmp = tmp(find(tmp));
                tmp = sort(tmp);
                tmp = tmp-1;
                if(find(tmp==0))
                    zeroFlag = 1;
                    tmp = tmp(2:end);
                end
                
                fprintf(fid3,'%d ' ,tmp);
                fprintf(fid3,'] ');
                
                fprintf(fid4,'[');
                tmp=MuxesRegOperatorsArr(cascade,machine,filter,mux,:);
                tmp = tmp(find(tmp));
                if(zeroFlag==1)
                    zeroFlag = 0;
                    tmp = tmp(2:end);
                end
                fprintf(fid4,'%d ' ,tmp);
                fprintf(fid4,'] ');   
            end
            fprintf(fid3,'\n');
            fprintf(fid4,'\n');
        end
        fprintf(fid3,'\n\n');
        fprintf(fid4,'\n\n');
    end
     fprintf(fid3,'\n\n\n');
     fprintf(fid4,'\n\n\n');
end
fclose(fid3);
fclose(fid4);

% [4 5 6 7 8 9 11 12][4 5 6 7 8 9 1 11 12 13 14][4 6 7 8 9 1 11 12 13 14 2 21][7 8 9 1 12 14]
% [1 4 16 18][1 2 3 5 7 13 16 18 19 2 21][5 6 7 13 16 18 19 2 22 24][7 2 21 22 24]
% [8 12][1 2 5 6 8 11 12 14 16][1 2 5 6 8 11 12 14 16 2 23 24][2 8 11 16 23 24]
% [3 4 6 7 8 11 12 14][3 4 6 7 8 9 11 12 14 16 17 18][4 8 9 1 11 12 13 14 17 2 22 24][8 9 1 11 14 18 22 24]
% [4 7 12 13 18][1 8 9 12 13 14 15 2 21][7 8 9 12 13 14 15 16 18 21 22 24][15 16 21 23 24]
% [5 6 8 9 1 12][5 6 7 8 9 1 11 15 21][6 7 8 9 1 11 12 15 18 22][7 8 9 11 12 21 22]
% [9 11 12 13 14 15 16 17][11 12 13 14 15 16 17 19][13 15 16 17 18 21][14 16 17 18 19 21]
% [1 4 5 6 8][1 3 5 6 7 9 11 12 17][3 4 5 6 8 9 1 12 14 17 18 23][7 9 1 17 23]
% [4 7 1 11 12 13 14 16][1 4 6 7 9 1 11 12 13 14 15 17 2][5 6 7 1 11 12 13 14 16 17 21 24][6 13 14 15 16 17 21 24]
% [12 14 15 16 17 18 19][13 15 16 17 18 19 2 21][17 18 19 2 21 23 24][18 19 2 21 23 24]
% [3 5 8 9 1 11 13][5 6 8 9 1 11 12 14 16][5 7 8 9 1 11 12 13 14 15 16 2 24][8 11 12 13 14 16 24]
% [14 15 16][2 8 14 15 16 17 18 19][8 12 14 16 17 18 19 22 24][14 16 17 18 19 22]
% [1 15 18][1 2 8 13 14 15 16 19][1 2 3 9 1 15 16 17 18 2 21][2 3 18 2 21]
% [3 5 11 12 15 16][4 6 9 13 15 16 17 18 2][3 4 5 7 11 12 13 14 17 18 19 2 21 22 23][6 8 15 17 19 2 22 23]
% [3 4 5 6 7 8 9][3 4 5 6 7 8 9 1][4 5 6 7 8 9 1 11 12 13][6 7 9 1 11 12 13 14]
% [19 2 21][4 19 2 21 22][21 22 23 24][22 23 24]



% [5 6 7 8 9 10 12 13][1 5 6 7 8 9 10 11 12 13 14 15][5 7 8 9 10 11 12 13 14 15 21 22][8 9 10 11 13 15]
% [2 5 17 19][2 3 4 6 8 14 17 19 20 21 22][6 7 8 14 17 19 20 21 23 25][8 21 22 23 25]
% [1 9 13][1 2 3 6 7 9 12 13 15 17][2 3 6 7 9 12 13 15 17 21 24 25][3 9 12 17 24 25]
% [1 4 5 7 8 9 12 13 15][1 4 5 7 8 9 10 12 13 15 17 18 19][5 9 10 11 12 13 14 15 18 21 23 25][9 10 11 12 15 19 23 25]
% [1 5 8 13 14 19][1 2 9 10 13 14 15 16 21 22][8 9 10 13 14 15 16 17 19 22 23 25][16 17 22 24 25]
% [6 7 9 10 11 13][6 7 8 9 10 11 12 16 22][7 8 9 10 11 12 13 16 19 23][8 9 10 12 13 22 23]
% [10 12 13 14 15 16 17 18][12 13 14 15 16 17 18 20][14 16 17 18 19 22][15 17 18 19 20 22]
% [2 5 6 7 9][1 2 4 6 7 8 10 12 13 18][4 5 6 7 9 10 11 13 15 18 19 24][8 10 11 18 24]
% [1 5 8 11 12 13 14 15 17][1 2 5 7 8 10 11 12 13 14 15 16 18 21][6 7 8 11 12 13 14 15 17 18 22 25][7 14 15 16 17 18 22 25]
% [13 15 16 17 18 19 20][1 14 16 17 18 19 20 21 22][18 19 20 21 22 24 25][19 20 21 22 24 25]
% [4 6 9 10 11 12 14][1 6 7 9 10 11 12 13 15 17][6 8 9 10 11 12 13 14 15 16 17 21 25][9 12 13 14 15 17 25]
% [15 16 17][3 9 15 16 17 18 19 20][9 13 15 17 18 19 20 23 25][15 17 18 19 20 23]
% [1 2 16 19][1 2 3 9 14 15 16 17 20][2 3 4 10 11 16 17 18 19 21 22][3 4 19 21 22]
% [4 6 12 13 16 17][1 5 7 10 14 16 17 18 19 21][4 5 6 8 12 13 14 15 18 19 20 21 22 23 24][7 9 16 18 20 21 23 24]
% [4 5 6 7 8 9 10][4 5 6 7 8 9 10 11][5 6 7 8 9 10 11 12 13 14][7 8 10 11 12 13 14 15]
% [20 21 22][5 20 21 22 23][22 23 24 25][23 24 25]    
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

