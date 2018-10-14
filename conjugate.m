%This function conjugate block S as defined in "Principle and applications
%of BPCS-Steganography
%S* = S xor Wc
%Wc = checkerboard patter, it has white pixel at the upper-left position.
%I.e: white-black-white-black...
%Input: S is a block of numbers of 8 bits

function Sstar = conjugate(S)
    Wc = 2.^6+2.^4+2.^2+2.^0;
    Sstar = bitxor(S,Wc);
end