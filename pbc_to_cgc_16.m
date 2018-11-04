% Transform the matrix received as argument from PBC system
% to CGC system
% Input: b is a PBC matrix composed by numbers of 16 bits 
% Output: g is a CGC matrix composed by numbers of 16 bits
%
% PBC = [b16 b15 ... b2 b1]
% CGC = [g16 g15 ... g2 g1]
% gi = elements of CGC
% bi = elements of PBC
% g16 = b16
% gi = bi xor b(i+1)

function g = pbc_to_cgc_16(b)
   g = bitxor(b,(bitor(bitshift(b,-1),bitand(2^15,b))));
end