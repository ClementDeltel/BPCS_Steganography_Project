classdef JPEGStegoObj < handle
    
    properties (GetAccess=public)
        % Global properties
        readData
        name
        width
        height
        DCTcoefficients
        quantTables
        ACcoefficients
        DCcoefficients
        
        % Blocks fields
        blockRows
        blockColumns
        blocks
        
        % Bitplanes fields
        nbBitplanes=8;
        coeffType='int8';
        bitplanes
        
        % BPCS - Complexity Process
        thresholdAlpha = 0.5;
        noiseAreas
        complexityTab
        countNoiseAreas = 0;
        countNoiseAreasInBytes = 0;
        payloadCapacityBPCS = 0;
        
        % Advanced BPCS
%         thresholdBeta = 0;
%         thresholdGamma = 0;
%         payloadCapacityAdvancedBPCS = 0;
        
        % LSB
        LSBAreas
        countLSBAreas = 0;
        countLSBAreasInBytes = 0;
        payloadCapacityLSB = 0;
        
        % Steganalysis
        Peak_SNR = 0;
        SNR = 0;
        MSE = 0;
        SSIMVal = 0;
        SSIMMap
        
    end
    
    % Supposed to be private methods in a final implementation
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function JPEGImage=JPEGStegoObj(image)
            readData=jpeg_read(image);
            [~,name,ext] = fileparts(image);
            
            if (strcmp(ext,'.jpg'))
                % Initialization of class fields thanks to the jpeg_read above
                JPEGImage.readData =         readData;
                JPEGImage.name =             name;
                JPEGImage.width =            readData.image_width;
                JPEGImage.height =           readData.image_height;
                JPEGImage.DCTcoefficients =  readData.coef_arrays;
                
                JPEGImage.quantTables =      readData.quant_tables;
                JPEGImage.ACcoefficients =   readData.ac_huff_tables;
                JPEGImage.DCcoefficients =   readData.dc_huff_tables;
                
                % Blocks matrix initialization
                JPEGImage.blockRows =        size(JPEGImage.DCTcoefficients{1},1)/8;
                JPEGImage.blockColumns =     size(JPEGImage.DCTcoefficients{1},2)/8;
                JPEGImage.blocks = zeros(1, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8);
            end
        end
        
        %==================================================================
        % DCT Coefficients to Blocks and vice versa
        %==================================================================
        function DCT_Coeff_to_Blocks(JPEGImage)
            for channel= 1
                % Y Channel only
                % permute function necessary to have data in the 5 dimensions matrix in the following order: channel, blockRow, blockColumn, row, column.
                JPEGImage.blocks(channel,:, :, :, :) = permute(reshape(JPEGImage.DCTcoefficients{channel}, 1, 8, JPEGImage.blockRows, 8, JPEGImage.blockColumns),[1 3 5 2 4]);
            end
        end
        
        function Blocks_to_DCT_Coeff(JPEGImage)
            for channel= 1
                % Y Channel only
                % permute function necessary to have data in the 5 dimensions matrix in the right order for reconstruction of the image.
                JPEGImage.DCTcoefficients{channel} = reshape(permute(JPEGImage.blocks(channel,:,:,:,:),[1 4 2 5 3]),size(JPEGImage.DCTcoefficients{channel}));
            end
        end
        
        %==================================================================
        % Blocks to bitplanes and vice versa
        %==================================================================
        function Blocks_to_Bitplanes(JPEGImage)
            % How many bitplanes do we need?
            JPEGImage.bitplanes = zeros(1, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8, JPEGImage.nbBitplanes);
            % Find the max value in the DCTcoefficients
            if max(abs(JPEGImage.DCTcoefficients{1}(:))) > 2^7
                JPEGImage.nbBitplanes = 16;
                JPEGImage.coeffType = 'int16';
            end
            
            % The loop is used to build the bitplanes
            for bitplane=1:JPEGImage.nbBitplanes
                for channel= 1
                    % Y Channel only
                    % 6 dimensions matrix now: channel, blockRow, blockColumn, row, column, and bitplane.
                    JPEGImage.bitplanes(channel, :, :, :, :, bitplane) = bitget(JPEGImage.blocks(channel, :, :, :, :), JPEGImage.nbBitplanes-bitplane+1, JPEGImage.coeffType);
                end
            end
        end
        
        function Bitplanes_to_Blocks(JPEGImage)
            % Blocks matrix initialization
            JPEGImage.blocks = zeros(1, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8);
            for bitplane= 1:JPEGImage.nbBitplanes
                for channel= 1
                    % Y Chanel only
                    JPEGImage.blocks(channel, :, :, :, :) = JPEGImage.blocks(channel, :, :, :, :) + bitshift(JPEGImage.bitplanes(channel, :, :, :, :, bitplane), JPEGImage.nbBitplanes-bitplane);
                end
            end
            JPEGImage.blocks(JPEGImage.blocks > 2^(JPEGImage.nbBitplanes-1)-1) = JPEGImage.blocks(JPEGImage.blocks > 2^(JPEGImage.nbBitplanes-1)-1) - 2^JPEGImage.nbBitplanes;
        end
        
        %==================================================================
        % PBC_to_CGC and CGC_to_PBC conversions
        %==================================================================
        function PBC_to_CGC(JPEGImage)
            %  Transform the matrix received as argument from PBC system
            %  to CGC system
            %
            %  Example : 8 bits system
            %  PBC = [b8 b7 b6 b5 b4 b3 b2 b1]
            %  CGC = [g8 g7 g6 g5 g4 g3 g2 g1]
            %  g1 = b1
            %  g_i = b_i-1 xor b_i
           
           
            % Under development, this function does not work.
        end
        
        function CGC_to_PBC(JPEGImage)
            
            % Under development, this function does not work.
            
        end
    end
    
    % Public methods
    methods (Access=public)
        
        %==================================================================
        % Image Initialization Function
        %==================================================================
        function Init_Image(JPEGImage)
            % PBC to CGC conversion
%             PBC_to_CGC(JPEG_Image);
            
            % Conversion to Blocks
            DCT_Coeff_to_Blocks(JPEGImage);
            
            % Conversion to bitplanes
            Blocks_to_Bitplanes(JPEGImage);
        end
        
        %==================================================================
        % Get Payload Capacity Functions
        %==================================================================
        
        function Get_Payload_Capacity_BPCS(JPEGImage)
            % Complexity process (identification of noise areas)
            JPEGImage.noiseAreas = [];
            JPEGImage.complexityTab = [];
            count = 0;
            for channel= 1:1
                for i= 1:JPEGImage.blockRows
                    for j= 1:JPEGImage.blockColumns
                        % Read the bitplanes and as a consequence hide data into bitplanes numbers 16 to 11
                        for bitplane= JPEGImage.nbBitplanes:-1:11
                            complexity = Get_Complexity(squeeze(JPEGImage.bitplanes(channel, i, j, :, :, bitplane)));
                            JPEGImage.complexityTab = [JPEGImage.complexityTab complexity];
                            % If the bitplane is a noise area, we store its position
                            if (complexity >= JPEGImage.thresholdAlpha)
                                JPEGImage.noiseAreas = [JPEGImage.noiseAreas [channel i j bitplane]'];
                                count = count +1;
                                % Limit to replace a maximum of 2 bitplanes per block
                                if (count >= 2)
                                    count = 0;
                                    break
                                end
                            end
                        end
                    end
                end
            end
            JPEGImage.countNoiseAreas = size(JPEGImage.noiseAreas,2);
            JPEGImage.countNoiseAreasInBytes = 7/2 * JPEGImage.countNoiseAreas;
            % Multiply by 3 the denominator if you want to use the 3 channels to hide data
            JPEGImage.payloadCapacityBPCS = JPEGImage.countNoiseAreas / (JPEGImage.blockRows * JPEGImage.blockColumns * JPEGImage.nbBitplanes);
        end
        
%         function Get_Payload_Capacity_Advanced_BPCS(JPEGImage)
%         end
        
        function Get_Payload_Capacity_LSB(JPEGImage)
            
            JPEGImage.LSBAreas = [];
            for channel= 1
                for i= 1:JPEGImage.blockRows
                    for j= 1:JPEGImage.blockColumns
                        JPEGImage.LSBAreas = [JPEGImage.LSBAreas [channel i j 16]'];
                    end
                end
            end
            JPEGImage.countLSBAreas = size(JPEGImage.LSBAreas,2);
            JPEGImage.countLSBAreasInBytes = 7/2 * JPEGImage.countLSBAreas;
            % Multiply by 3  the denominator if you want to use the 3 channels to hide data
            JPEGImage.payloadCapacityLSB = JPEGImage.countLSBAreas / (JPEGImage.blockRows * JPEGImage.blockColumns * JPEGImage.nbBitplanes);
        end
        
        %==================================================================
        % Embedding algorithms
        %==================================================================
        function Apply_BPCS(JPEGImage, SecretData)
            Init_Image(JPEGImage);
            Get_Payload_Capacity_BPCS(JPEGImage);
            
            % Embedding process
            EmbeddedData = EmbeddedObj(SecretData);
            Data_to_Blockstream(EmbeddedData);
            
            for index= 1:size(EmbeddedData.blockStream,3)
                area = JPEGImage.noiseAreas(:,index);
                % Replace some bitplanes with the textfile
                JPEGImage.bitplanes(area(1), area(2), area(3), 2:8, :, area(4)) = EmbeddedData.blockStream(:, :, index);
            end
            
            % Blocks rebuilding
            Bitplanes_to_Blocks(JPEGImage);
            
            % DCT Coefficients rebuilding
            Blocks_to_DCT_Coeff(JPEGImage);
            
            % CGC to PBC conversion
%             CGC_to_PBC(JPEG_Image);
            
            % JPEG New image generation
            JPEGImage.readData.coef_arrays = JPEGImage.DCTcoefficients;
            jpeg_write(JPEGImage.readData,strcat(JPEGImage.name,'-embedded-BPCS.jpg'));
            
            % PSNR
            PSNR_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-BPCS.jpg'));
            % MSE
            MSE_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-BPCS.jpg'));
            % SSIM
            SSIM_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-BPCS.jpg'));
        end
        
%         function Apply_Advanced_BPCS(JPEGImage, SecretData)
%         end
        
        function Apply_LSB(JPEGImage, SecretData)
             Init_Image(JPEGImage);
             Get_Payload_Capacity_LSB(JPEGImage);
            
            % Embedding process
            EmbeddedData = EmbeddedObj(SecretData);
            Data_to_Blockstream(EmbeddedData);
            
            for index= 1:size(EmbeddedData.blockStream,3)
                area = JPEGImage.LSBAreas(:,index);
                JPEGImage.bitplanes(area(1), area(2), area(3), 2:8, :, area(4)) = EmbeddedData.blockStream(:, :, index);
            end
            
            % Blocks rebuilding
            Bitplanes_to_Blocks(JPEGImage);
            
            % DCT Coefficients rebuilding
            Blocks_to_DCT_Coeff(JPEGImage);
            
            % JPEG New image generation
            JPEGImage.readData.coef_arrays = JPEGImage.DCTcoefficients;
            jpeg_write(JPEGImage.readData,strcat(JPEGImage.name,'-embedded-LSB.jpg'));
            
            % PSNR
            PSNR_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-LSB.jpg'));
            % MSE
            MSE_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-LSB.jpg'));
            % SSIM
            SSIM_Result(JPEGImage, strcat(JPEGImage.name,'.jpg'), strcat(JPEGImage.name,'-embedded-LSB.jpg'));
        end
        
        %==================================================================
        % Retrieving processes
        %==================================================================
        function Retrieve_Data_from_BPCS(JPEGImage)
            Init_Image(JPEGImage);
            Get_Payload_Capacity_BPCS(JPEGImage);
            
            % Creation of an empty textfile
            EmbeddedData = EmbeddedObj('secret-message-BPCS.txt');
            
            for index= 1:size(JPEGImage.noiseAreas,2)
                area = JPEGImage.noiseAreas(:,index);
                 % Retrieving the bitplanes with the hidden textfile
                EmbeddedData.blockStream(:,:,index) = JPEGImage.bitplanes(area(1),area(2),area(3),2:8,:,area(4));
            end
            
            Block_Stream_to_Data(EmbeddedData);
        end
        
%         function Retrieve_Data_from_Advanced_BPCS(JPEGImage)
%         end
%         
        function Retrieve_Data_from_LSB(JPEGImage)
            Init_Image(JPEGImage);
            Get_Payload_Capacity_LSB(JPEGImage);
            
            % Creation of an empty textfile
            EmbeddedData = EmbeddedObj('secret-message-LSB.txt');
            
            for index= 1:size(JPEGImage.LSBAreas,2)
                area = JPEGImage.LSBAreas(:,index);
                % Retrieving the bitplanes with the hidden textfile
                EmbeddedData.blockStream(:,:,index) = JPEGImage.bitplanes(area(1),area(2),area(3),2:8,:,area(4));
            end
            
            Block_Stream_to_Data(EmbeddedData);
        end
        
        %==================================================================
        % Steganalysis
        %==================================================================        
        function Complexity_Histogram(JPEGImage)
            figure('Name','Histogram')
            histogram(JPEGImage.complexityTab, 'BinLimits', [0,1]);
        end
        
        function PSNR_Result(JPEGImage, imageStart, imageEnd)
            ref = imread(imageStart);
            A = imread(imageEnd);
            [JPEGImage.Peak_SNR, JPEGImage.SNR] = psnr(A, ref);
        end
        
        function MSE_Result(JPEGImage, imageStart, imageEnd)
            ref = imread(imageStart);
            A = imread(imageEnd);
            JPEGImage.MSE = immse(A, ref);
        end
        
        function SSIM_Result(JPEGImage, imageStart, imageEnd)
            ref = imread(imageStart);
            A = imread(imageEnd);
            [JPEGImage.SSIMVal, JPEGImage.SSIMMap] = ssim(A, ref);
        end          
    end
end
