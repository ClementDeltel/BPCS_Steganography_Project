% Transform the matrix received as argument from PBC system
% to CGC system
% Input: b is a PBC matrix composed by numbers of 8 bits [0, 255]
% Output: g is a CGC matrix composed by numbers of 8 bits [0,255]
%
% PBC = [b8 b7 b6 b5 b4 b3 b2 b1]
% CGC = [g8 g7 g6 g5 g4 g3 g2 g1]
% gi = elements of CGC
% bi = elements of PBC
% g8 = b8
% gi = bi xor b(i+1)

function g = pbc_to_cgc(b)
   g = bitxor(b,(bitor(bitshift(b,-1),bitand(128,b))));
end