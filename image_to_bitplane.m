%This fuctions return the 16 bitplane of the image received as input
%Input: Image - Array(n x m)
%       (optional) num_bp = Number of BitPlanes
%       (optional) type = codification of the elements of the image
%Output: 16 BP x length(n x m)
%Bitplane = B1 B2 B3 ... B15 B16
function BP = image_to_bitplane(image,num_bp,type)
    if (nargin < 2)
        type = 'int16';
        num_bp = 16;
    elseif (nargin < 3)
        type = 'int16';
    end
    
    %Ex. Image=[1 2 
    %           3 4]
    [rows,columns] = size(image);

    BP = zeros(num_bp,rows,columns);
    
    for i=1:num_bp
        %Numer code = b16 b15 ... b2 b1
        %With bitget position 1 is bit 1 from right
        %BP1 is bit 16 .. BP16 is bit 1 
        BP(i,:,:) = int8(bitget(image,num_bp-i+1,type));
    end
end
