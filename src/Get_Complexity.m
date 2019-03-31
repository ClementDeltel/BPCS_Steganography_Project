function [alpha,complexity] = Get_Complexity(bitplane)

    % Length of the black-and-white border
    [rows,columns] = size(bitplane);
    % Max. possible changes in the bitplane
    if (rows == 1)
        maxPosChanges = columns - 1;
    elseif (columns == 1)
        maxPosChanges = rows - 1;
    else
      maxPosChanges = (rows-1)*columns+rows*(columns-1);
    end

    rowsChanges = 0;
    for i= 1:rows
        for j= 2:columns
            rowsChanges = rowsChanges + sum((bitplane(i,j-1) ~= bitplane(i,j)));
        end
    end

    columnsChanges = 0;
    for j= 1:columns
        for i= 2:rows
            columnsChanges = columnsChanges + sum((bitplane(i-1,j) ~= bitplane(i,j)));
        end
    end
    % Total changes and complexity
    totalChanges = rowsChanges + columnsChanges;
    if (maxPosChanges > 0)
         % This type of complexity is called alpha
         alpha = totalChanges/maxPosChanges;
    end

    %Document on the Google Drive to fill the next sections: Uncompressed Image Steganography using BPCS: Survey and Analysis

%     %% Run-length irregularity
%     rows= 8;
%     columns= 8;
%     %bitplane = randi([0 1],rows,columns);
%     bitplane = [ 1 1 1 1 1 0 1 1 ; 1 1 1 1 1 0 1 1 ; 1 1 1 1 1 0 1 1 ; 1 1 1 1 1 0 1 1 ; 1 1 1 1 1 0 1 1 ; 0 0 0 0 0 1 0 0 ; 1 1 1 1 1 0 1 1 ; 1 1 1 1 1 0 1 1];
%     % [hr,hc] = Run_frequency(bitplane);
%     %hr
%     %hc
%     % Sum(1,:) = sum of each rows
%     % Sum (2,:) = sum of each columns
%     SUM=zeros(2,columns);
%     for i =1:rows
%         for j=1:columns
%             SUM(1,i) = SUM(1,i) + hr(i,j); 
%             SUM(2,i) = SUM(2,i) + hc(j,i); 
%         end
%     end
%    
%    %SUM
%     
%     pr=zeros(rows,columns);
%     pc=zeros(rows,columns);
%     for i = 1:rows
%         for j = 1:columns
%             pr(i,j) = hr(i,j)/SUM(1,i);
%             pc(j,i) = hc(j,i)/SUM(2,i);
%         end
%     end
%     %pr
%     %pc
%     % hs is used to measure the irregularity of a binary pixel sequence
%     % hs(1,:) are all the rows
%     % hs(2,:) are all the columns
%     hs = zeros(2,rows);
%     for i=1:rows
%         for j = 1:columns %columns is equal to the length of the row
%             if ne(pr(i,j),0)
%                 hs(1,i) =  hs(1,i)  - hr(i,j)*log2(pr(i,j));
%             end
%             if ne(pc(j,i),0)
%                 hs(2,i) =  hs(2,i) - hc(j,i)*log2(pc(j,i));
%             end
%         end
%     end
%     %hs
%     hsnorm = hs;
%     
%     for i = 1:2
%         for j = 1:rows
%             hsnorm(i,j)=(hs(i,j)-min(hs(:)))/(max(hs(:))-min(hs(:)));
%         end
%     end
% 
%     %hsnorm
%     
%     hsmean=mean(hsnorm,2);
%     
%     
%     beta = min(hsmean(:))
% 
%     % Border Noisiness
% %     %Random values
% %     rows = 64;
% %     columns = 64;
% %     %Replace by bitplane normally
% %     bitplane = randi([0 1], rows,columns);
%     rhoR = zeros(rows-1,columns);
%     rhoC = zeros(rows,columns-1);
%     SUMR = zeros(rows-1,1);
%     SUMC = zeros(1,columns-1);
%     for i= 2:rows
%         for j= 1:columns
%             rhoR(i-1,j)= bitor(bitplane(i-1,j),bitplane(i,j));
%             rhoC(j,i-1)=bitor(bitplane(j,i-1),bitplane(i,j));
%         end
%     end
%     for i = 1:rows-1
%         for j = 1:columns
%             if isequal(rhoR(i,j),1)
%                 SUMR(i,1)= SUMR(i,1)+1;
%             end
%             if isequal(rhoC(j,i),1)
%                 SUMC(1,i)= SUMC(1,i)+1;
%             end
%         end
%     end
%     varR =  var(SUMR);
%     varC  = var(SUMC);
%     MAX=max(varR,varC);
% 
%     E = zeros(1,2);
%     E(1,1) = ((1-varR)/MAX)*mean(SUMC);
%     E(1,2) = ((1-varC)/MAX)*mean(SUMR);
% 
% %     varR = var(rhoR,0,2);
% %     varC = var(rhoC);
% %     meanR=mean(rhoR,2);
% %     meanC = mean(rhoC);
% % 
% %     E = zeros(2,columns-1);
% %     for i = 1:rows-1
% %         E(1,i) = ((1-varR(i,1))/max(varR))*meanR(i,1);
% %         E(2,i) = ((1-varC(1,i))/max(varC))*meanC(1,i);
% %     end
% %     E
% 
% %     x = randi([0 1],rows,columns)
% %     y = var(x,0,2)
% %     c=max(y)
% %     d=mean(x(:))
%     
%    
%     
%     gamma = min(E(:))/rows


    %% Final complexity - how to combine those values ?
    beta =0;
    gamma =0;
    complexity = alpha + beta + gamma;
end
