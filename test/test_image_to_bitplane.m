A = [126 40 30 58];
BPc = [0 0 0 0; 1 0 0 0; 1 1 0 1; 1 0 1 1; 1 1 1 1;1 0 1 0; 1 0 1 1; 0 0 0 0];

disp('Testing image_to_bitplane...\n')
disp('Matrix to convert into bitplane is ')
disp(A)
disp('in binary is')
disp(dec2bin(A))
BP = image_to_bitplane(A);
%disp('The bit-plane matrix obtained is ')
%disp(dec2bin(BP))

assert(isequal(BPc,BP),'The conversion into bitplane is not correct')