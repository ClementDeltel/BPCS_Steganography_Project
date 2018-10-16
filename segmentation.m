%Function that segment each bit-plane of the image into informative and
%noise-like regions using a thresholdvalue
%Input: Matrix bitplane (NxNx8)
%Output: indexes of the noise & informative bitplanes

%Threshold: replace each pixel in an image with a black pixel if the image
%intensity is less than a constant (alpha)
function [noise,informative] = segmentation(BP,alpha)  
    if nargin < 2
        alpha=0.3;
    end
    noise = [];
    informative = [];
    num_bp = 8;
    
    for i=1:num_bp
        %complexity = [complexity get_complexity(BP(:,:,i))];
        if (get_complexity(BP(i,:,:)) >= alpha)
            noise = [noise i];
        else
            informative = [informative i];
        end
    end
end