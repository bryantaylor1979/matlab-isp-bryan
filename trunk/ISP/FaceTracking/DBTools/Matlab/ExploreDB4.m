%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [tree,fGetTreeSelections]=ExploreDB4(hf,Position,S,BaseDir)

%h - handle to figure
%Position - relative position
%S - ImageDB struct

import javax.swing.*;

name = 'Image DB';

RootDat.NodeData='.';
RootDat.IconWidth=16;%root icon width
RootDat.NodeDataIdx=0;
RootDat.Type=0;
root = ModUitreenode('v0','unselected',name, [], false ,RootDat);
tree = uitree( 'v0',hf,'Root', root,'ExpandFcn', @myExpfcn4);


drawnow ();
set(tree, 'Units', 'normalized', 'position', Position)
set(tree, 'NodeWillExpandCallback', @nodeWillExpand_cb4);
set(tree, 'NodeSelectedCallback', @nodeSelected_cb4);
fGetTreeSelections=@GetTreeSelections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


iconWidth = 72;
 


% we often rely on the underlying java tree
jtree = handle(tree.getTree,'CallbackProperties');
jtree.setRowHeight(72);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmp = tree. FigureComponent;
%cell_Data = cell(3,1);
cell_Data.InputStruct = S;
cell_Data.AppData.BaseDir =BaseDir;
cell_Data.CurrNodeDataIdx=0;
cell_Data.CurrNodeType=0;
cell_Data.ReturnSelectionList=[];
set(tmp, 'UserData', cell_Data);

t = tree.Tree;
set(t, 'MousePressedCallback', @mouse_cb);

% ExpendSelectedTree(root,tree);
% UpdateNodeCounts(root,0,0, 0);

% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse Pressed Handler
    function mouse_cb(h, ev)
        
        clickX = ev.getX;
        clickY = ev.getY;
        treePath = jtree.getPathForLocation(clickX, clickY);
        
        if ~isempty(treePath)
            node = treePath.getLastPathComponent;
            AppVal=NodeAppVal(node);
            iconWidth=AppVal.IconWidth;
            % check if the checkbox was clicked
            if ev.getModifiers()== ev.META_MASK % right click
                %SelectFunc(AppVal.NodeDataIdx,0,handles);
            
%                 if clickX > (jtree.getPathBounds(treePath).x+iconWidth) &&...
%                         clickX < (jtree.getPathBounds(treePath).x+iconWidth+25)
                    node = treePath.getLastPathComponent;
                    nodeValue = node.getValue;
                    % as the value field is the selected/unselected flag,
                    % we can also use it to only act on nodes with these values
                    switch nodeValue
                        case 'selected'
                            SetTreeVal(node,'unselected');
                            
                            jtree.treeDidChange();
                        case 'unselected'
                            SetTreeVal(node,'selected');
                            
                            jtree.treeDidChange();
                    end
                    
                %end
            end
        end
    end




    function List=GetTreeSelections()
        %generate a list of all selected indexes to the input array
        tmp =  tree. FigureComponent;
        S = get(tmp, 'UserData');
        %ExpendSelectedTree(root,tree);
        
        [List.Img,List.Face]=GetTreeSelection(root,[],[],S.InputStruct);
        S.ReturnSelectionList=List;
        
    end

    function cNode = nodeSelected_cb4(tree,ev)
        cNode = ev.getCurrentNode;
        tmp = tree.FigureComponent;
        cell_Data =get(tmp, 'UserData');
        cell_Data.CurrentNode = cNode;
        AppVal=NodeAppVal(cNode);
        cell_Data.CurrNodeDataIdx=AppVal.NodeDataIdx;
        cell_Data.CurrNodeType=AppVal.Type;
        set(tmp, 'UserData', cell_Data);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function nodes = myExpfcn4(tree,value)    
        
    
            tmp = tree. FigureComponent;
            S= get(tmp, 'UserData');
            cNode = S.CurrentNode; 
            if cNode.isLeaf
                nodes=ExpandNode(cNode,tree);
            else
                nodes=[];
            end
            
            
    end
    
    function nodes=ExpandNode(Node,Tree)
    
            count = 0;
            tmp = Tree. FigureComponent;
            S= get(tmp, 'UserData');
            s = S.InputStruct;
            BaseDir=S.AppData.BaseDir;
            Selected=Node.getValue;

            cNodeVal=NodeAppVal(Node);
            %if cNodeVal.Type ~=2 %it is not a face that is the end of the tree
                Children=FindChildren(cNodeVal,s,BaseDir);
                
                for i= 1: length(Children);
                    count = count + 1;
                    nodes(count) =  ModUitreenode('v0', Selected,Children(i).Name, Children(i).Icon, Children(i).IsLeaf , Children(i).AppVal );
                end
            %end
            
            if (count == 0)
               nodes = [];
            end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function cNode = nodeWillExpand_cb4(tree,ev)
        cNode = ev.getCurrentNode;
        tmp = tree.FigureComponent;
        cell_Data =get(tmp, 'UserData');
        cell_Data.CurrentNode = cNode;
        set(tmp, 'UserData', cell_Data);
    end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  function SetTreeVal(Node,Val)
  No= Node.getChildCount;
  if No>0
      for i=0:No-1
          SetTreeVal(Node.getChildAt(i),Val);
          
      end
  end
  
  Node.setValue(Val);
  ChangeName(Node,Val);
  %Node.setIcon(Icon);
  end
  
  function ExpendSelectedTree(Node,Tree)
  
%   Str=char(Node.getName);
%   display(sprintf(' In to : %s ',Str(43:end-11)));
  if  ~Node.isLeafNode  && Node.isLeaf && strcmp(Node.getValue ,'selected')  % expand Node
      nodes=ExpandNode(Node,Tree);
      if ~isempty(nodes)
          %Node.setAllowsChildren(1);
          
          for i=1:length(nodes)
              Node.add(nodes(i));
          end
      end
 
  end
  
  No= Node.getChildCount;
  if No>0
      for i=0:No-1
          ExpendSelectedTree(Node.getChildAt(i),Tree);
          
      end
  end
  
  
  end
  
  function [ImgList,FaceList]=GetTreeSelection(Node,ImgList,FaceList,S)
  
  if  ~Node.isLeafNode  && Node.isLeaf && strcmp(Node.getValue ,'selected')  % expand Node
      [ImgList,FaceList]=GetNodeTree(Node,ImgList,FaceList ,S);
      
  else
      
      No= Node.getChildCount;
      if No>0
          for i=0:No-1
              [ImgList,FaceList]=GetTreeSelection(Node.getChildAt(i),ImgList,FaceList,S);
              
          end
          
          
          
      end
      if strcmp(Node.getValue,'selected')
          
          Val=NodeAppVal(Node);
          if Val.NodeDataIdx>0
              if Val.Type==1
                  ImgList=[ImgList,Val.NodeDataIdx];
              elseif Val.Type==2
                  FaceList=[FaceList,Val.NodeDataIdx];
              end
          end
          
          %Node.setIcon(Icon);
      end
  end
  end
  
  function [ImgCount,FaceCount, DirCount]=UpdateNodeCounts(Node,ImgCount,FaceCount, DirCount)
  
  
  No= Node.getChildCount;
  if No>0
      for i=0:No-1
          [ImgCount,FaceCount, DirCount]=UpdateNodeCounts(Node.getChildAt(i),ImgCount,FaceCount, DirCount);
          
      end
  end
  
  Val=NodeAppVal(Node);
  switch(Val.Type)
      case 0
          DirCount=DirCount+1;
          Dat=get(Node,'UserData');
          Str=Dat.Name;
          f=strfind(Str,'(');
          if ~isempty(f)
              Str=Str(1:f(1)-1);
          end
          Str=sprintf('%s (D- %d I- %d F- %d)',Str,DirCount,ImgCount,FaceCount);
          SetName(Str,Node.getValue);
      case 1 
          ImgCount=ImgCount+1;
      case 2
          FaceCount=FaceCount+1;
  end
      
      %Node.setIcon(Icon);
  end
 
  
  function Str=NameChar(node)
     Str=get(node,'UserData');
     Str=Str.Name;
  end
  
  function Val=NodeAppVal(node)
     Val=get(node,'UserData');
     Val=Val.AppVal;
  end
  
  
  function ChangeName(node,mode)
     Str=char(node.getName);
     Pre='  ';
     switch (mode)
         case 'selected'
             Pre='<html><p style="background-color:yellow;">! ';
             Post='</p></html>';
         case 'unselected'
             Pre='<html><p style="background-color:white ;">- ';
             Post='</p></html>';
     end
     node.setName([Pre,Str(length(Pre)+1:end-length(Post)),Post]);
  end
  
  function Str=SetName(Str,mode)
     Pre='  ';
     switch (mode)
         case 'selected'
             Pre='<html><p style="background-color:yellow;">! ';
             Post='</p></html>';
         case 'unselected'
             Pre='<html><p style="background-color:white ;">- ';
             Post='</p></html>';
     end
     Str=[Pre,Str,Post];
  end
  
  function  node=ModUitreenode(ver ,value, string, icon, isLeaf, AppValue)
  
  node=uitreenode(ver ,value, SetName(string,value), icon, isLeaf );
  Dat.Name=string;
  Dat.AppVal=AppValue;
  set(node,'UserData',Dat);
  
  end
  
  
  function  [ImgList,FList]=GetNodeTree(Node,ImgList,FList,S)
  
  NodeVal=NodeAppVal(Node);
  FileList=S.FileList.ImgFiles;
  FaceList=S.FaceList.FaceDat;
  TmpImgList=[];
  TmpFaceList=[];
    
  switch( NodeVal.Type )
      case 0 % it is a dir
          for i =1:length(FileList)
              f=strfind(FileList(i).Dir,NodeVal.NodeData);
              if ~isempty(f) % there is a directory with the same starting
                  f=f(1);
                  if f+length(NodeVal.NodeData)-1==length(FileList(i).Dir) ||...
                          strcmp(FileList(i).Dir(f+1+length(NodeVal.NodeData):f+1+length(NodeVal.NodeData)+1),'DB')||...        % it is a directory leaf
                          FileList(i).Dir(f+length(NodeVal.NodeData))=='\' % the tree struct is going deeper
                      
                      TmpImgList=[TmpImgList,i];
                      
                  end
                  
                  
              end
          end
          
      case 1               %it is an image
          TmpImgList=NodeVal.NodeDataIdx;
      case 2
          %it is a face - no need to go deeper
          return
  end
  
  for j=1:length(TmpImgList)
      
      for i =1:length(FaceList)
          if strcmp(FaceList(i).FileName , FileList(TmpImgList(j)).FileName) && ...
              strcmp(FaceList(i).Dir , FileList(TmpImgList(j)).Dir)% face belong to image in node
              TmpFaceList=[TmpFaceList,i];
          end
          
      end
  end
          
  ImgList=[ImgList,TmpImgList];
  FList=[FList,TmpFaceList];
  
  end
  
  
  function ChildrenOrd=FindChildren(NodeVal,S,BaseDir)
  
  FileList=S.FileList.ImgFiles;
  FaceList=S.FaceList.FaceDat;
  
  Children=[];
  Type=[];
  pth = ['C:\Public\BRCM\RND\SV5\FT\Tools\Mat DB\SstructTree\exp_struct_icons\'];
  
  
  if ischar(NodeVal.NodeData) % it is a directory
      for i =1:length(FileList)
          Child=[];
          f=strfind(FileList(i).Dir,NodeVal.NodeData);
          if ~isempty(f) % there is a directory with the same starting
              f=f(1);
              if f+length(NodeVal.NodeData)-1==length(FileList(i).Dir) ||...
                      strcmp(FileList(i).Dir(f+1+length(NodeVal.NodeData):f+1+length(NodeVal.NodeData)+1),'DB')        % it is a directory leaf
                  Child.Name=[FileList(i).FileName,' (',num2str(FileList(i).NoOfFaces),' )'];
                  Child.IsLeaf=0;
                  Child.AppVal.Type=1;
                  Child.AppVal.NodeData=FileList(i);
                  Child.AppVal.IconWidth=FileList(i).SmlThumbX;
                  Child.AppVal.NodeDataIdx=i;
                  Child.Icon=[BaseDir,FileList(i).SmlThumbDir(2:end),'\',FileList(i).SmlThumbFile];
              elseif FileList(i).Dir(f+length(NodeVal.NodeData))=='\' % the tree struct is going deeper
                  s=strfind(FileList(i).Dir(f+1+length(NodeVal.NodeData):end),'\');
                  if isempty(s) % this is the last dir in this list
                      Child.Name=FileList(i).Dir(f+length(NodeVal.NodeData)+1:end);
                      Child.AppVal.NodeData=FileList(i).Dir;
                      
                  else% it will go deeper
                      Child.Name=FileList(i).Dir(f+length(NodeVal.NodeData)+1:f+length(NodeVal.NodeData)+s(1)-1);
                      Child.AppVal.NodeData=FileList(i).Dir(1:f+length(NodeVal.NodeData)+s(1)-1);
                  end
                  Child.IsLeaf=0;
                  Child.AppVal.Type=0;
                  
                  Child.Icon=[pth,'struct_icon.GIF'];
                  Child.AppVal.IconWidth=16;
                  Child.AppVal.NodeDataIdx=0;
                  
                  
              end
          end
          
          if ~isempty(Child)
              
              Found=0;
              for j= 1:length(Children) % check if it is already in Dir
                  if strcmp(Child.AppVal.NodeData , Children(j).AppVal.NodeData)
                      Found=1;
                      break;
                  end
              end
              if Found==0 % if it is a new child , add it
                  Children=[Children,Child];
                  Type=[Type, Child.AppVal.Type];
                  
              end
          end
          
      end
  else               %it is an image
      
      for i =1:length(FaceList)
          Child=[];
          if strcmp(FaceList(i).FileName , NodeVal.NodeData.FileName) && strcmp(FaceList(i).Dir , NodeVal.NodeData.Dir)  % face belong to image in node
              if ~isnan(FaceList(i).SmlThumbFile)
                  Child.Name=[FaceList(i).ThumbFile];
                  Child.IsLeaf=1;
                  Child.AppVal.Type=2;
                  Child.AppVal.NodeData=FaceList(i);
                  Child.AppVal.IconWidth=FaceList(i).SmlThumbX;
                  Child.AppVal.NodeDataIdx=i;
                  Child.Icon=[BaseDir,FaceList(i).SmlThumbDir(2:end),'\',FaceList(i).SmlThumbFile];
              end
              
          end
          
          
          if ~isempty(Child)
              
              Found=0;
              for j= 1:length(Children) % check if it is already in Dir
                  if strcmp(Child.AppVal.NodeData , Children(j).AppVal.NodeData)
                      Found=1;
                      break;
                  end
              end
              if Found==0 % if it is a new child , add it
                  Children=[Children,Child];
                  Type=[Type, Child.AppVal.Type];
                  
              end
          end
      end
      
  end
  
  
  
  DirList=find(Type==0);
  Files=find(Type==1);
  Faces=find(Type==2);
  ChildrenOrd=[Children(DirList),Children(Files),Children(Faces)];
  
  end
  