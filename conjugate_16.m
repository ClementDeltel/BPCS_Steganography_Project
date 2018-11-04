%This function conjugate block S as defined in "Principle and applications
%of BPCS-Steganography
%S* = S xor Wc
%Wc = checkerboard patter, it has white pixel at the upper-left position.
%I.e: white-black-white-black...
%Input: S is a block of numbers of 16 bits

function Sstar = conjugate_16(S)
    Wc = 2.^14+2.^12+2.^10+2.^8+2.^6+2.^4+2.^2+2.^0;
    Sstar = bitxor(S,Wc);
end