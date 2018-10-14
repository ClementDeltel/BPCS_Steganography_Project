%This fuctions return the 8 bitplane of the image received as input
%Input: Image - Array(2D)
%Output: 8BP x length(Image)
%   BP = B1 ... B8
%Bitplane = B8 B7 B6 B5 B4 B3 B2 B1
function image = bitplane_to_image(BP)
    [num_bp rows columns] = size(BP);
    image = zeros(rows,columns);
    
    for i=1:num_bp
        image(:,:) = image(:,:) + reshape(BP(i,:,:),rows,columns)*2^(i-1);
    end
end
