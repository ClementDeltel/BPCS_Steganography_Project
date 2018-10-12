% Transform the matrix received as argument from CGC system
% to PBC system
% Input: c is a CGC matrix composed by numbers of 8 bits [0, 255]
% Output: b is a PBC matrix 
%
% CGC = [g8 g7 g6 g5 g4 g3 g2 g1]
% PBC = [b8 b7 b6 b5 b4 b3 b2 b1]
% bi = elements of PBC
% gi = elements of CGC
% g8 = b8
% gi = bi xor b(i+1)

%g is a CGC matrix composed by binary elements
function b = cgc_to_pbc(g)
%[rows,columns] = size(g);
%b = zeros(rows, columns);
%b(:,1)=g(:,1);
%    for j=2:columns
%        b(:,j)=xor(g(:,j),b(:,j-1));
%    end
    b = bitand(128,g);    
    for i=7:-1:1
        b = bitor(b,bitxor(bitand(g,2.^(i-1)),bitshift(bitand(b,2.^i),-1)));
    end

end