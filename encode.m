%Input: vessel image data and text
%Output: image with text inside applying bpcs algorithm
function steg_image = encode(vessel, t)
    addpath('./jpeg_toolbox');
    block_size = 8;
    
    dct = get_dct_coef(vessel);
    
    %Get the first channel from YCbCr (i.e: Y channel)
    dct_y = int16(dct{1,1});
    
    %Transform dct coefficients to CGC system
    dct_cgc = pbc_to_cgc_16(dct_y);
    
    %Calculate the number of blocks of 8x8 (1DC + 63 AC)
    [rows, columns] = size(dct_cgc);
    n_blocks_row = rows/block_size;
    n_blocks_column = columns/block_size;  
    
    
    %Convert the text to characters. It inserts two control codes
    % 2=Start of Text ; 3=End of Text(EoT)
    char_matrix=[uint8(2) uint8(char(t)) uint8(3)];
    n_bits = 8;
    char_matrix = dec2bin(char_matrix,n_bits);
    
    [n_char, ~] = size(char_matrix);
    n_elem_char = n_char * n_bits;
 %   char_matrix = [char_matrix zeros(mod(n_elem_char,64))];
 %   n_elem_char = n_elem_char + mod(n_elem_char,64);
    p_char = 1;
    
    for i=1:n_blocks_row
        for j=1:n_blocks_column
           block = dct_cgc((i-1)*8+1:i*8, (j-1)*8+1:j*8);
           bp_block = image_to_bitplane(block);
           [noise,~] = segmentation(bp_block);
           num_noise = length(noise);
           
        end
        if (n_elem_char <= p_char)
           break
        end
    end

    steg_image = double(cgc_to_pbc_16(dct_cgc));
end