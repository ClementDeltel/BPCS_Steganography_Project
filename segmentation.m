%Function that group each bit-plane of the image into informative or
%noise-like regions. The bitplane presents a noise-like pattern when its 
%complexity is higher than the threshold value (alpha)
%Input: Matrix bitplane (bp x N x M)
%Output: indexes of the noise & informative bitplanes

function [noise,informative] = segmentation(BP,alpha,num_bp)  
    if nargin < 2
        num_bp = 16;
        alpha=0.3;
    elseif nargin < 3
        num_bp = 16;
    end
    
    noise = [];
    informative = [];
    
    for i=1:num_bp
        if (get_complexity(BP(i,:,:)) >= alpha)
            noise = [noise i];
        else
            informative = [informative i];
        end
    end
end