classdef JPEG_Obj_v2 < handle
    
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
        Blocks
        
        %Bitplanes fields
        Nb_Bitplanes=8;
        Coeff_type='int8';
        Bitplanes
        
        %Complexity Process
        threshold_alpha = 0.5;
        Noise_areas
        Count_Noise_areas = 0;
        
        Payload_Capacity_LSB = 0;
        Payload_Capacity_BPCS = 0;
    end
    
    % Private methods
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function JPEG_Image=JPEG_Obj_v2(Image)
            Read_Data=jpeg_read(Image);
            [~,Name,Ext] = fileparts(Image);
            
            if (strcmp(Ext,'.jpg'))
                % Initialization of class fileds
                JPEG_Image.Name =              Name;
                JPEG_Image.Width =             Read_Data.image_width;
                JPEG_Image.Height =            Read_Data.image_height;
                JPEG_Image.DCT_Coefficients =  Read_Data.coef_arrays;
                
                JPEG_Image.Quant_Tables =      Read_Data.quant_tables;
                JPEG_Image.AC_Coefficients =   Read_Data.ac_huff_tables;
                JPEG_Image.DC_Coefficients =   Read_Data.dc_huff_tables;
                
                % Blocks matrix initialization
                JPEG_Image.Block_rows =        size(JPEG_Image.DCT_Coefficients{1},1)/8;
                JPEG_Image.Block_columns =     size(JPEG_Image.DCT_Coefficients{1},2)/8;
                JPEG_Image.Blocks = zeros(3, JPEG_Image.Block_rows, JPEG_Image.Block_columns, 8, 8);
            end
        end
        
        %==================================================================
        % DCT Coefficients to Blocks and vice versa
        %==================================================================
        function DCT_Coeff_to_Blocks(JPEG_Image)
            % Y Channel
            JPEG_Image.Blocks(1,:, :, :, :) = permute(reshape(JPEG_Image.DCT_Coefficients{1}, 1, 8, JPEG_Image.Block_rows, 8, JPEG_Image.Block_columns),[1 3 5 2 4]);
            % Cb Channel
            JPEG_Image.Blocks(2,:, :, :, :) = permute(reshape(JPEG_Image.DCT_Coefficients{2}, 1, 8, JPEG_Image.Block_rows, 8, JPEG_Image.Block_columns),[1 3 5 2 4]);
            % Cr Channel
            JPEG_Image.Blocks(3,:, :, :, :) = permute(reshape(JPEG_Image.DCT_Coefficients{3}, 1, 8, JPEG_Image.Block_rows, 8, JPEG_Image.Block_columns),[1 3 5 2 4]);
        end
        
        function Blocks_to_DCT_Coeff(JPEG_Image)
            % Y Channel
            JPEG_Image.DCT_Coefficients{1} = reshape(permute(JPEG_Image.Blocks(1,:,:,:,:),[1 4 2 5 3]),size(JPEG_Image.DCT_Coefficients{1}));
            % Cb Channel
            JPEG_Image.DCT_Coefficients{2} = reshape(permute(JPEG_Image.Blocks(2,:,:,:,:),[1 4 2 5 3]),size(JPEG_Image.DCT_Coefficients{1}));
            % Cr Channel
            JPEG_Image.DCT_Coefficients{3} = reshape(permute(JPEG_Image.Blocks(3,:,:,:,:),[1 4 2 5 3]),size(JPEG_Image.DCT_Coefficients{1}));
        end
        
        %==================================================================
        % Blocks to bitplanes and vice versa
        %==================================================================
        function Blocks_to_Bitplanes(JPEG_Image)
            % How many bitplanes do we need?
            JPEG_Image.Bitplanes = zeros(3, JPEG_Image.Block_rows, JPEG_Image.Block_columns, 8, 8, JPEG_Image.Nb_Bitplanes);
            Pow=[8 16];
            for p = Pow
                % Find the max value in the DCT_Coefficients
                if max(abs(JPEG_Image.DCT_Coefficients{1}(:))) > 2^p
                    JPEG_Image.Nb_Bitplanes = p*2;
                    JPEG_Image.Coeff_type = 'int16';
                end
            end
            
            %The loop is used to build the bitplanes
            for bitplane=1:JPEG_Image.Nb_Bitplanes
                % Y Channel
                JPEG_Image.Bitplanes(1, :, :, :, :, bitplane) = bitget(JPEG_Image.Blocks(1, :, :, :, :), JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
                % Cb Channel
                JPEG_Image.Bitplanes(2, :, :, :, :, bitplane) = bitget(JPEG_Image.Blocks(2, :, :, :, :), JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
                % Cr Channel
                JPEG_Image.Bitplanes(3, :, :, :, :, bitplane) = bitget(JPEG_Image.Blocks(3, :, :, :, :), JPEG_Image.Nb_Bitplanes-bitplane+1, JPEG_Image.Coeff_type);
            end
        end
        
        function Bitplanes_to_Blocks(JPEG_Image)
            % Blocks matrix initialization
            JPEG_Image.Blocks = zeros(3, JPEG_Image.Block_rows, JPEG_Image.Block_columns, 8, 8);
            for bitplane= 1:JPEG_Image.Nb_Bitplanes
                % Y Chanel
                JPEG_Image.Blocks(1, :, :, :, :) = JPEG_Image.Blocks(1, :, :, :, :) + bitshift(JPEG_Image.Bitplanes(1, :, :, :, :, bitplane), JPEG_Image.Nb_Bitplanes-bitplane);
                % Cb Channel
                JPEG_Image.Blocks(2, :, :, :, :) = JPEG_Image.Blocks(2, :, :, :, :) + bitshift(JPEG_Image.Bitplanes(2, :, :, :, :, bitplane), JPEG_Image.Nb_Bitplanes-bitplane);
                % Cr Channel
                JPEG_Image.Blocks(3, :, :, :, :) = JPEG_Image.Blocks(3, :, :, :, :) + bitshift(JPEG_Image.Bitplanes(3, :, :, :, :, bitplane), JPEG_Image.Nb_Bitplanes-bitplane);
            end
            JPEG_Image.Blocks(JPEG_Image.Blocks > 2^(JPEG_Image.Nb_Bitplanes-1)-1) = JPEG_Image.Blocks(JPEG_Image.Blocks > 2^(JPEG_Image.Nb_Bitplanes-1)-1) - 2^JPEG_Image.Nb_Bitplanes;
        end
        
        %==================================================================
        % PBC_to_CGC and CGC_to_PBC conversions
        %==================================================================
        function PBC_to_CGC(JPEG_Image)
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
            
%             Pow=[8 16];
%             for p = Pow
%                 % Find the max value in the DCT_Coefficients
%                 if max(abs(JPEG_Image.DCT_Coefficients{1}(:))) > 2^p
%                     JPEG_Image.Nb_Bitplanes = p*2;
%                     JPEG_Image.Coeff_type = 'int16';
%                 end
%             end
            
            min1 = abs(min(JPEG_Image.DCT_Coefficients{1}(:)));
            min2 = abs(min(JPEG_Image.DCT_Coefficients{2}(:)));
            min3 = abs(min(JPEG_Image.DCT_Coefficients{3}(:)));
            
            JPEG_Image.DCT_Coefficients{1}(:) = JPEG_Image.DCT_Coefficients{1}(:) + min1;
            JPEG_Image.DCT_Coefficients{2}(:) = JPEG_Image.DCT_Coefficients{2}(:) + min2;
            JPEG_Image.DCT_Coefficients{3}(:) = JPEG_Image.DCT_Coefficients{3}(:) + min3;
            
            for i= 1:size(JPEG_Image.DCT_Coefficients{1},1)
                for j= 1:size(JPEG_Image.DCT_Coefficients{1},2)
                    % Channel Y
                    JPEG_Image.DCT_Coefficients{1}(i,j) = bitxor(JPEG_Image.DCT_Coefficients{1}(i,j),(bitor(bitshift(JPEG_Image.DCT_Coefficients{1}(i,j),-1),bitand(2^(JPEG_Image.Nb_Bitplanes-1),JPEG_Image.DCT_Coefficients{1}(i,j)))));
                    %Channel Cb
                    JPEG_Image.DCT_Coefficients{2}(i,j) = bitxor(JPEG_Image.DCT_Coefficients{2}(i,j),(bitor(bitshift(JPEG_Image.DCT_Coefficients{2}(i,j),-1),bitand(2^(JPEG_Image.Nb_Bitplanes-1),JPEG_Image.DCT_Coefficients{2}(i,j)))));
                    % Channel Cr
                    JPEG_Image.DCT_Coefficients{3}(i,j) = bitxor(JPEG_Image.DCT_Coefficients{3}(i,j),(bitor(bitshift(JPEG_Image.DCT_Coefficients{3}(i,j),-1),bitand(2^(JPEG_Image.Nb_Bitplanes-1),JPEG_Image.DCT_Coefficients{3}(i,j)))));
                end
            end            
            JPEG_Image.DCT_Coefficients{1}(:) = JPEG_Image.DCT_Coefficients{1}(:) - min1;
            JPEG_Image.DCT_Coefficients{2}(:) = JPEG_Image.DCT_Coefficients{2}(:) - min2;
            JPEG_Image.DCT_Coefficients{3}(:) = JPEG_Image.DCT_Coefficients{3}(:) - min3;
        end
        
        
        %function CGC_to_PBC(JPEG_Image)
        %end
        
        %==================================================================
        % Get Complexity Function
        %==================================================================
%         function complexity = Get_Complexity(Bitplane)
%             [rows,columns] = size(Bitplane);
%             % Max. possible changes in the bitplane
%             if (rows == 1)
%                 max_pos_changes = columns - 1;
%             elseif (columns == 1)
%                 max_pos_changes = rows - 1;
%             else
%                 max_pos_changes = (rows-1)*columns+rows*(columns-1);
%             end
%             
%             %Example - Changes on rows in a 3x3Matrix:
%             % 0 0 0 -> 0 changes
%             % 0 1 0 -> 2 changes
%             % 0 1 1 -> 1 changes
%             rows_changes = 0;
%             for i= 1:rows
%                 for j= 2:columns
%                     rows_changes = rows_changes + sum((Bitplane(i,j-1) ~= Bitplane(i,j)));
%                 end
%             end
%             
%             %Changes on column in a 3x3Matrix:
%             % 0 0 0
%             % 0 1 0
%             % 0 1 1
%             % | | |
%             % | | ----> 0 changes
%             % | ------> 1 changes
%             % --------> 0 changes
%             columns_changes = 0;
%             for j= 1:columns
%                 for i= 2:rows
%                     columns_changes = columns_changes + sum((Bitplane(i-1,j) ~= Bitplane(i,j)));
%                 end
%             end
%             % Total changes and complexity
%             total_changes = rows_changes + columns_changes;
%             if (max_pos_changes > 0)
%                 % This type of complexity is called alpha
%                 alpha = total_changes/max_pos_changes;
%             end
%             
%             %             beta=0;
%             %             gamma=0;
%             complexity = alpha;
%         end
     end
    
    % Public methods
    methods (Access=public)
        
        %==================================================================
        % Get Payload Capacity Functions
        %==================================================================
        function Get_Payload_Capacity_BPCS(JPEG_Image)
            
            % PBC to CGC conversion
            % PBC_to_CGC(JPEG_Image);
            
            % Conversion to Blocks
            DCT_Coeff_to_Blocks(JPEG_Image);
            
            % Conversion to bitplanes
            Blocks_to_Bitplanes(JPEG_Image);
            
            % Complexity process (identification of noise areas)
%             complexity_tab= [];
            JPEG_Image.Noise_areas = [];
            for channel= 1:3
                for i= 1:JPEG_Image.Block_rows
                    for j= 1:JPEG_Image.Block_columns
                        for bitplane= JPEG_Image.Nb_Bitplanes:-1:1
                            complexity =  Get_Complexity(squeeze(JPEG_Image.Bitplanes(channel, i, j, :, :, bitplane)));
%                             complexity_tab = [complexity_tab complexity];
                            % If the bitplane is a noise area, we store its position
                            if (complexity >= JPEG_Image.threshold_alpha)
                                JPEG_Image.Noise_areas = [JPEG_Image.Noise_areas [channel i j bitplane]'];
                                break
                            end
                        end
                    end
                end
            end
%             histogram(complexity_tab);
            JPEG_Image.Count_Noise_areas = size(JPEG_Image.Noise_areas,2);
            JPEG_Image.Payload_Capacity_BPCS = JPEG_Image.Count_Noise_areas / (3 * JPEG_Image.Block_rows * JPEG_Image.Block_columns * JPEG_Image.Nb_Bitplanes);
        end
        
        %function Get_Payload_Capacity_LSB(JPEG_Image)
        %end
        
        %==================================================================
        % Display an image in CGC
        %==================================================================
        function Display_CGC(Image_Data, JPEG_Image)
            PBC_to_CGC(JPEG_Image);
            Image_Data.coef_arrays = JPEG_Image.DCT_Coefficients;
            jpeg_write(Image_Data,'house-cgc3.jpg');
        end
        
        %==================================================================
        % Embedding algorithms
        %==================================================================
        function ApplyBPCS(Image_Data, JPEG_Image, Secret_Data)
            
            Get_Payload_Capacity_BPCS(JPEG_Image);
            %----------------------------------
            % Embedding process
            %----------------------------------
            Embedded_Data = Embedded_Obj(Secret_Data);
            Data_to_Block_Stream(Embedded_Data);
            
            for index= 1:size(Embedded_Data.Block_Stream,3)
                area = JPEG_Image.Noise_areas(:,index);
                JPEG_Image.Bitplanes(area(1), area(2), area(3), 2:8, :, area(4)) = Embedded_Data.Block_Stream(:, :, index);
            end
            
            % Blocks rebuilding
            Bitplanes_to_Blocks(JPEG_Image);
            
            %a = JPEG_Image.DCT_Coefficients{1};
            
            %DCT Coefficients rebuilding
            Blocks_to_DCT_Coeff(JPEG_Image);
            
            %b = JPEG_Image.DCT_Coefficients{1};
            
            %JPEG Writing
            Image_Data.coef_arrays = JPEG_Image.DCT_Coefficients;
            jpeg_write(Image_Data,strcat(JPEG_Image.Name,'-embedded.jpg'));
        end
        
        %function ApplyLSB(JPEG_Image, Secret_Data)
        %end
        
        %==================================================================
        % Retrieving processes
        %==================================================================
    end
end