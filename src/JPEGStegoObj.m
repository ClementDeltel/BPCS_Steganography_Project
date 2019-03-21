classdef JPEGStegoObj < handle
    
    properties (GetAccess=public)
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
        payloadCapacityAdvancedBPCS = 0;
        
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
    
    % Private methods
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function JPEGImage=JPEGStegoObj(image)
            readData=jpeg_read(image);
            [~,name,ext] = fileparts(image);
            
            if (strcmp(ext,'.jpg'))
                % Initialization of class fileds
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
                JPEGImage.blocks = zeros(3, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8);
            end
        end
        
        %==================================================================
        % DCT Coefficients to Blocks and vice versa
        %==================================================================
        function DCT_Coeff_to_Blocks(JPEGImage)
            % Y Channel
            JPEGImage.blocks(1,:, :, :, :) = permute(reshape(JPEGImage.DCTcoefficients{1}, 1, 8, JPEGImage.blockRows, 8, JPEGImage.blockColumns),[1 3 5 2 4]);
            % Cb Channel
            JPEGImage.blocks(2,:, :, :, :) = permute(reshape(JPEGImage.DCTcoefficients{2}, 1, 8, JPEGImage.blockRows, 8, JPEGImage.blockColumns),[1 3 5 2 4]);
            % Cr Channel
            JPEGImage.blocks(3,:, :, :, :) = permute(reshape(JPEGImage.DCTcoefficients{3}, 1, 8, JPEGImage.blockRows, 8, JPEGImage.blockColumns),[1 3 5 2 4]);
        end
        
        function Blocks_to_DCT_Coeff(JPEGImage)
            % Y Channel
            JPEGImage.DCTcoefficients{1} = reshape(permute(JPEGImage.blocks(1,:,:,:,:),[1 4 2 5 3]),size(JPEGImage.DCTcoefficients{1}));
            % Cb Channel
            JPEGImage.DCTcoefficients{2} = reshape(permute(JPEGImage.blocks(2,:,:,:,:),[1 4 2 5 3]),size(JPEGImage.DCTcoefficients{1}));
            % Cr Channel
            JPEGImage.DCTcoefficients{3} = reshape(permute(JPEGImage.blocks(3,:,:,:,:),[1 4 2 5 3]),size(JPEGImage.DCTcoefficients{1}));
        end
        
        %==================================================================
        % Blocks to bitplanes and vice versa
        %==================================================================
        function Blocks_to_Bitplanes(JPEGImage)
            % How many bitplanes do we need?
            JPEGImage.bitplanes = zeros(3, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8, JPEGImage.nbBitplanes);
            pow=[8 16];
            for p = pow
                % Find the max value in the DCTcoefficients
                if max(abs(JPEGImage.DCTcoefficients{1}(:))) > 2^p
                    JPEGImage.nbBitplanes = p*2;
                    JPEGImage.coeffType = 'int16';
                end
            end
            
            % The loop is used to build the bitplanes
            for bitplane=1:JPEGImage.nbBitplanes
                % Y Channel
                JPEGImage.bitplanes(1, :, :, :, :, bitplane) = bitget(JPEGImage.blocks(1, :, :, :, :), JPEGImage.nbBitplanes-bitplane+1, JPEGImage.coeffType);
                % Cb Channel
                JPEGImage.bitplanes(2, :, :, :, :, bitplane) = bitget(JPEGImage.blocks(2, :, :, :, :), JPEGImage.nbBitplanes-bitplane+1, JPEGImage.coeffType);
                % Cr Channel
                JPEGImage.bitplanes(3, :, :, :, :, bitplane) = bitget(JPEGImage.blocks(3, :, :, :, :), JPEGImage.nbBitplanes-bitplane+1, JPEGImage.coeffType);
            end
        end
        
        function Bitplanes_to_Blocks(JPEGImage)
            % Blocks matrix initialization
            JPEGImage.blocks = zeros(3, JPEGImage.blockRows, JPEGImage.blockColumns, 8, 8);
            for bitplane= 1:JPEGImage.nbBitplanes
                % Y Chanel
                JPEGImage.blocks(1, :, :, :, :) = JPEGImage.blocks(1, :, :, :, :) + bitshift(JPEGImage.bitplanes(1, :, :, :, :, bitplane), JPEGImage.nbBitplanes-bitplane);
                % Cb Channel
                JPEGImage.blocks(2, :, :, :, :) = JPEGImage.blocks(2, :, :, :, :) + bitshift(JPEGImage.bitplanes(2, :, :, :, :, bitplane), JPEGImage.nbBitplanes-bitplane);
                % Cr Channel
                JPEGImage.blocks(3, :, :, :, :) = JPEGImage.blocks(3, :, :, :, :) + bitshift(JPEGImage.bitplanes(3, :, :, :, :, bitplane), JPEGImage.nbBitplanes-bitplane);
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
            
            JPEGProcess = JPEGPRocessObj(JPEGImage.DCTcoefficients, JPEGImage.quantTables);
            Decompressor_JPEG(JPEGProcess);
            
            JPEGProcess.R = bitxor(JPEGProcess.R,(bitor(bitshift(JPEGProcess.R,-1),bitand(2^7,JPEGProcess.R))));
            JPEGProcess.G = bitxor(JPEGProcess.G,(bitor(bitshift(JPEGProcess.G,-1),bitand(2^7,JPEGProcess.G))));
            JPEGProcess.B = bitxor(JPEGProcess.B,(bitor(bitshift(JPEGProcess.B,-1),bitand(2^7,JPEGProcess.B))));
            
            Compressor_JPEG(JPEGProcess);
            JPEGImage.DCTcoefficients = JPEGProcess.DCTcoefficients;
            
        end
        
        function CGC_to_PBC(JPEGImage)
            
            JPEGProcess = JPEGPRocessObj(JPEGImage.DCTcoefficients, JPEGImage.quantTables);
            Decompressor_JPEG(JPEGProcess);
            
            JPEGProcess.R = bitor(JPEGProcess.PBCr,bitxor(bitand(JPEGProcess.R,2.^(7-1)),bitshift(bitand(JPEGProcess.PBCr,2.^7),-1)));
            JPEGProcess.G = bitor(JPEGProcess.PBCg,bitxor(bitand(JPEGProcess.G,2.^(7-1)),bitshift(bitand(JPEGProcess.PBCg,2.^7),-1)));
            JPEGProcess.B = bitor(JPEGProcess.PBCb,bitxor(bitand(JPEGProcess.B,2.^(7-1)),bitshift(bitand(JPEGProcess.PBCr,2.^7),-1)));
            
            Compressor_JPEG(JPEGProcess);
            JPEGImage.DCTcoefficients = JPEGProcess.DCTcoefficients;
            
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
            for channel= 1:3
                for i= 1:JPEGImage.blockRows
                    for j= 1:JPEGImage.blockColumns
                        for bitplane= JPEGImage.nbBitplanes:-1:8
                            complexity = Get_Complexity(squeeze(JPEGImage.bitplanes(channel, i, j, :, :, bitplane)));
                            JPEGImage.complexityTab = [JPEGImage.complexityTab complexity];
                            % If the bitplane is a noise area, we store its position
                            if (complexity >= JPEGImage.thresholdAlpha)
                                JPEGImage.noiseAreas = [JPEGImage.noiseAreas [channel i j bitplane]'];
                                count = count +1;
                                if (count >= 1)
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
            JPEGImage.payloadCapacityBPCS = JPEGImage.countNoiseAreas / (3 * JPEGImage.blockRows * JPEGImage.blockColumns * JPEGImage.nbBitplanes);
        end
        
%         function Get_Payload_Capacity_Advanced_BPCS(JPEGImage)
%         end
        
        function Get_Payload_Capacity_LSB(JPEGImage)
            
            JPEGImage.LSBAreas = [];
            for channel= 1:3
                for i= 1:JPEGImage.blockRows
                    for j= 1:JPEGImage.blockColumns
                        JPEGImage.LSBAreas = [JPEGImage.LSBAreas [channel i j 16]'];
                    end
                end
            end
            JPEGImage.countLSBAreas = size(JPEGImage.LSBAreas,2);
            JPEGImage.countLSBAreasInBytes = 7/2 * JPEGImage.countLSBAreas;
            JPEGImage.payloadCapacityLSB = JPEGImage.countLSBAreas / (3 * JPEGImage.blockRows * JPEGImage.blockColumns * JPEGImage.nbBitplanes);
        end
        
        %==================================================================
        % Display an image in CGC
        %==================================================================
        function Display_CGC(ImageData, JPEGImage)
            PBC_to_CGC(JPEGImage);
            ImageData.coef_arrays = JPEGImage.DCTcoefficients;
            jpeg_write(ImageData,strcat(JPEGImage.name,'-cgc.jpg'));
        end
        
        %==================================================================
        % Embedding algorithms
        %==================================================================
        function Apply_BPCS(JPEGImage, SecretData)
            Init_Image(JPEGImage);
            Get_Payload_Capacity_BPCS(JPEGImage);
            
            %----------------------------------
            % Embedding process
            %----------------------------------
            EmbeddedData = EmbeddedObj(SecretData);
            Data_to_Blockstream(EmbeddedData);
            
            for index= 1:size(EmbeddedData.blockStream,3)
                area = JPEGImage.noiseAreas(:,index);
                JPEGImage.bitplanes(area(1), area(2), area(3), 2:8, :, area(4)) = EmbeddedData.blockStream(:, :, index);
            end
            
            % Blocks rebuilding
            Bitplanes_to_Blocks(JPEGImage);
%             test1 = JPEG_Image.DCTcoefficients{1};
            
            % DCT Coefficients rebuilding
            Blocks_to_DCT_Coeff(JPEGImage);
%             test2 = JPEG_Image.DCTcoefficients{1};
            
            % CGC to PBC conversion
%             CGC_to_PBC(JPEG_Image);
            
            % JPEG Writing
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
            
            %----------------------------------
            % Embedding process
            %----------------------------------
            EmbeddedData = EmbeddedObj(SecretData);
            Data_to_Blockstream(EmbeddedData);
            for index= 1:size(EmbeddedData.blockStream,3)
                area = JPEGImage.LSBAreas(:,index);
                JPEGImage.bitplanes(area(1), area(2), area(3), 2:8, :, area(4)) = EmbeddedData.blockStream(:, :, index);
            end
            
            % Blocks rebuilding
            Bitplanes_to_Blocks(JPEGImage);
%             test1 = JPEG_Image.DCTcoefficients{1};
            
            % DCT Coefficients rebuilding
            Blocks_to_DCT_Coeff(JPEGImage);
%             test2 = JPEG_Image.DCTcoefficients{1};
            
            % JPEG Writing
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
            
            EmbeddedData = EmbeddedObj('secret-message-BPCS.txt');
            
            for index= 1:size(JPEGImage.noiseAreas,2)
                area = JPEGImage.noiseAreas(:,index);
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
            
            EmbeddedData = EmbeddedObj('secret-message-LSB.txt');
            
            for index= 1:size(JPEGImage.LSBAreas,2)
                area = JPEGImage.LSBAreas(:,index);
                EmbeddedData.blockStream(:,:,index) = JPEGImage.bitplanes(area(1),area(2),area(3),2:8,:,area(4));
            end
            
            Block_Stream_to_Data(EmbeddedData);
        end
        
        %==================================================================
        % Steganalysis
        %==================================================================        
        function Complexity_Histogram(JPEGImage)
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
