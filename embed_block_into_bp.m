
%Blocks of data = (num1, num2, ... num8; num 9... num16;...)
%Noise_Regions = (bitplane1: bit1 ... bitn;..... bitplane8: bit1... bitn)

function noise_regions=embed_block_into_bp(blocks, noise_regions)

    blocksbin = dec2bin(blocks,8); %Array(num_elem in blocks x 8)
                                   %Example: 2x8 char array
                                   %'00000001'
                                   %'00000011'
                                   
    [noise_regions_rows, noise_regions_columns] = size(noise_regions);
    [blocks_rows, blocks_columns] = size(blocksbin);
    
    p_blocks_row = 1;
    p_blocks_column = 1;
    
    for i=1:noise_regions_rows
        j=1;

        while((noise_regions_columns - j >= 0) && (p_blocks_row <= blocks_rows))
            if (blocksbin(p_blocks_row,p_blocks_column) == '0')
                noise_regions(i,j)=0;
            else
                noise_regions(i,j)=1;
            end
            
            p_blocks_column = p_blocks_column + 1;
            if (p_blocks_column == blocks_columns)
                p_blocks_column=1;
                p_blocks_row = p_blocks_row+1;
            end
            j=j+1;
        end
        
        if (p_blocks_row > blocks_rows)
            break
        end
    end
end