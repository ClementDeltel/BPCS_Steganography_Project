clear all;
close all;
clc;

%% Test PBC to CGC with a matrix

b = [126;40;30;58];
Result = [65;60;17;39]; %Result

disp('Testing PBC to CGC')
disp('Matrix to convert is ')
disp(b)
disp('in binary is')
disp(dec2bin(b))
CGC = bitxor(b,(bitor(bitshift(b,-1),bitand(2^7,b))));
disp('CGC matrix obtained is ')
disp(dec2bin(CGC))

assert(isequal(Result,CGC),'The conversion is not correct')

%% Test CGC to PBC with a matrix

disp('Testing CGC to PBC')
disp('Matrix to convert is ')
disp(CGC)
disp('in binary is')
disp(dec2bin(CGC))
PBC =  bitor(b,bitxor(bitand(CGC,2.^(7-1)),bitshift(bitand(b,2.^7),-1)));
disp('PBC matrix obtained is ')
disp(dec2bin(PBC))

assert(isequal(b,PBC),'The conversion is not correct')

%% Compressor/Decompressor JPEG

A = [52, 55, 61, 66, 70, 61, 64, 73;
     63, 59, 55, 90, 109, 85, 69, 72;
     62, 59, 68, 113, 144, 104, 66, 73;
     63, 58, 71, 122, 154, 106, 70, 69;
     67, 61, 68, 104, 126, 88, 68, 70;
     79, 65, 60, 70, 77, 68, 58, 75;
     85, 71, 64, 59, 55, 61, 65, 83;
     87, 79, 69, 68, 65, 76, 78, 94];

% Quantization matrix
Q = [16, 11, 10, 16, 24, 40, 51, 61;
     12, 12, 14, 19, 26, 58, 60, 55;
     14, 13, 16, 24, 40, 57, 69, 56;
     14, 17, 22, 29, 51, 87, 80, 62;
     18, 22, 37, 56, 68, 109, 103, 77;
     24, 35, 55, 64, 81, 104, 113, 92;
     49, 64, 78, 87, 103, 121, 120, 101;
     72, 92, 95, 98, 112, 100, 103, 99];

% Encoding
b = A - 128;
G = round(dct2(b),2);
B = round(G./Q);

% Decoding
C = round(B.*Q);
D = round(idct2(C),2);
E = round(D) + 128;

% Accuracy measure
Diff = A - E;


%% PBC to CGC with real blocks from the 3 three chanels of the image 

Start_Y = [-497,11,8,27,16,9,8,6;
           101,48,-5,-1,-9,5,3,2;
           -9,34,11,-20,-11,2,-3,-5;
           11,-32,-5,-4,0,0,-1,-4;
           -1,-24,-28,11,26,7,3,-6;
           11,5,-7,8,17,0,-2,-3;
           11,-6,-4,2,3,2,-6,4;
           1,-5,2,6,-3,-2,-6,0];
       
Result_Y = [-466,-36,19,21,37,18,-7,-8;
         62,8,-13,-31,-24,9,12,-14;
         -11,6,15,-6,3,-3,-4,3;
         6,10,-4,12,1,-15,10,-6;
         -33,-8,-4,-14,34,12,-10,6;
         10,-2,31,6,-16,-30,-3,7;
         3,6,-21,-8,8,4,5,-3;
         -22,-1,1,17,15,7,0,-19];

Start_Cb = [-202,26,12,-12,-4,4,1,0;
            -4,-8,1,-14,-1,3,-1,1;
            20,-17,-10,-1,5,2,1,0;
            -7,4,-3,-2,3,1,1,0;
            -8,0,6,-2,3,2,0,1;
            0,-3,0,3,2,0,0,0;
            -2,0,-1,1,-1,0,0,0;
            1,-1,-1,-1,-1,0,0,-1];
        
Result_Cb = [-214,43,-5,-17,-10,-1,12,10;
             19,3,-10,-10,9,1,-9,14;
             30,-2,-7,-14,-2,6,-2,-5;
             5,-16,2,-9,7,10,-15,-3;
             19,-7,-3,16,2,-1,-8,-11;
             9,4,-21,6,24,16,-11,-17;
             3,-11,-1,7,-3,-5,-11,-3;
             18,0,-2,-5,-11,-5,-6,7];
        
Start_Cr = [-147,-2,2,-1,2,4,1,-1;
            -4,-9,1,0,2,-3,-1,1;
            -2,2,3,4,-1,-3,1,0;
            -4,11,2,-1,-2,-1,0,-2;
            3,-4,0,0,-2,0,1,-1;
            -1,-1,-1,0,2,1,-1,0;
            1,1,0,1,1,0,-1,0;
            0,1,0,0,-1,0,1,0];     
     
Result_Cr = [-139,25,7,8,4,13,11,6;
             38,33,27,14,24,11,-2,-1;
             7,33,1,-1,-10,23,6,-19;
             -1,-15,9,-15,5,21,-9,0;
             3,-26,-30,3,-4,-11,-11,-8;
             -12,-6,-31,19,39,27,-5,0;
             -2,-23,16,24,15,6,-3,-5;
             3,14,-7,-17,1,14,11,-3];

Quant_matrix = ones(8,8);

% Decoding 
IQY         = Start_Y.*Quant_matrix;
IQCb        = Start_Cb.*Quant_matrix;
IQCr        = Start_Cr.*Quant_matrix;

IDCTY       = idct2(IQY);
IDCTCb      = idct2(IQCb);
IDCTCr      = idct2(IQCr);

Shift1Y     = round(IDCTY) + 128;
Shift1Cb    = round(IDCTCb) + 128;
Shift1Cr    = round(IDCTCr) + 128;

% YCbCr to RGB
PBC_R       = round(Shift1Y  + 1.402*(Shift1Cr - 128));
PBC_G       = round(Shift1Y  - 0.34414*(Shift1Cb - 128) - 0.71414*(Shift1Cr - 128));
PBC_B       = round(Shift1Y  + 1.772*(Shift1Cb - 128));

% PBC to CGC
CGC_R       = bitxor(PBC_R,(bitor(bitshift(PBC_R,-1),bitand(2^15,PBC_R))));
CGC_G       = bitxor(PBC_G,(bitor(bitshift(PBC_G,-1),bitand(2^15,PBC_G))));
CGC_B       = bitxor(PBC_B,(bitor(bitshift(PBC_B,-1),bitand(2^15,PBC_B))));

% RGB to YCbCr
CGC_Y       = 0.299*CGC_R    + 0.587*CGC_G    + 0.114*CGC_B;
CGC_Cb      = -0.1687*CGC_R  - 0.3313*CGC_G   + 0.5*CGC_B    + 128;
CGC_Cr      = 0.5*CGC_R      - 0.4187*CGC_G   - 0.0813*CGC_B + 128;


Shift2Y = CGC_Y - 128;
Shift2Cb = CGC_Cb - 128;
Shift2Cr = CGC_Cr - 128;

DCTY = dct2(Shift2Y);
DCTCb = dct2(Shift2Cb);
DCTCr = dct2(Shift2Cr);

QY = round(DCTY./Quant_matrix);
QCb = round(DCTCb./Quant_matrix);
QCr = round(DCTCr./Quant_matrix);

Diff_Y = Result_Y - QY;
Diff_Cb = Result_Cb - QCb;
Diff_Cr = Result_Cr - QCr;

avg1 = mean(Diff_Y(:));
avg2 = mean(Diff_Cb(:));
avg3 = mean(Diff_Cr(:));