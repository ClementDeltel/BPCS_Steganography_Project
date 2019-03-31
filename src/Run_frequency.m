function [hr,hc] = Run_frequency(bitplane)

size2 = size(bitplane);
rows = size2(1);
columns = size2(2);
hr = zeros(rows, columns);
hc = zeros (rows, columns);

for i = 1:rows
    temp=1;
    for j = 2:columns
        if j~=columns
            if isequal(bitplane(i,j-1),bitplane(i,j))
                temp = temp + 1;
            else
                hr(i,temp) = hr(i,temp) + 1;
                temp = 1 ;
            end
        else
            if isequal(bitplane(i,j-1),bitplane(i,j))
                temp = temp + 1;
                hr(i,temp) = hr(i,temp) + 1;
            else
                hr(i,temp) = hr(i,temp) + 1;
                temp = 1 ;
                hr(i,temp) = hr(i,temp) + 1;
            end
        end
    end
end

for j = 1:columns
    temp=1;
    for i = 2:rows
        if i~=rows
            if isequal(bitplane(i-1,j),bitplane(i,j))
                temp = temp + 1;
            else
                hc(temp,j) = hc(temp,j) + 1;
                temp = 1 ;
            end
        else
            if isequal(bitplane(i-1,j),bitplane(i,j))
                temp = temp + 1;
                hc(temp,j) = hc(temp,j) + 1;
            else
                hc(temp,j) = hc(temp,j) + 1;
                temp = 1 ;
                hc(temp,j) = hc(temp,j) + 1;
            end
        end
    end
end
end