%This fuctions return the 8 bitplane of the image received as input
%Input: Image - Array(2D)
%Output: 8BP x length(Image)
%   BP = B1 ... B8
%Bitplane = B8 B7 B6 B5 B4 B3 B2 B1
function BP = image_to_bitplane(image)
    %Image=[1 2 
    %       3 4]
    [rows,columns] = size(image);
    num_bp = 8;
    BP = zeros(num_bp,rows,columns);
    
    for i=1:num_bp
        BP(i,:,:) = bitget(image,i);
    end
end
