classdef JPEG_Obj_v1 < handle
    
    properties (GetAccess=public)
        Name
        Width
        Height
        DCT_Coefficients
        Quant_Tables
        AC_Coefficients
        DC_Coefficients
        
        %Blocks fields
        Block_rows
        Block_columns
        Blocks_Y
        Blocks_Cb
        Blocks_Cr
        
        %Bitplanes fields
        Nb_Bitplanes=8;
        Coeff_type='int8';
        Bitplanes_Y
        Bitplanes_Cb
        Bitplanes_Cr
        
        %Complexity Process
        Noise_areas_Y
        Noise_areas_Cb
        Noise_areas_Cr
        Noise_areas_Blocks_Y
        Noise_areas_Blocks_Cb
        Noise_areas_Blocks_Cr
        
        Payload_Capacity_LSB
        Payload_Capacity_BPCS
    end
    
    % Private methods
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function JPEG_Image=JPEG_Obj(Image)
            Read_Data=jpeg_read(Image);
            [~,Name,Ext] = fileparts(Image);
            
            if (strcmp(Ext,'.jpg'))
                %Initialization of class fileds
                JPEG_Image.Name =              Name;
                JPEG_Image.Width =             Read_Data.image_width;
                JPEG_Image.Height =            Read_Data.image_height;
                JPEG_Image.DCT_Coefficients =  Read_Data.coef_arrays;
                
                JPEG_Image.Quant_Tables =      Read_Data.quant_tables;
                JPEG_Image.AC_Coefficients =   Read_Data.ac_huff_tables;
                JPEG_Image.DC_Coefficients =   Read_Data.dc_huff_tables;
                
                JPEG_Image.Block_rows =        size(JPEG_Image.DCT_Coefficients{1},1)/8;
                JPEG_Image.Block_columns =     size(JPEG_Image.DCT_Coefficients{1},2)/8;
                
                %Bitplanes cells initialization for each channel
                JPEG_Image.Bitplanes_Y =       cell(JPEG_Image.Block_rows, JPEG_Image.Block_columns);
                JPEG_Image.Bitplanes_Cb =      cell(JPEG_Image.Block_rows, JPEG_Image.Block_columns);
                JPEG_Image.Bitplanes_Cr =      cell(JPEG_Image.Block_rows, JPEG_Image.Block_columns);
            end
        end
        
        %==================================================================
        % DCT Coefficients to Blocks and vice versa
        %==================================================================
        function DCT_Coeff_to_Blocks(JPEG_Image)
            %Matrix with the width of each block
            x=repmat(8,JPEG_Image.Block_rows,1)';
            %Matrix with the height of each block
            y=repmat(8,JPEG_Image.Block_columns,1)';
            %Convert the matrix into sub-matrix stored in a cell
            JPEG_Image.Blocks_Y = mat2cell(JPEG_Image.DCT_Coefficients{1}, x, y);
            JPEG_Image.Blocks_Cb = mat2cell(JPEG_Image.DCT_Coefficients{2}, x, y);
            JPEG_Image.Blocks_Cr = mat2cell(JPEG_Image.DCT_Coefficients{3}, x, y);
        end
        
        function Blocks_to_DCT_Coeff(JPEG_Image)
            JPEG_Image.DCT_Coefficients{1} = cell2mat(JPEG_Image.Blocks_Y);
            JPEG_Image.DCT_Coefficients{2} = cell2mat(JPEG_Image.Blocks_Cb);
            JPEG_Image.DCT_Coefficients{3} = cell2mat(JPEG_Image.Blocks_Cr);
        end
        
        %==================================================================
        % Blocks of each channel to bitplanes and vice versa
        %==================================================================
        function Blocks_to_Bitplanes(JPEG_Image)
            %How many bitplanes do we need?
            %By default it is 8, but it could be 16
            Pow=[8 16];
            for x = Pow
                if max(abs(JPEG_Image.DCT_Coefficients{1}(:))) > 2^x
                    JPEG_Image.Nb_Bitplanes = x*2;
                    JPEG_Image.Coeff_type = 'int16';
                end
            end
            
            %The first two loops are used to go through all the blocks of each channel
            for i= 1:JPEG_Image.Block_rows
                for j= 1:JPEG_Image.Block_columns
                    %The third one is used to build the bitplanes
                    for bitplane=1:JPEG_Image.Nb_Bitplanes
                        JPEG_Image.Bitplanes_Y{i,j}(:,:,bitplane) = bitget(JPEG_Image.Blocks_Y{i,j},JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
                        JPEG_Image.Bitplanes_Cb{i,j}(:,:,bitplane) = bitget(JPEG_Image.Blocks_Cb{i,j},JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
                        JPEG_Image.Bitplanes_Cr{i,j}(:,:,bitplane) = bitget(JPEG_Image.Blocks_Cr{i,j},JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
                    end
                end
            end
        end
        
        function Bitplanes_to_Blocks(JPEG_Image)
            for i= 1:JPEG_Image.Block_rows
                for j= 1:JPEG_Image.Block_columns
                    % Zero initialization of each block
                    for bitplane= 1:JPEG_Image.Nb_Bitplanes
                        JPEG_Image.Blocks_Y{i,j}(:,:) = JPEG_Image.Blocks_Y{i,j}(:,:) + bitshift(JPEG_Image.Bitplanes_Y{i,j}(:,:,bitplane),JPEG_Image.Nb_Bitplanes-bitplane);
                        JPEG_Image.Blocks_Cb{i,j}(:,:) = JPEG_Image.Blocks_Cb{i,j}(:,:) + bitshift(JPEG_Image.Bitplanes_Cb{i,j}(:,:,bitplane),JPEG_Image.Nb_Bitplanes-bitplane);
                        JPEG_Image.Blocks_Cr{i,j}(:,:) = JPEG_Image.Blocks_Cr{i,j}(:,:) + bitshift(JPEG_Image.Bitplanes_Cr{i,j}(:,:,bitplane),JPEG_Image.Nb_Bitplanes-bitplane);
                    end
                    
                    JPEG_Image.Blocks_Y{i,j}(JPEG_Image.Blocks_Y{i,j} > 2^15-1) = JPEG_Image.Blocks_Y{i,j}(JPEG_Image.Blocks_Y{i,j} > 2^(JPEG_Image.Nb_Bitplanes-1)-1) - 2^JPEG_Image.Nb_Bitplanes;
                    JPEG_Image.Blocks_Cb{i,j}(JPEG_Image.Blocks_Cb{i,j} > 2^15-1) = JPEG_Image.Blocks_Cb{i,j}(JPEG_Image.Blocks_Cb{i,j} > 2^(JPEG_Image.Nb_Bitplanes-1)-1) - 2^JPEG_Image.Nb_Bitplanes;
                    JPEG_Image.Blocks_Cr{i,j}(JPEG_Image.Blocks_Cr{i,j} > 2^15-1) = JPEG_Image.Blocks_Cr{i,j}(JPEG_Image.Blocks_Cr{i,j} > 2^(JPEG_Image.Nb_Bitplanes-1)-1) - 2^JPEG_Image.Nb_Bitplanes;
                end
            end
        end
        
        %==================================================================
        % PBC_to_CGC and CGC_to_PBC conversions
        %==================================================================
        function Block_out = PBC_to_CGC(JPEG_Image, Block_in)
            %  Transform the matrix received as argument from PBC system
            %  to CGC system
            %  Input: Block_in is a PBC matrix
            %  Output: Block_out is a CGC matrix
            %
            %  Example : 8 bits system
            %  PBC = [b8 b7 b6 b5 b4 b3 b2 b1]
            %  CGC = [g8 g7 g6 g5 g4 g3 g2 g1]
            %  g1 = b1
            %  g_i = b_i-1 xor b_i
            
            if (strcmp(JPEG_Image.Coeff_type,'int8'))
                Block_out = bitxor(Block_in,(bitor(bitshift(Block_in,-1),bitand(2^7,Block_in))));
            elseif (strcmp(JPEG_Image.Coeff_type,'int16'))
                Block_out = bitxor(Block_in,(bitor(bitshift(Block_in,-1),bitand(2^15,Block_in))));
            end
        end
        
        function Block_out = CGC_to_PBC(JPEG_Image, Block_in)
            if (strcmp(JPEG_Image.Coeff_type,'int8'))
                Block_out = bitand(2^7,Block_in);
                for i=7:-1:1
                    Block_out = bitor(Block_out,bitxor(bitand(Block_in,2.^(i-1)),bitshift(bitand(Block_out,2.^i),-1)));
                end
            elseif (strcmp(JPEG_Image.Coeff_type,'int16'))
                Block_out = bitand(2^15,Block_in);
                for i=15:-1:1
                    Block_out = bitor(Block_out,bitxor(bitand(Block_in,2.^(i-1)),bitshift(bitand(Block_out,2.^i),-1)));
                end
            end
        end
        
        %==================================================================
        % Get Complexity Function
        %==================================================================
        function [alpha, beta, gamma] = Get_Complexity(Bitplane)
            [rows,columns] = size(Bitplane);
            % Max. possible changes in the bitplane
            if (rows == 1)
                max_pos_changes = columns - 1;
            elseif (columns == 1)
                max_pos_changes = rows - 1;
            else
                max_pos_changes = (rows-1)*columns+rows*(columns-1);
            end
            
            %Example - Changes on rows in a 3x3Matrix:
            % 0 0 0 -> 0 changes
            % 0 1 0 -> 2 changes
            % 0 1 1 -> 1 changes
            rows_changes = 0;
            for i= 1:rows
                for j= 2:columns
                    rows_changes = rows_changes + sum((Bitplane(i,j-1) ~= Bitplane(i,j)));
                end
            end
            
            %Changes on column in a 3x3Matrix:
            % 0 0 0
            % 0 1 0
            % 0 1 1
            % | | |
            % | | ----> 0 changes
            % | ------> 1 changes
            % --------> 0 changes
            columns_changes = 0;
            for j= 1:columns
                for i= 2:rows
                    columns_changes = columns_changes + sum((Bitplane(i-1,j) ~= Bitplane(i,j)));
                end
            end
            % Total changes and complexity
            total_changes = rows_changes + columns_changes;
            if (max_pos_changes > 0)
                % This type of complexity is called alpha
                alpha = total_changes/max_pos_changes;
            end
            
            beta=0;
            gamma=0;
        end
    end
    
    % Public methods
    methods (Access=public)
        
        %==================================================================
        % Get Payload Capacity Functions
        %==================================================================
        function Get_Payload_Capacity_BPCS(JPEG_Image)
            threshold_alpha = 0.5;
            
            DCT_Coeff_to_Blocks(JPEG_Image);
            % PBC to CGC conversion
            for i= 1:JPEG_Image.Block_rows
                for j= 1:JPEG_Image.Block_columns
                    JPEG_Image.Blocks_Y{i,j} = PBC_to_CGC(JPEG_Image, JPEG_Image.Blocks_Y{i,j});
                    JPEG_Image.Blocks_Cb{i,j} = PBC_to_CGC(JPEG_Image, JPEG_Image.Blocks_Cb{i,j});
                    JPEG_Image.Blocks_Cr{i,j} = PBC_to_CGC(JPEG_Image, JPEG_Image.Blocks_Cr{i,j});
                end
            end
            % Conversion to bitplanes
            Blocks_to_Bitplanes(JPEG_Image);
            
            % Complexity process (identification of noise areas)
            JPEG_Image.Noise_areas_Y = [];
            JPEG_Image.Noise_areas_Y = [];
            JPEG_Image.Noise_areas_Y = [];
            for i= 1:JPEG_Image.Block_rows
                for j= 1:JPEG_Image.Block_columns
                    for bitplane= 1:JPEG_Image.Nb_Bitplanes
                        [alpha_Y, ~, ~] = Get_Complexity(JPEG_Image.Bitplanes_Y{i,j}(:,:,bitplane));
                        [alpha_Cb, ~, ~] = Get_Complexity(JPEG_Image.Bitplanes_Cb{i,j}(:,:,bitplane));
                        [alpha_Cr, ~, ~] = Get_Complexity(JPEG_Image.Bitplanes_Cr{i,j}(:,:,bitplane));
                        if (alpha_Y >= threshold_alpha)
                            JPEG_Image.Noise_areas_Y = [JPEG_Image.Noise_areas_Y [i j bitplane]'];
                        end
                        if (alpha_Cb >= threshold_alpha)
                            JPEG_Image.Noise_areas_Cb = [JPEG_Image.Noise_areas_Cb [i j bitplane]'];
                        end
                        if (alpha_Cr >= threshold_alpha)
                            JPEG_Image.Noise_areas_Cr = [JPEG_Image.Noise_areas_Cr [i j bitplane]'];
                        end
                    end
                end
            end
            JPEG_Image.Payload_Capacity_BPCS = size(JPEG_Image.Noise_areas_Y,2) + size(JPEG_Image.Noise_areas_Cb,2) + size(JPEG_Image.Noise_areas_Cr,2);
        end
        
        %function Get_Payload_Capacity_LSB(JPEG_Image)
        %end        
    end
end
