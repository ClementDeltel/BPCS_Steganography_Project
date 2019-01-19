function complexity = Get_Complexity(Bitplane)
    [rows,columns] = size(Bitplane);
    % Max. possible changes in the bitplane
    if (rows == 1)
        max_pos_changes = columns - 1;
    elseif (columns == 1)
        max_pos_changes = rows - 1;
    else
      max_pos_changes = (rows-1)*columns+rows*(columns-1);
    end

    rows_changes = 0;
    for i= 1:rows
        for j= 2:columns
            rows_changes = rows_changes + sum((Bitplane(i,j-1) ~= Bitplane(i,j)));
        end
    end

    columns_changes = 0;
    for j= 1:columns
        for i= 2:rows
            columns_changes = columns_changes + sum((Bitplane(i-1,j) ~= Bitplane(i,j)));
        end
    end
    % Total changes and complexity
    total_changes = rows_changes + columns_changes;
    if (max_pos_changes > 0)
         % This type of complexity is called alpha
         alpha = total_changes/max_pos_changes;
    end

    complexity = alpha;
end
