%This fuctions return the 16 bitplane of the image received as input
%Input: Image - Array(n x m)
%Output: 16 BP x length(n x m)
%Bitplane = B1 B2 B3 ... B15 B16

function BP = image_to_bitplane(image, num_bp)
    if (nargin < 2)
        num_bp = 16;
    end
    
    %Ex. Image=[1 2 
    %           3 4]
    [rows,columns] = size(image);

    BP = zeros(num_bp,rows,columns);
    
    for i=1:num_bp
        BP(i,:,:) = bitget(image,num_bp-i+1);
    end
end
