N = 40;
n = 20;
picSize = 20;
Map = linspace( 0, 1, 256 )' * ones( 1, 3 );
numOfLayers = 11;

load NoMaskFacesImgLearn20x20;
load NoMaskNonFacesImg20x20;
load net11Layer;

facesLen = length(FacesImgLearn);
nonFacesLen = length(NonFacesImg);

P = cell(numOfLayers-1, nonFacesLen + facesLen);
T = cell(1, nonFacesLen + facesLen);

%Build P %%%%%%%%%%%%%%%%%%%%%%%%%%
%Read FacesMat%%%%%%%%%%%%%%%%%%%%%
for i=1:facesLen+nonFacesLen,
   
   if(i<=facesLen)
      currPic = FacesImgLearn(:,i);
      T{i} = 1;
   else
      currPic = NonFacesImg(:,i-facesLen);
      T{i} = -1;
   end
   
   currPic = reshape( currPic, picSize, picSize);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for j=1:4
      P{j,i} = zeros(100, 1);
   end
   slice = currPic(1:10, 1:10);
   P{1,i} = slice(:);  
   slice =  currPic(1:10, 11:20);
   P{2,i} = slice(:);  
   slice =  currPic(11:20, 1:10);
   P{3,i} = slice(:);  
   slice = currPic(11:20, 11:20);
   P{4,i} = slice(:);  
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    for j=5:20
%       P{j,i} = zeros(25, 1);
%    end
%    
%    slice = currPic(1:5, 1:5);
%    P{5,i} = slice(:);  
%    slice = currPic(1:5, 6:10);
%    P{6,i} = slice(:);  
%    slice = currPic(1:5, 11:15);
%    P{7,i} = slice(:);  
%    slice = currPic(1:5, 16:20);
%    P{8,i} = slice(:);  
%    
%    
%    slice = currPic(6:10, 1:5); 
%    P{9,i} = slice(:);  
%    slice = currPic(6:10, 6:10);
%    P{10,i} = slice(:);  
%    slice = currPic(6:10, 11:15);
%    P{11,i} = slice(:);  
%    slice = currPic(6:10, 16:20);
%    P{12,i} = slice(:);  
%    
%    slice = currPic(11:15, 1:5);
%    P{13,i} = slice(:);  
%    slice = currPic(11:15, 6:10);   
%    P{14,i} = slice(:);  
%    slice = currPic(11:15, 11:15);
%    P{15,i} = slice(:);  
%    slice = currPic(11:15, 16:20);
%    P{16,i} = slice(:);  
%    
%    slice = currPic(16:20, 1:5);
%    P{17,i} = slice(:);  
%    slice = currPic(16:20, 6:10);
%    P{18,i} = slice(:);  
%    slice = currPic(16:20, 11:15);
%    P{19,i} = slice(:);  
%    slice = currPic(16:20, 16:20);
%    P{20,i} = slice(:);  
%   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    for j=21:26
   for j=5:10
      P{j,i} = zeros(100, 1);
   end
   slice = currPic(1:5, :);
   P{5,i} = slice(:);  
   slice = currPic(4:8, :);
   P{6,i} = slice(:);  
   slice = currPic(7:11, :);
   P{7,i} = slice(:);  
   slice = currPic(10:14, :);
   P{8,i} = slice(:);  
   slice = currPic(13:17, :);
   P{9,i} = slice(:);  
   slice = currPic(16:20, :);
   P{10,i} = slice(:);  
   
end 
save('P20x20','P');
save('T20x20','T');

display('End');
%Build T %%%%%%%%%%%%%%%%%%%%%%%%%%