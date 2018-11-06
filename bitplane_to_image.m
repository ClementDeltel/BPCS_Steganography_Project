%This fuctions return the image from the i bitplane of n x m values
%Input: iBP x length(n x m)
%Bitplane = B1 B2 B3 ... Bi
%Output: Image - Array(n x m)

function image = bitplane_to_image(BP,num_bp)
    if (nargin < 2)
        num_bp = 16;
    end
    
    [num_bp,rows,columns] = size(BP);
    image = zeros(rows,columns);
    
    for i=1:num_bp
        %image(:,:) = image(:,:) + reshape(BP(num_bp-i+1,:,:),rows,columns)*2^(i-1);
        image(:,:) = image(:,:) + bitshift(reshape(BP(num_bp-i+1,:,:),rows,columns),i-1);
    end
    
    image(image > 2^15-1) = image(image > 2^15-1) - 2^16;
end
