%Step 3 of BPCS algorithm: group the bytes of the secret file into a serie
%of secret blocks
%B = Array of blocks
    %B1 = first 8 characters [c1 c2 ... c8]
    %B2 = second 8 characters [c9 ... c16]
function [B,conj_map] = group_text_into_block(t)
    alpha = 0.3;
    charMatrix=uint8(char(t));
    [rows n_char] = size(charMatrix);
    n_bloq = ceil(n_char/8);
    B = zeros(n_bloq,8);
    
    conj_map = [];
    
    for i=1:n_bloq
        if i < n_bloq
            B1 = charMatrix(8*(i-1)+1:8*i);
            if (get_complexity(dec2bin(B1,8)) < alpha)
                conj_map = [conj_map i];
                conjugate(B1);
            end
            B(i,:)= B1;
        else
            B1 = charMatrix(8*(i-1)+1:end);
            if (get_complexity(dec2bin(B1,8)) < alpha)
                conj_map = [conj_map i];
                conjugate(B1);
            end
            B(i,:)= [B1 zeros(1, 8-length(charMatrix(8*(i-1)+1:end)))];
            
        end 
    end
end