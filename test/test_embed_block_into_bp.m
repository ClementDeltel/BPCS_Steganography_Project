clear all

CGC = [65 60 17 39];
BP = [0 0 0 0; 1 0 0 0; 0 1 0 1; 0 1 1 0; 0 1 0 0; 0 1 0 1; 0 0 0 1; 1 0 1 1];
informative = 1;

textBlocks = [104 111 108 97];
embed_block_into_bp(textBlocks,BP(1,:));
