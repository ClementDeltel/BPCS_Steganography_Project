%Return the DCT coefficient of a JPEG image.
%Input: Filename

function [dct_coef,ac_coef,dc_coef,quant]=get_dct_coef(jpeg)
    dct_coef=getfield(jpeg,'coef_arrays');
    ac_coef=getfield(jpeg.ac_huff_tables,'symbols');
    dc_coef=getfield(jpeg.dc_huff_tables,'symbols');
    quant=getfield(jpeg,'quant_tables'); 
end