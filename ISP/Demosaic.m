classdef Demosaic <     handle & ...
                        FeederObject
    properties (SetObservable = true)
        ClearVar = true;
        Mode = 'bilinear';  %bilinear
        BayerOrder = 1;
        imageIN
        imageOUT
    end
    methods
        function RUN(obj,imagein)
            disp('Running Demosaic')
            obj.imageOUT.image = []; %Save memory.
            switch lower(obj.Mode)
                case 'bilinear' 
                    obj.imageOUT = obj.imageIN;
                    obj.imageOUT.image = obj.biDemosaic(obj.imageIN.image,obj.BayerOrder);
                    
                otherwise
            end
            if obj.ClearVar == true
                obj.imageIN.image = [];
            end
            obj.imageOUT.class = obj.imageIN.class;
            obj.imageOUT.type = obj.imageIN.type;
            obj.imageOUT.fsd = obj.imageIN.fsd ;
        end
    end
    methods (Hidden = true)
        function obj = Demosaic(varargin)
            x = size(varargin,2);
            for i = 1:2:x
               obj.(varargin{i}) =  varargin{i+1};
            end   
            if not(isempty(obj.InputObject))
                obj.ClassType = 'image';
                obj.LinkObjects;
                obj.UpdateLink;
            end
        end
        function [rgbImage] = biDemosaic(obj,image,config)
            
            %Bilinear demosaicing for Bayer patterns
            %
            %config  : bayer order
            %            config = 1  R G
            %                        G B
            %            config = 2  B G
            %                        G R
            %            config = 3  G R
            %                        B G
            %            config = 4  G B
            %                        R G
            config = obj.BayerOrder;
            [nRow nCol] = size(image);
            rgbImage = zeros(nRow,nCol,3);

            rbKernel = ...
                [ 0.25 0.5 0.25; ...
                  0.50 1.0 0.50; ...
                  0.25 0.5 0.25];

            gKernel  = ...
                [0.00 0.25 0.00; ...
                 0.25 1.00 0.25; ...
                 0.00 0.25 0.00];

            if config == 1,

              rRow = [1:2:nRow];
              rCol = [1:2:nCol];
              bRow = [2:2:nRow];
              bCol = [2:2:nCol];
              g1Row = [1:2:nRow];
              g1Col = [2:2:nCol];
              g2Row = [2:2:nRow];
              g2Col = [1:2:nCol];

            elseif config == 2,

              rRow = [2:2:nRow];
              rCol = [2:2:nCol];
              bRow = [1:2:nRow];
              bCol = [1:2:nCol];
              g1Row = [1:2:nRow];
              g1Col = [2:2:nCol];
              g2Row = [2:2:nRow];
              g2Col = [1:2:nCol];

            elseif config == 3,

              rRow = [1:2:nRow];
              rCol = [2:2:nCol];
              bRow = [2:2:nRow];
              bCol = [1:2:nCol];
              g1Row = [1:2:nRow];
              g1Col = [1:2:nCol];
              g2Row = [2:2:nRow];
              g2Col = [2:2:nCol];

            else 

              rRow = [2:2:nRow];
              rCol = [1:2:nCol];
              bRow = [1:2:nRow];
              bCol = [2:2:nCol];
              g1Row = [1:2:nRow];
              g1Col = [1:2:nCol];
              g2Row = [2:2:nRow];
              g2Col = [2:2:nCol];

            end
            rgbImage(rRow,rCol,1) = image(rRow,rCol);
            rgbImage(bRow,bCol,3) = image(bRow,bCol);
            rgbImage(g1Row,g1Col,2) = image(g1Row,g1Col);
            rgbImage(g2Row,g2Col,2) = image(g2Row,g2Col);

            % Interpolate the data here
            rgbImage(:,:,1) = conv2(rgbImage(:,:,1),rbKernel,'same');
            rgbImage(:,:,2) = conv2(rgbImage(:,:,2),gKernel,'same');
            rgbImage(:,:,3) = conv2(rgbImage(:,:,3),rbKernel,'same');
            
            switch class(image)
                case 'uint16'
                    rgbImage = uint16(rgbImage);
                case 'double'
                case 'uint8'
                    rgbImage = uint8(rgbImage);
                otherwise
                    error('class not supported')
            end
            clearvars gData image        
        end
    end
end
    
