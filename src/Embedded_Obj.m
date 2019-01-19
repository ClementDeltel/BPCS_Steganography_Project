classdef Embedded_Obj < handle
    
    properties (GetAccess = public)
        Name
        Size
        Type
        Text
        
        %Useful data
        Bitstream
        Blocks
        Count_decimal
        Count_block
        
        %Conjugation related fields
        Threshold_alpha = 0.5;
        Count_Conjugation_decimal
        Count_Conjugation_block
        Positions_decimal_tab
        Positions_block_tab
        
        % Stream with all the data to hide
        Block_Stream
        
    end
    
    methods (Access=public)
        
        %==================================================================
        % Constructor
        %==================================================================
        function Embedded_Data = Embedded_Obj(filename)
            [~,Name,Ext] = fileparts(filename);
            fileID = fopen(filename,'r');
            if (strcmp(Ext,'.txt'))
                Embedded_Data.Text = fscanf(fileID,'%c');
            end
            fclose(fileID);
            
            Embedded_Data.Name = Name;
            Embedded_Data.Size = strlength(Embedded_Data.Text);
            Embedded_Data.Type = Ext;
            
            Embedded_Data.Bitstream = '';
            Embedded_Data.Count_decimal = 0;
            Embedded_Data.Count_Conjugation_decimal = 0;
        end
        
        %==================================================================
        % Text to Bitstream and vice versa
        %==================================================================
        function Text_to_Bitstream(Embedded_Data)
            % Binary conversion
            bin = dec2bin(Embedded_Data.Text,8);
            % The output bitstream is a string
            Embedded_Data.Bitstream = reshape(bin',1,numel(bin));
            % Zero-padding
            mult = 2;
            r = mod(56,strlength(Embedded_Data.Bitstream));
            while (r >= 56)
                r = mod(56*mult,strlength(Embedded_Data.Bitstream));
                mult = mult + 1;
            end
            padding = repmat('0',1,r);
            Embedded_Data.Bitstream = strcat(Embedded_Data.Bitstream,padding);
        end
        
        function Bitstream_to_Text(Embedded_Data)
            Embedded_Data.Text = char(bin2dec(reshape(Embedded_Data.Bitstream,7,[]).')).';
            fileID = fopen('secret-message.txt','w');
            fprintf(fileID, Embedded_Data.Text);
            fclose(fileID);
        end
        
        %==================================================================
        % Bitstream to Blocks and vice versa
        %==================================================================
        function Bitstream_to_Blocks(Embedded_Data)
            % Number of blocks we need to hide all the data
            Embedded_Data.Count_decimal = strlength(Embedded_Data.Bitstream)/56;
            % Each block is a 7x8 matrix
            Embedded_Data.Blocks = zeros(7,8,Embedded_Data.Count_decimal);
            % Filling the blocks with the data - string slicing
            for bit= 1:56:strlength(Embedded_Data.Bitstream)
                % String to matrix conversion
                Bitstream_with_spaces = strtrim(regexprep(Embedded_Data.Bitstream(bit:bit+55), '.{1}', '$0 '));
                Line_Block = str2num(Bitstream_with_spaces); %#ok<ST2NM>
                Embedded_Data.Blocks(:,:,fix(bit/56)+1) = reshape(Line_Block, 8, 7)';
            end
        end
        
        function Blocks_to_Bitstream(Embedded_Data)
            for block= 1:Embedded_Data.Count_decimal
                % Matrix to string conversion
                str = mat2str(Embedded_Data.Blocks(:,:,block));
                Embedded_Data.Bitstream = strcat(Embedded_Data.Bitstream, str);
            end
            Embedded_Data.Bitstream = regexprep(Embedded_Data.Bitstream,'[[,],;, ]','');
        end
                
        %==================================================================
        % Block 1 - How many useful blocks do we have ?
        %==================================================================
        function Count_to_block(Embedded_Data)
            Line_Block = str2num(strtrim(regexprep(dec2bin(Embedded_Data.Count_decimal,56), '.{1}', '$0 '))); %#ok<ST2NM>
            Embedded_Data.Count_block = reshape(Line_Block,8,7)';
        end
        
        function Count_to_decimal(Embedded_Data)
            Embedded_Data.Count_decimal = bin2dec(regexprep(mat2str(Embedded_Data.Count_block),'[[,],;, ]',''));
        end
        
        %==================================================================
        % Block 2 - Among useful blocks how many conjugated blocks do we have ?
        %==================================================================
        function Count_Conjugation_to_block(Embedded_Data)
            Line_Block = str2num(strtrim(regexprep(dec2bin(Embedded_Data.Count_Conjugation_decimal,24), '.{1}', '$0 '))); %#ok<ST2NM>
            Embedded_Data.Count_Conjugation_block = reshape(Line_Block,8,3)';
            Embedded_Data.Count_Conjugation_block = [zeros(4,8);Embedded_Data.Count_Conjugation_block];
        end
        
        function Count_Conjugation_to_decimal(Embedded_Data)
            Embedded_Data.Count_Conjugation_decimal = bin2dec(regexprep(mat2str(Embedded_Data.Count_Conjugation_block),'[[,],;, ]',''));
        end
        
        %==================================================================
        % Blocks 3...(n-k) - Conjugated Blocks positions
        %==================================================================
        function Positions_decimal_tab_to_block_tab(Embedded_Data)
            Embedded_Data.Positions_block_tab = zeros(7,8,Embedded_Data.Count_Conjugation_decimal);
            
            for position= 1:Embedded_Data.Count_Conjugation_decimal
                Line_Block = str2num(strtrim(regexprep(dec2bin(Embedded_Data.Positions_decimal_tab(1,position),56), '.{1}', '$0 '))); %#ok<ST2NM>
                Embedded_Data.Positions_block_tab(:,:,position) = reshape(Line_Block,8,7)';
            end
        end
        
        function Positions_block_tab_to_decimal_tab(Embedded_Data)
            Embedded_Data.Positions_decimal_tab = zeros(1,Embedded_Data.Count_Conjugation_decimal);
            
            for position= 1:Embedded_Data.Count_Conjugation_decimal
                Embedded_Data.Positions_decimal_tab(1,position) = bin2dec(regexprep(mat2str(Embedded_Data.Positions_block_tab(:,:,position)),'[[,],;, ]',''));
            end
        end
        
        %==================================================================
        % Conjugation of Blocks (only if necessary)
        %==================================================================
        function Conjugation_Blocks(Embedded_Data)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            complexity_tab= zeros(1,Embedded_Data.Count_decimal);
            % For loop to retrieve the complexity of all blocks
            for index= 1:Embedded_Data.Count_decimal
                complexity_tab(1,index)= Get_Complexity(Embedded_Data.Blocks(:,:,index));
            end
            % For loop to conjugate the blocks if necessary
            for index= 1:Embedded_Data.Count_decimal
                if (complexity_tab(1,index) <= Embedded_Data.Threshold_alpha)
                    % Conjugation of the block
                    Embedded_Data.Blocks(:,:,index) = bitxor(Wc,Embedded_Data.Blocks(:,:,index));
                    % Update the complexity of the block
                    complexity_tab(1,index)= Get_Complexity(Embedded_Data.Blocks(:,:,index));
                    % Increment the count of conjugated blocks
                    Embedded_Data.Count_Conjugation_decimal = Embedded_Data.Count_Conjugation_decimal+1;
                    % Save the position of the conjugated block in the appropiate tab
                    Embedded_Data.Positions_decimal_tab(1,Embedded_Data.Count_Conjugation_decimal) = index;
                end
            end
        end
        
        %==================================================================
        % Conjugation of additional data
        %==================================================================
        function Conjugation_Additional_Data_1(Embedded_Data)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            % Conjugation of the block Count_block
            Embedded_Data.Count_block = bitxor(Wc,Embedded_Data.Count_block);
            % Conjugation of the block Count_Conjugation_block
            Embedded_Data.Count_Conjugation_block = bitxor(Wc,Embedded_Data.Count_Conjugation_block);
        end
        
        function Conjugation_Additional_Data_2(Embedded_Data)
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            % Conjugation of the blocks Position_block_tab
            for position= 1:Embedded_Data.Count_Conjugation_decimal
                Embedded_Data.Positions_block_tab(:,:,position) = bitxor(Wc,Embedded_Data.Positions_block_tab(:,:,position));
            end
        end
        
        %==================================================================
        % Block Stream
        %==================================================================
        function Data_to_Block_Stream(Embedded_Data)
            Text_to_Bitstream(Embedded_Data);
            % Conversion of each data into blocks
            Bitstream_to_Blocks(Embedded_Data);
            Conjugation_Blocks(Embedded_Data);
            
            Count_to_block(Embedded_Data);
            Count_Conjugation_to_block(Embedded_Data);
            Conjugation_Additional_Data_1(Embedded_Data);
            
            Positions_decimal_tab_to_block_tab(Embedded_Data);
            Conjugation_Additional_Data_2(Embedded_Data);
            
            % Stream initialization
            Embedded_Data.Block_Stream = zeros(7,8,2+Embedded_Data.Count_Conjugation_decimal+Embedded_Data.Count_decimal);
            % Stream filling
            Embedded_Data.Block_Stream(:,:,1) = Embedded_Data.Count_block;
            Embedded_Data.Block_Stream(:,:,2) = Embedded_Data.Count_Conjugation_block;
            Embedded_Data.Block_Stream(:,:,3:Embedded_Data.Count_Conjugation_decimal+2) = Embedded_Data.Positions_block_tab;
            Embedded_Data.Block_Stream(:,:,3+Embedded_Data.Count_Conjugation_decimal:Embedded_Data.Count_Conjugation_decimal+Embedded_Data.Count_decimal+2) = Embedded_Data.Blocks;
        end
        
        %==================================================================
        % Block coding to decimal values
        %==================================================================
        function Block_Stream_to_Data(Embedded_Data)
            % Retrieve the two first blocks of our Block_Stream
            Embedded_Data.Count_block = Embedded_Data.Block_Stream(:,:,1);
            Embedded_Data.Count_Conjugation_block = Embedded_Data.Block_Stream(:,:,2);
            % Conversion of data in decimal values
            Conjugation_Additional_Data_1(Embedded_Data);
            Count_to_decimal(Embedded_Data);
            Count_Conjugation_to_decimal(Embedded_Data);
            
            %Retrieve the blocks which contain the positions of the
            %conjugated blocks
            Conjugation_Additional_Data_2(Embedded_Data);
            Embedded_Data.Positions_block_tab = Embedded_Data.Block_Stream(:,:,3:Embedded_Data.Count_Conjugation_decimal+3);
            Positions_block_tab_to_decimal_tab(Embedded_Data);
            
            %Retrieve the useful blocks
            Embedded_Data.Blocks = Embedded_Data.Block_Stream(:,:,Embedded_Data.Count_Conjugation_decimal+4:Embedded_Data.Count_Conjugation_decimal+Embedded_Data.Count_decimal+4);
            
            % Retrieve the conjugated blocks
            X = toeplitz(mod(1:8,2));
            Wc = bitxor(X(1:7,:),ones(7,8));
            
            for position= Embedded_Data.Positions_decimal_tab
                Embedded_Data.Blocks(:,:,positon) = bitxor(Wc,Embedded_Data.Blocks(:,:,position));
            end
            
            % Retrieve the text message
            Blocks_to_Bitstream(Embedded_Data);
            Bitsream_to_Text(Embedded_Data);
        end
    end
end