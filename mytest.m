struct_jpeg=jpeg_read('D:\Users\fandrieux\Desktop\BPCS_Steganography_Project\jpeg_toolbox\logo.jpg');
[dct_coef,ac_coef,dc_coef,quant]= get_dct_coef(struct_jpeg);

dct_coef{1}=dct_coef{1}+5;
dct_coef{2}=dct_coef{2}+5;
dct_coef{3}=dct_coef{3}+5;
struct_jpeg=setfield(struct_jpeg,'coef_arrays',dct_coef);
%ac_coef= ac_coef+150;
%dc_coef= dc_coef +130;
%struct_jpeg.ac_huff_tables=setfield(struct_jpeg.ac_huff_tables,'ac_huff_tables',ac_coef);
%struct_jpeg.dc_huff_tables=setfield(struct_jpeg.dc_huff_tables,'ac_huff_tables',dc_coef);
jpeg_write(struct_jpeg,'write.jpg');
