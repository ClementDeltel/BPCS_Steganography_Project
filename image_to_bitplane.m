%This fuctions return the 8 bitplane of the image received as input
%Input: Image - Array
%Output: 8BP x length(Image)
%Bitplane = B8 B7 B6 B5 B4 B3 B2 B1
function BP = image_to_bitplane(image)
    %Image=[1 2 3 4]
    %[rows,columns] = size(image);
    columns = length(image);
    num_bp = 8;
    BP = zeros(num_bp,columns);
    
    for i=0:num_bp-1
        BP(num_bp-i,:) = bitand(image,2.^i) > 0;
    end
end
