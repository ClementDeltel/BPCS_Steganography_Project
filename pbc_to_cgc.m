
% Input: b is a PBC matrix composed by binary elements
% Output: g is a CGC matrix composed by binary elements
function g = pbc_to_cgc(b)
[rows,columns] = size(b);
g = zeros(rows, columns);
g(:,1)=b(:,1);
   for j=2:columns
       g(:,j)=xor(b(:,j-1),b(:,j));
   end
end

%g is a CGC matrix composed by binary elements
function b = cgc_to_pbc(g)
[rows,columns] = size(g);
b = zeros(rows, columns);
b(:,1)=g(:,1);
    for j=2:columns
        b(:,j)=xor(g(:,j),b(:,j-1));
    end
end



%image NxN
%output [BP8 BP7 BP6 BP5 BP4 BP3 BP2 BP1] Each BP has size NxN
function BP = get_bit_plane(image)
    [rows,columns] = size(image);
    BP=zeros(rows, columns,8);
    for i=1:8
%TODO bitget revision negatives
        BP(:,:,i)=bitget(BP,i);
    end
end

%Threshold: replace each pixel in an image with a black pixel if the image
%intensity is less than a constant (alpha)
alpha = 0.3;





%Return the complexity of an image
%Input: NxN Matrix
function complexity = get_complexity(image)
    [rows,columns] = size(image);
    
    %Max. possible changes in the image
    max_pos_changes = (rows-1)*(columns-1); 
    
    %Changes on rows
    %In a 3x3Matrix:
    % 0 0 0 -> 0 changes
    % 0 1 0 -> 2 changes
    % 0 1 1 -> 1 changes
    rows_changes = 0;
    for j=2:columns-1
        rows_changes = rows_changes + ((image(:,j-1) ~= image(:,j)))
    end
    
    %Changes on column 
    %In a 3x3Matrix:
    % 0 0 0 
    % 0 1 0
    % 0 1 1
    % 
    % 0 1 1 changes
    columns_changes = 0;
    for i=2:rows-1
        columns_changes = columns_changes + ((image(i-1,:) ~= image(i,:)))
    end
    
    total_changes = rows_changes + columns_changes;
    complexity = total_changes/max_pos_changes;
end


%Function that segment each bit-plane of the image into informative and
%noise-like regions using a thresholdvalue
%Input: Matrix bitplane (NxNx8)
function [noise,informative] = segmentation(BP,alpha=0.3)   
    complexity = [];
    
    for i=1:8
        complexity = [complexity get_complexity(BP(:,:,i))];
    end
    
    noise = [];
    informative = [];
    for i=1:n
        if (complexity(i)<=alpha)
            noise = cat(3,noise,BP(:,:,i));
        else
            informative = cat(3,informative,BP(:,:,i)); 
        end
    end
end



function Sstar = conjugate(S)
    [rows,columns)=size(S);
    Wc = zeros(rows,columns);
    Wc(2:2:end,1:2:end)=1;
    Wc(1:2:end,2:2:end)=1;    
    Sstar = xor(S,Wc);
end


function secret_block_preparation(B)
    
    complexity = get_complexity(S);
    if (complexity < alpha)
        S = conjugate(S);
    end
    
end



