%Function that segment each bit-plane of the image into informative and
%noise-like regions using a thresholdvalue
%Input: Matrix bitplane (NxNx8)
%Threshold: replace each pixel in an image with a black pixel if the image
%intensity is less than a constant (alpha)
function [noise,informative] = segmentation(BP,alpha)  
    if nargin < 2
        alpha=0.3;
    end
    complexity = [];
    
    for i=1:8
        %complexity = [complexity get_complexity(BP(:,:,i))];
        complexity = [complexity get_complexity(BP(i,:))];
    end
    
    noise = [];
    informative = [];
    num_bp = 8;
    for i=1:num_bp
        if (complexity(i)<=alpha)
            %noise = cat(3,noise,BP(:,:,i));
            noise = [noise i];
        else
            %informative = cat(3,informative,BP(:,:,i)); 
            informative = [informative i];
        end
    end
end