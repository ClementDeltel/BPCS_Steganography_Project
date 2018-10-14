clear all
%Test PBC to CGC
A = [126 40 30 58];
R = [65 60 17 39]; %Result

disp('Testing PBC to CGC...\n')
disp('Matrix to convert is ')
disp(A)
disp('in binary is')
disp(dec2bin(A))
PBC = pbc_to_cgc(A)
disp('CGC matrix obtained is ')
disp(dec2bin(PBC))

assert(isequal(R,PBC),'The conversion is not correct')