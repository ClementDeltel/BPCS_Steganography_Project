classdef EmbeddedObj < handle
    
    properties (GetAccess = public)
        name
        size
        type
        text='';
        
        % Useful data
        bitstream
        blocks
        countDecimal
        countBlock
        
        % Conjugation related fields
        thresholdAlpha = 0.5;
        complexityTab
        complexityTabConj
        countConjugationDecimal
        countConjugationBlock
        positionsDecimalTab
        positionsBlockTab
        
        % Stream with all the data to hide
        blockStream
        
    end
    
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function EmbeddedData = EmbeddedObj(filename)
            [~,name,ext] = fileparts(filename);
            fileID = fopen(filename,'r');
            if (fileID > 0 && strcmp(ext,'.txt'))
                EmbeddedData.text = fscanf(fileID,'%c');
                fclose(fileID);
            end
            
            EmbeddedData.name = name;
            EmbeddedData.size = strlength(EmbeddedData.text);
            EmbeddedData.type = ext;
            
            EmbeddedData.bitstream = '';
            EmbeddedData.countDecimal = 0;
            EmbeddedData.countConjugationDecimal = 0;
        end
        
        %==================================================================
        % Text to Bitstream and vice versa
        %==================================================================
        function Text_to_Bitstream(EmbeddedData)
            % Remove undesirables char
            EmbeddedData.text = regexprep(EmbeddedData.text, '‘|’|“|”|‹|›|«|»|?|?|„|"|''', ' ');
            % Binary conversion
            bin = dec2bin(EmbeddedData.text,8);
            % The output bitstream is a string
            EmbeddedData.bitstream = reshape(bin',1,numel(bin));
            % Zero-padding
            mult = 2;
            r = mod(56,strlength(EmbeddedData.bitstream));
            while (r >= 56)
                r = mod(56*mult,strlength(EmbeddedData.bitstream));
                mult = mult + 1;
            end
            padding = repmat('0',1,r);
            EmbeddedData.bitstream = strcat(EmbeddedData.bitstream,padding);
        end
        
        function Bitstream_to_Text(EmbeddedData)
            EmbeddedData.text = char(bin2dec(reshape(EmbeddedData.bitstream,8,[]).')).';
            EmbeddedData.size = strlength(EmbeddedData.text);
            % Writing to the file
            fileID = fopen(strcat(EmbeddedData.name, EmbeddedData.type),'w');
            fprintf(fileID, EmbeddedData.text);
            fclose(fileID);
        end
        
        %==================================================================
        % Bitstream to Blocks and vice versa
        %==================================================================
        function Bitstream_to_Blocks(EmbeddedData)
            % Number of blocks we need to hide all the data
            EmbeddedData.countDecimal = strlength(EmbeddedData.bitstream)/56;
            % Each block is a 7x8 matrix
            EmbeddedData.blocks = zeros(7,8,EmbeddedData.countDecimal);
            % Filling the blocks with the data - string slicing
            for bit= 1:56:strlength(EmbeddedData.bitstream)
                % String to matrix conversion
                spacedBitstream = strtrim(regexprep(EmbeddedData.bitstream(bit:bit+55), '.{1}', '$0 '));
                lineBlock = str2num(spacedBitstream); %#ok<ST2NM>
                EmbeddedData.blocks(:,:,fix(bit/56)+1) = reshape(lineBlock, 8, 7)';
            end
        end
        
        function Blocks_to_Bitstream(EmbeddedData)
            for block= 1:EmbeddedData.countDecimal
                % Matrix to string conversion
                str = mat2str(EmbeddedData.blocks(:,:,block));
                EmbeddedData.bitstream = strcat(EmbeddedData.bitstream, str);
            end
            EmbeddedData.bitstream = regexprep(EmbeddedData.bitstream,'[[,],;, ]','');
        end
                
        %==================================================================
        % Block 1 - How many useful blocks do we have ?
        %==================================================================
        function Count_to_block(EmbeddedData)
            lineBlock = str2num(strtrim(regexprep(dec2bin(EmbeddedData.countDecimal,56), '.{1}', '$0 '))); %#ok<ST2NM>
            EmbeddedData.countBlock = reshape(lineBlock,8,7)';
        end
        
        function Count_to_decimal(EmbeddedData)
            EmbeddedData.countDecimal = bin2dec(regexprep(mat2str(EmbeddedData.countBlock),'[[,],;, ]',''));
        end
        
        %==================================================================
        % Block 2 - Among useful blocks how many conjugated blocks do we have ?
        %==================================================================
        function Count_Conjugation_to_block(EmbeddedData)
            lineBlock = str2num(strtrim(regexprep(dec2bin(EmbeddedData.countConjugationDecimal,24), '.{1}', '$0 '))); %#ok<ST2NM>
            EmbeddedData.countConjugationBlock = reshape(lineBlock,8,3)';
            EmbeddedData.countConjugationBlock = [zeros(4,8);EmbeddedData.countConjugationBlock];
        end
        
        function Count_Conjugation_to_decimal(EmbeddedData)
            EmbeddedData.countConjugationDecimal = bin2dec(regexprep(mat2str(EmbeddedData.countConjugationBlock),'[[,],;, ]',''));
        end
        
        %==================================================================
        % Blocks 3...(n-k) - Conjugated Blocks positions
        %==================================================================
        function Positions_Decimal_Tab_to_block(EmbeddedData)
            EmbeddedData.positionsBlockTab = zeros(7,8,EmbeddedData.countConjugationDecimal);
            
            for position= 1:EmbeddedData.countConjugationDecimal
                lineBlock = str2num(strtrim(regexprep(dec2bin(EmbeddedData.positionsDecimalTab(1,position),56), '.{1}', '$0 '))); %#ok<ST2NM>
                EmbeddedData.positionsBlockTab(:,:,position) = reshape(lineBlock,8,7)';
            end
        end
        
        function Positions_Block_Tab_to_decimal(EmbeddedData)
            EmbeddedData.positionsDecimalTab = zeros(1,EmbeddedData.countConjugationDecimal);
            
            for position= 1:EmbeddedData.countConjugationDecimal
                EmbeddedData.positionsDecimalTab(1,position) = bin2dec(regexprep(mat2str(EmbeddedData.positionsBlockTab(:,:,position)),'[[,],;, ]',''));
            end
        end
        
        %==================================================================
        % Conjugation of Blocks (only if necessary)
        %==================================================================
        function Conjugation_Blocks(EmbeddedData)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            EmbeddedData.complexityTab= zeros(1,EmbeddedData.countDecimal);
            % For loop to retrieve the complexity of all blocks
            for index= 1:EmbeddedData.countDecimal
                EmbeddedData.complexityTab(1,index)= Get_Complexity(EmbeddedData.blocks(:,:,index));
            end
            EmbeddedData.complexityTabConj = EmbeddedData.complexityTab;
            % For loop to conjugate the blocks if necessary
            for index= 1:EmbeddedData.countDecimal
                if (EmbeddedData.complexityTabConj(1,index) <= EmbeddedData.thresholdAlpha)
                    % Conjugation of the block
                    EmbeddedData.blocks(:,:,index) = bitxor(Wc,EmbeddedData.blocks(:,:,index));
                    % Update the complexity of the block
                    EmbeddedData.complexityTabConj(1,index)= Get_Complexity(EmbeddedData.blocks(:,:,index));
                    % Increment the count of conjugated blocks
                    EmbeddedData.countConjugationDecimal = EmbeddedData.countConjugationDecimal+1;
                    % Save the position of the conjugated block in the appropiate tab
                    EmbeddedData.positionsDecimalTab(1,EmbeddedData.countConjugationDecimal) = index;
                end
            end
        end
        
        %==================================================================
        % Conjugation of additional data
        %==================================================================
        function Conjugation_Additional_Data_1(EmbeddedData)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            % Conjugation of the block countBlock
            EmbeddedData.countBlock = bitxor(Wc,EmbeddedData.countBlock);
            % Conjugation of the block countConjugationBlock
            EmbeddedData.countConjugationBlock = bitxor(Wc,EmbeddedData.countConjugationBlock);
        end
        
        function Conjugation_Additional_Data_2(EmbeddedData)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            % Conjugation of the blocks PositionBlockTab
            for position= 1:EmbeddedData.countConjugationDecimal
                EmbeddedData.positionsBlockTab(:,:,position) = bitxor(Wc,EmbeddedData.positionsBlockTab(:,:,position));
            end
        end
        
        %==================================================================
        % Block Stream
        %==================================================================
        function Data_to_Blockstream(EmbeddedData)
            Text_to_Bitstream(EmbeddedData);
            % Conversion of each data into blocks
            Bitstream_to_Blocks(EmbeddedData);
            Conjugation_Blocks(EmbeddedData);
            
            Count_to_block(EmbeddedData);
            Count_Conjugation_to_block(EmbeddedData);
            Conjugation_Additional_Data_1(EmbeddedData);
            
            Positions_Decimal_Tab_to_block(EmbeddedData);
            Conjugation_Additional_Data_2(EmbeddedData);
            
            % Stream initialization
            EmbeddedData.blockStream = zeros(7,8,2+EmbeddedData.countConjugationDecimal+EmbeddedData.countDecimal);
            % Stream filling
            EmbeddedData.blockStream(:,:,1) = EmbeddedData.countBlock;
            EmbeddedData.blockStream(:,:,2) = EmbeddedData.countConjugationBlock;
            EmbeddedData.blockStream(:,:,3:EmbeddedData.countConjugationDecimal+2) = EmbeddedData.positionsBlockTab;
            EmbeddedData.blockStream(:,:,3+EmbeddedData.countConjugationDecimal:EmbeddedData.countConjugationDecimal+EmbeddedData.countDecimal+2) = EmbeddedData.blocks;
        end
        
        %==================================================================
        % Block coding to decimal values
        %==================================================================
        function Block_Stream_to_Data(EmbeddedData)
            % Retrieve the two first blocks of our blockStream
            EmbeddedData.countBlock = EmbeddedData.blockStream(:,:,1);
            EmbeddedData.countConjugationBlock = EmbeddedData.blockStream(:,:,2);
            % Conversion of data in decimal values
            Conjugation_Additional_Data_1(EmbeddedData);
            Count_to_decimal(EmbeddedData);
            Count_Conjugation_to_decimal(EmbeddedData);
            
            % Retrieve the blocks which contain the positions of the
            % conjugated blocks
            EmbeddedData.positionsBlockTab = EmbeddedData.blockStream(:,:,3:EmbeddedData.countConjugationDecimal+2);
            Conjugation_Additional_Data_2(EmbeddedData);
            Positions_Block_Tab_to_decimal(EmbeddedData);
            
            % Retrieve the useful blocks
            EmbeddedData.blocks = EmbeddedData.blockStream(:,:,EmbeddedData.countConjugationDecimal+3:EmbeddedData.countConjugationDecimal+EmbeddedData.countDecimal+2);
            
            % Retrieve the conjugated blocks
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            for position= EmbeddedData.positionsDecimalTab
                EmbeddedData.blocks(:,:,position) = bitxor(Wc,EmbeddedData.blocks(:,:,position));
            end
            
            % Retrieve the text message
            Blocks_to_Bitstream(EmbeddedData);
            Bitstream_to_Text(EmbeddedData);
        end
        
        %==================================================================
        % Steganalysis
        %==================================================================
        function Complexity_Histogram(EmbeddedData)
            figure;
            subplot(121);
            histogram(EmbeddedData.complexityTab, 'BinLimits', [0,1]);
            subplot(122);
            histogram(EmbeddedData.complexityTabConj, 'BinLimits', [0,1]);
        end
    end
end
