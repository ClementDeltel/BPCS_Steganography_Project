% Transform the matrix received as argument from CGC system
% to PBC system
% Input: c is a CGC matrix composed by numbers of 16 bits 
% Output: b is a PBC matrix composed by numbers of 16 bits 
%
% Algorithm
% CGC = [g16 g15 ... g2 g1]
% PBC = [b16 b15 ... b2 b1]
% bi = elements of PBC
% gi = elements of CGC
% b16 = g16
% bi = gi xor b(i+1)

%g is a CGC matrix composed by binary elements
function b = cgc_to_pbc_16(g)
    b = bitand(2^15,g);    
    for i=15:-1:1
        b = bitor(b,bitxor(bitand(g,2.^(i-1)),bitshift(bitand(b,2.^i),-1)));
    end
end