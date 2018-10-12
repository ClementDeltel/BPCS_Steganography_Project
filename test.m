clear all
%Test PBC to CGC
A = [126 40 30 58];
B = [65 60 17 39]; %Result

disp('Testing PBC to CGC...\n')
disp('Matrix to convert is ')
disp(A)
disp('in binary is')
disp(dec2bin(A))
c = pbc_to_cgc(A)
disp('CGC matrix obtained is ')
disp(dec2bin(c))

assert(isequal(B,c),'The conversion is not correct')

%Test CGC to PBC


disp('Testing CGC to PBC...\n')
disp('Matrix to convert is ')
disp(c)
disp('in binary is')
disp(dec2bin(c))
P = cgc_to_pbc(c)
disp('PBC matrix obtained is ')
disp(dec2bin(P))

assert(isequal(A,P),'The conversion is not correct')