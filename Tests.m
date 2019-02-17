clear all;
close all;
clc;

%% Function jpeg_read
Read = jpeg_read('house-cgc.jpg');

%% Multiple JPEG images

Read1 = jpeg_read('images_test/cat1.jpg');
Read2 = jpeg_read('images_test/cat2.jpg');
Read3 = jpeg_read('images_test/cat3.jpg');

%% JPEG Object Initialization
Read = jpeg_read('house-cgc.jpg');
jpeg = JPEGStegoObj('house-cgc.jpg');

%% First block Y Channel
DCT_Coeff_to_Blocks(jpeg);
Y = squeeze(jpeg.blocks(1,1,1,:,:));

%% Test with DCT coefficients to obtain CGC matrix
DCT_Coeff_to_Blocks(jpeg);

% 3 channels, Y Cb Cr
Y = squeeze(jpeg.blocks(1,1,1,:,:));
Cb = squeeze(jpeg.blocks(2,1,1,:,:));
Cr = squeeze(jpeg.blocks(3,1,1,:,:));

%% Test DCT_Coeff to Blocks
DCT_Coeff_to_Blocks(jpeg);

% Retrieving the block at each corner of the image (Y Channel)
Test1 = squeeze(jpeg.blocks(1,1,1,:,:));
Test2 = squeeze(jpeg.blocks(1,end,1,:,:));
Test3 = squeeze(jpeg.blocks(1,1,end,:,:));
Test4 = squeeze(jpeg.blocks(1,end,end,:,:));

%% Test bitplane construction

jpeg.bitplanes = zeros(3, jpeg.blockRows, jpeg.blockColumns, 8, 8, 16);
jpeg.bitplanes(1, 1, 1, :, :, 1) = bitget(jpeg.blocks(1, 1, 1, :, :),16-1+1, 'int16');

bitplane = squeeze(jpeg.Bitplanes(1, 1, 1, :, :, 1));

%% Test function to convert blocks into bitplanes

Blocks_to_Bitplanes(jpeg);
BP1 = squeeze(jpeg.Bitplanes(1,1,1,:,:,:));
%%
tr = zeros(8,8);

for i=1:16
    tr(:,:) = tr(:,:) + bitshift(BP1(:,:,i),16-i);
end

%%
Bitplanes_to_Blocks(jpeg);
Test1 = squeeze(jpeg.Blocks(1,1,1,:,:));

%% Test blocks and bitplanes

jpegv1=JPEG_Obj('house-pbc.jpg');

DCT_Coeff_to_Blocks(jpegv1);


test = jpegv1.Blocks_Y{1,1};

Nb_Bitplanes=16;
Coeff_type='int16';
Bitplanes_test = zeros(8,8,16);
for bitplane=1:Nb_Bitplanes
    Bitplanes_test(:,:,bitplane) = bitget(test,Nb_Bitplanes-bitplane+1,Coeff_type);
end

test_recover = zeros(8,8);

for i=1:Nb_Bitplanes
    test_recover(:,:) = test_recover(:,:) + bitshift(Bitplanes_test(:,:,i),Nb_Bitplanes-i);
end

test_recover(test_recover > 2^15-1) = test_recover(test_recover > 2^15-1) - 2^16;        
tf=isequal(test,test_recover);

%% Test complexity
for k= 1:16
    bitplane = BP1(:,:,k);
    complexity = Get_Complexity(bitplane);
end

%%
dct_coef{1}=dct_coef{1}+5;
dct_coef{2}=dct_coef{2}+5;
dct_coef{3}=dct_coef{3}+5;
struct_jpeg=setfield(struct_jpeg,'coef_arrays',dct_coef);
%ac_coef= ac_coef+150;
%dc_coef= dc_coef +130;
%struct_jpeg.ac_huff_tables=setfield(struct_jpeg.ac_huff_tables,'ac_huff_tables',ac_coef);
%struct_jpeg.dc_huff_tables=setfield(struct_jpeg.dc_huff_tables,'ac_huff_tables',dc_coef);
jpeg_write(struct_jpeg,'write.jpg');


%% Test bitstream to block
bitstream = '00000111010101010111000110000011010100001011100000110101010101010101101101101000001101011101010111101001001010101010101111101010100000001011010111100010001110010';
l = strlength(bitstream);
a = bitstream(1:64);
b = reshape(a,8,8);
c = str2num(a);

%%

Data = Embedded_Obj('hello.txt');
Text_to_Bitstream(Data);

Bitstream_to_Blocks(Data);

%% Conjugation Demo

P = zeros(16,16);
P(3,5:7) = 1;
P(4,5:9) = 1;
P(5:10,4:11) = 1;
P(11:12,9:15) = 1;

X = toeplitz(mod(1:16,2));
Wc = bitxor(X,ones(16,16));

P_star = bitxor(Wc,P);

figure;
subplot(131);
imshow(P);
subplot(132);
imshow(Wc);
subplot(133);
imshow(P_star);