classdef DLS_Calc < handle
    properties (SetObservable = true)
        ClearVar = true
        RGB_base
        weights
        imageSTATS
        rg_enable = true;
        bg_enable = true;
        g_enable = false;
        GridSize = [24,32];
        ls_tables
        imageIN
    end
    methods (Hidden = false)
        function RUN(obj)
			obj.RGB_base = obj.LoadBase();
            obj.weights = ones( obj.GridSize(1), obj.GridSize(2) );
            stats = obj.getwbstats2(obj.imageIN.image,obj.GridSize)./2^6;     
            
            obj.imageSTATS = obj.imageIN;
            obj.imageSTATS.image = stats;
            
            [obj.ls_tables] = obj.dls(  stats, ...
                                        obj.RGB_base, ...
                                        obj.weights, ...
                                        obj.rg_enable, ...
                                        obj.bg_enable, ...
                                        obj.g_enable);   
            if obj.ClearVar == true 
                obj.RGB_base = [];
                obj.weights = [];
                obj.imageIN.image = [];
                obj.imageSTATS = [];
            end
        end
    end
    methods (Hidden = true)
        function base = LoadBase(obj)
             load 'base';
        end
    	function [ls_tables] = dls(obj,RGB_Image, RGB_base, weights, rg_enable, bg_enable, g_enable)
            
            RGB_Image = double(RGB_Image);
            RGB_base = double(RGB_base);  
            
            RG_BG_base = obj.luma2chroma(RGB_base);
            RG_BG_Image = obj.luma2chroma(RGB_Image);            
            
            weights_rg = weights;
            weights_bg = weights;
            weights_g = weights;

            % R/G
            if (rg_enable)
                fprintf(1, 'RG\n');
                %RG_BG_base(:,:,1) -> r/g from the base image
                %RG_BG_Image(:,:,1) -> r/g from the stats image
                [ls_table_rg] = obj.dls_single(RG_BG_Image(:,:,1), RG_BG_base(:,:,1), weights_rg, 0.14, 0.03, 2, 'RG');
            else
                ls_table_rg = ones(size(img_rg));
            end

            % B/G
            if (bg_enable)
                fprintf(1, 'BG\n');
                %RG_BG_base(:,:,2) -> b/g
                %RG_BG_Image(:,:,2) -> b/g from the stats image
                [ls_table_bg] = obj.dls_single(RG_BG_Image(:,:,2), RG_BG_base(:,:,2), weights_bg, 0.05, 0.03, 2, 'BG');  
            else
                ls_table_bg = ones(size(img_bg));
            end

            % G
            if (g_enable)
                fprintf(1, 'G\n');
                [ls_table_g] = dls_single(RGB_Image(:,:,2), base_g, weights_g, 0.14, 0.03, 1, 'vignetting');
            else
                ls_table_g = ones(size(RGB_Image(:,:,2))); % green channel image size
            end

            ls_table_r = ls_table_rg .* ls_table_g;
            ls_table_b = ls_table_bg .* ls_table_g;

            ls_tables = cat(3, ls_table_r, ls_table_g, ls_table_b);
        end 
        function [ls_table] = dls_single(obj,img, base, wgt0, global_thresh, local_thresh, num_iter, method)
        % dls_single.m
        %
        % deform base to fit img.
        %
        
        iter_thresh_decay = 0.9;

        % transform everything to log space
        img = log(img);
        base = log(base);
        base = base - obj.dls_centerval(base);

        %filt = [1 2 1; 2 4 2; 1 2 1] / 16;
        %img = imfilter(img, filt, 'same', 'replicate');

        ls_table = zeros(size(img));

        % compute derivatives

        img_dx = obj.dls_dx(img);
        img_dy = obj.dls_dy(img);

        base_dx = obj.dls_dx(base);
        base_dy = obj.dls_dy(base);
        
        h1 = figure;
        h2 = figure;
        h3 = figure;

        for iter=1:num_iter

            fprintf(1, 'iter: #%d\n', iter);

            if or((strcmp(method, 'BG') || strcmp(method, 'vignetting')),(strcmp(method, 'RG') || strcmp(method, 'vignetting')))

                % -- GLOBAL FITTING --

                % calculate dx, dy weights
                wgt_dx = obj.dls_weight(img_dx, global_thresh) .* wgt0;
                wgt_dy = obj.dls_weight(img_dy, global_thresh) .* wgt0;

                % clean derivatives
                img_dx_dn = obj.dls_dn(img_dx, wgt_dx);
                img_dy_dn = obj.dls_dn(img_dy, wgt_dy);

                bases_dx{1} = base_dx;
                bases_dy{1} = base_dy;
                coeff = obj.dls_global_fit(img_dx_dn, img_dy_dn, wgt_dx, wgt_dy, bases_dx, bases_dy);

                fprintf(1, 'base_power: %.2f\n', coeff(1));

                surface = base * coeff(1);
                surface_dx = base_dx * coeff(1);
                surface_dy = base_dy * coeff(1);

                % update table and derivatives
                ls_table = ls_table + surface;
                img_dx = img_dx - surface_dx;
                img_dy = img_dy - surface_dy;

                % -- LOCAL FITTING --

                % calculate dx, dy weights
                wgt_dx = obj.dls_weight(img_dx, local_thresh);
                wgt_dy = obj.dls_weight(img_dy, local_thresh);

                % clean derivatives
                img_dx_dn = obj.dls_dn(img_dx, wgt_dx);
                img_dy_dn = obj.dls_dn(img_dy, wgt_dy);

                [surface, surface_dx, surface_dy] = obj.dls_local_fit(img_dx_dn, img_dy_dn, wgt_dx, wgt_dy);

                % update table and derivatives
                ls_table = ls_table + surface;
                img_dx = img_dx - surface_dx;
                img_dy = img_dy - surface_dy;
            end

            % update thresholds
            global_thresh = global_thresh * iter_thresh_decay;
            local_thresh = local_thresh * iter_thresh_decay;
            
 
            figure(h1);
            surf(img);
            set(h1,'NumberTitle','off','Name',[method,': Image Surface Plot - Last Inter of ',num2str(iter)]);
            
            figure(h2);
            surf(ls_table);
            set(h2,'NumberTitle','off','Name',[method,': Estimated Lens Shading - Last Inter of ',num2str(iter)]);
            
            figure(h3);
            surf(img - ls_table);
            set(h3,'NumberTitle','off','Name',[method,': Residuals - Last Inter of ',num2str(iter)]);

        end

        ls_table = exp(-ls_table);

        end
        function [wgt] = dls_weight(obj,x, thresh)
            wgt = exp(-x.^2 ./ (thresh.^2));
        end
        function [img_dx] = dls_dx(obj,img)
            filt_dx = ...
              [ 0  0 0 ;
               -1  0 1 ;
                0  0 0 ] / 2;
            img_dx = imfilter(img, filt_dx, 'same', 'replicate');
            img_dx(:,1) = img_dx(:,1)*2;
            img_dx(:,end) = img_dx(:,end)*2;
        end
        function [img_dy] = dls_dy(obj,img)
            img_dy = obj.dls_dx(img')';
        end
        function [coeff] = dls_global_fit(obj,img_dx, img_dy, wgt_dx, wgt_dy, bases_dx, bases_dy)
        N = length(bases_dx);
        A = zeros(N, N);
        b = zeros(N, 1);

        for i=1:N
            for j=1:N
                A(i, j) = obj.dls_iprod_wgt(bases_dx{i}, bases_dx{j}, wgt_dx) + obj.dls_iprod_wgt(bases_dy{i}, bases_dy{j}, wgt_dy);
            end

            b(i) = obj.dls_iprod_wgt(img_dx, bases_dx{i}, wgt_dx) + obj.dls_iprod_wgt(img_dy, bases_dy{i}, wgt_dy);
        end

        coeff = A \ b;
        end
        function [res] = dls_iprod_wgt(obj,A, B, wgt)
            res = obj.dls_sum2_wgt(A .* B, wgt);
        end
        function [res] = dls_sum2_wgt(obj,A, wgt)
            res = sum(sum(A .* wgt));
        end
        function [dn] = dls_dn(obj, img, wgt)
            % currently, no denoise.
            dn = img;
        end
        function [res] = dls_centerval(obj,img)
            w = size(img, 2);
            h = size(img, 1);
            i0 = floor((h-1)/2) + 1;
            j0 = floor((w-1)/2) + 1;
            res = ( img(i0, j0) + img(i0, j0+1) + img(i0+1, j0) + img(i0+1, j0+1) ) / 4;
        end
        function [surface, surface_dx, surface_dy] = dls_local_fit(obj,img_dx, img_dy, wgt_dx, wgt_dy)
            %[surface, surface_dx, surface_dy] = dls_local_fit_energy(img_dx, img_dy, wgt_dx, wgt_dy);
            [surface, surface_dx, surface_dy] = obj.dls_local_fit_bilinear(img_dx, img_dy, wgt_dx, wgt_dy, 4, 4);
        end
        function [surface, surface_dx, surface_dy] = dls_local_fit_energy(obj,img_dx, img_dy, wgt_dx, wgt_dy)
            params0 = zeros([1, 5*5]);
            dls_energy_func = @(x) dls_energy_cs(x, img_dx, img_dy, wgt_dx, wgt_dy);
            params = fminunc(dls_energy_func, params0);

            [surface, surface_dx, surface_dy] = dls_surface_cs(params);
            %E = dls_energy_cs(params, img_dx, img_dy, wgt_dx, wgt_dy);
        end
        function [E] = dls_energy_cs(obj,params, img_dx, img_dy, wgt_dx, wgt_dy)
            [surface, surface_dx, surface_dy] = dls_surface_cs(params);
            E_outer = sum(sum(wgt_dx .* (surface_dx - img_dx).^2)) + sum(sum(wgt_dy .* (surface_dy - img_dy).^2));
            %E_inner = sum(sum(srf_dx.^2 + srf_dy.^2)) + srf(12,16)^2;
            E_inner = obj.dls_centerval(surface)^2;
            %E_inner = 0;

            E = E_outer + E_inner;
        end
        function [surface, surface_dx, surface_dy] = dls_surface_cs(obj,params)
            deform = reshape(params, [5, 5]);
            [x, y] = meshgrid(0:4, 0:4);
            x = x/4;
            y = y/4;

            [xi, yi] = meshgrid(0:31, 0:23);
            xi = (0.5 + xi) / 32;
            yi = (0.5 + yi) / 24;

            deform_i = interp2(x, y, deform, xi, yi, 'cubic');

            %surface = base * base_power;
            %surface = base * base_power + deform_i;
            %surface = base .* deform_i;
            surface = deform_i;

            surface_dx = dls_dx(surface);
            surface_dy = dls_dy(surface);
        end
        function [E] = dls_energy_vignetting(obj,params, img_dx, img_dy, wgt_dx, wgt_dy)
            [surface, surface_dx, surface_dy] = dls_surface_vignetting(params);
            E_outer = sum(sum(wgt_dx .* (surface_dx - img_dx).^2)) + sum(sum(wgt_dy .* (surface_dy - img_dy).^2));
            %E_inner = sum(sum(srf_dx.^2 + srf_dy.^2)) + srf(12,16)^2;
            E_inner = obj.dls_centerval(surface)^2;
            %E_inner = 0;
            E = E_outer + E_inner;
        end
        function [surface, surface_dx, surface_dy] = dls_surface_vignetting(obj,params)
            deform = reshape(params, [5, 5]);

            [x, y] = meshgrid(0:4, 0:4);
            x = x/4 - 0.5;
            y = y/4 - 0.5;

            [xi, yi] = meshgrid(0:31, 0:23);
            xi = (0.5 + xi) / 32;
            yi = (0.5 + yi) / 24;

            xi = xi - 0.5;
            yi = yi - 0.5;

            deform_i = interp2(x, y, deform, xi, yi, 'spline');

            %surface = base * base_power;
            %surface = base * base_power + deform_i;
            %surface = base .* deform_i;
            surface = deform_i;

            surface_dx = dls_dx(surface);
            surface_dy = dls_dy(surface);
        end        
        function [surface, surface_dx, surface_dy] = dls_local_fit_bilinear(obj,img_dx, img_dy, wgt_dx, wgt_dy, M, N)
            w = size(img_dx, 2);
            h = size(img_dx, 1);

            BLK_W = floor(w / N);
            BLK_H = floor(h / M);

            horiz_map = zeros(M, N);
            vert_map = zeros(M, N);
            diag_map = zeros(M, N);
            wgt_map = zeros(M, N);

            for i=0:M-1

                for j=0:N-1

                    y0 = i*BLK_H + 1;
                    x0 = j*BLK_W + 1;
                    y1 = y0 + BLK_H - 1;
                    x1 = x0 + BLK_W - 1;

                    img_dx_blk = img_dx(y0:y1, x0:x1);
                    img_dy_blk = img_dy(y0:y1, x0:x1);

                    wgt_dx_blk = wgt_dx(y0:y1, x0:x1);
                    wgt_dy_blk = wgt_dy(y0:y1, x0:x1);

                    [p00, p01, p10, p11, wgt] = obj.dls_approximate_block_bl(img_dx_blk, img_dy_blk, wgt_dx_blk, wgt_dy_blk);

                    horiz_map(i+1, j+1) = p01 - p00;
                    vert_map(i+1, j+1) = p10 - p00;
                    diag_map(i+1, j+1) = p11 - p00;
                    wgt_map(i+1, j+1) = wgt;

                end

            end

            % construct integration matrix
            A = zeros(M*N*3+1, (M+1)*(N+1));
            W = zeros(M*N*3+1, M*N*3+1);
            b = zeros(M*N*3+1, 1);

            row = 1;

            for i=1:M
                for j=1:N
                    % horiz        
                    A(row, (i-1)*(N+1)+j+0) = -1;
                    A(row, (i-1)*(N+1)+j+1) =  1;
                    b(row) = horiz_map(i, j);
                    W(row, row) = wgt_map(i, j);

                    % vert        
                    A(row+M*N, (i-1)*(N+1)+j) = -1;
                    A(row+M*N, (i-0)*(N+1)+j) =  1;
                    b(row+M*N) = vert_map(i, j);
                    W(row+M*N, row+M*N) = wgt_map(i, j);

                    % diag        
                    A(row+M*N*2, (i-1)*(N+1)+j+0) = -1;
                    A(row+M*N*2, (i-0)*(N+1)+j+1) =  1;
                    b(row+M*N*2) = diag_map(i, j);
                    W(row+M*N*2, row+M*N*2) = wgt_map(i, j);

                    row = row + 1;
                end
            end

            if (M == 1 && N == 1)
                A(end, :) = [1, 1, 1, 1];
            else
                A(end, floor((M+1)*(N+1)/2)+1) = 1;
            end

            W(end,end) = 1;

            b(end) = 0;

            W = eye(size(W));

            AA = ( A' * W * A ) \ (A' * W);
            potential_v = AA * b;

            potential = reshape(potential_v, M+1, N+1)';

            % interpolate to image size
            surface = obj.dls_interp_bilinear(potential, BLK_W, BLK_H);

            surface_dx = obj.dls_dx(surface);
            surface_dy = obj.dls_dy(surface);
        end
        function [p00, p01, p10, p11, wgt] = dls_approximate_block_bl(obj,blk_dx, blk_dy, wgt_dx, wgt_dy)
            w = size(blk_dx, 2);
            h = size(blk_dx, 1);

            [x, y] = meshgrid(0:w-1, 0:h-1);
            x = (x + 0.5) / w;
            y = (y + 0.5) / h;

            BL0{1} =     x .* (1-y);
            BL0{2} = (1-x) .* y;
            BL0{3} =     x .* y;

            BLx{1} = (1-y) / w;
            BLy{1} = -x / h;

            BLx{2} = -y / w;
            BLy{2} = (1-x) / h;

            BLx{3} = y / w;
            BLy{3} = x / h;

            coeff = obj.dls_global_fit(blk_dx .* wgt_dx, blk_dy .* wgt_dy, ones(size(blk_dx)), ones(size(blk_dy)), BLx, BLy);
            w = 1;

            p00 = 0;
            p01 = coeff(1) * w;
            p10 = coeff(2) * w;
            p11 = coeff(3) * w;

            wgt = 1;
        end
        function [img_interp] = dls_interp_bilinear(obj,img, blk_w, blk_h)
            M = size(img, 1) - 1;
            N = size(img, 2) - 1;
            [x, y] = meshgrid(0:blk_w-1, 0:blk_h-1);
            x = (x+0.5)/blk_w;
            y = (y+0.5)/blk_h;
            img_interp = zeros(M*blk_h, N*blk_w);

            for i=0:M-1
                for j=0:N-1
                    y0 = i*blk_h + 1;
                    x0 = j*blk_w + 1;
                    y1 = y0 + blk_h - 1;
                    x1 = x0 + blk_w - 1;
                    p00 = img(i+1, j+1);
                    p01 = img(i+1, j+2);
                    p10 = img(i+2, j+1);
                    p11 = img(i+2, j+2);
                    img_interp(y0:y1, x0:x1) = p00*(1-x).*(1-y) + p01*x.*(1-y) + p10*(1-x).*y + p11*x.*y;
                end
            end
        end   
        function [stats] = getwbstats2(obj,mosImg,gridsize)
            [y, x, z] = size(mosImg);
            fun = @(block_struct)mean2(block_struct.data);
            
            Y = round(y/gridsize(1));
            X = round(x/gridsize(2));
            
            stats_r  = blockproc( mosImg(:,:,1), [Y, X], fun );
            stats_gr = blockproc( mosImg(:,:,2), [Y, X], fun );
            stats_gb = blockproc( mosImg(:,:,2), [Y, X], fun );
            stats_b  = blockproc( mosImg(:,:,3), [Y, X], fun );
            stats_g = (stats_gr + stats_gb) / 2;
            stats = cat(3, stats_r, stats_g, stats_b);            
        end
        function RG_BG = luma2chroma(obj,RGB)
            RGB = double(RGB);
            RG_BG(:,:,1) = RGB(:,:,1)./ RGB(:,:,2);
            RG_BG(:,:,2) = RGB(:,:,3)./ RGB(:,:,2);            
        end
        function obj = DLS_Calc()    
        end
    end
end