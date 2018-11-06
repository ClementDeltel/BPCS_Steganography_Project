%This function receive a text as parameter, for example "hello world"
%   1) Divide the text into blocks (composed by BLOCK_SIZE columns)
%       where BLOCK_SIZE is the number of characters per block
%   2) For each block calculate its complexity
%        2.1) If it is NOT complex, make it complex by conjugating it
%             and make a note of it
%B = Array of blocks
    %B1 = first BLOCK_SIZE characters [c1 c2 ... c8] Here BLOCK_SIZE = 8
    %B2 = second BLOCK_SIZE characters [c9 ... c16]
    %BN = N BLOCK_SIZE characters [ci ... cn]
function [B,conj_map] = group_text_into_block(t, alpha, block_size)
    switch nargin
    case 1
        alpha = 0.3;
        block_size = 8;
    case 2
        block_size = 8;
    end

    charMatrix=int16(char(t));
    [~, n_char] = size(charMatrix);
    n_bloq = ceil(n_char/block_size);
    B = zeros(n_bloq,block_size);
    
    conj_map = [];
    
    %Add "END" character at the end
    
    for i=1:n_bloq
        if i < n_bloq
            B1 = charMatrix(8*(i-1)+1:8*i);
            if (get_complexity(dec2bin(B1,8)) < alpha)
                B1 = conjugate(B1);
                conj_map = [conj_map i];
            end
            B(i,:)= B1;
        else
            B1 = charMatrix(8*(i-1)+1:end);
            if (get_complexity(dec2bin(B1,8)) < alpha)
                B1 = conjugate(B1);
                conj_map = [conj_map i];
            end
            B(i,:)= [B1 zeros(1, 8-length(charMatrix(8*(i-1)+1:end)))];
            
        end 
    end
end