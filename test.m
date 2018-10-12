clear all
%Test PBC to CGC
A = [126 40 30 58];
B = [65 60 17 39]; %Result
BPc = [0 0 0 0; 1 0 0 0; 1 1 0 1; 1 0 1 1; 1 1 1 1;1 0 1 0; 1 0 1 1; 0 0 0 0];

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


disp('Testing image_to_bitplane...\n')
disp('Matrix to convert into bitplane is ')
disp(A)
disp('in binary is')
disp(dec2bin(A))
BP = image_to_bitplane(A)
%disp('The bit-plane matrix obtained is ')
%disp(dec2bin(BP))

assert(isequal(BPc,BP),'The conversion into bitplane is not correct')



disp('Testing get complexity...\n')
disp('Get complexity of matrix ')
disp(BPc)
complexity = zeros(8,1);
for i=1:8
    complexity(i) = get_complexity(BPc(i,:));
end
disp('The complexity obteined is ')
disp(complexity)

assert(isequal([0; 1/3; 2/3; 2/3; 0/3; 3/3; 2/3; 0],complexity),'Fail to get correct complexity')



disp('Testing segmentation...\n')
disp('Get complexity of matrix ')
disp(BPc)
[noise, informative] = segmentation(BPc);
disp('The noise areas are')
disp(noise)
disp('The informative areas are')
disp(informative)

assert(isequal([1 5 8],noise),'Fail to get noise bp')
assert(isequal([2 3 4 6 7],informative),'Fail to get informative bp')



