clear all
%Test CGC to PBC
PBC = [65 60 17 39];
R = [126 40 30 58]; %Result

disp('Testing CGC to PBC...\n')
disp('Matrix to convert is ')
disp(PBC)
disp('in binary is')
disp(dec2bin(PBC))
CGC = cgc_to_pbc(PBC)
disp('PBC matrix obtained is ')
disp(dec2bin(CGC))

assert(isequal(CGC,R),'The conversion is not correct')