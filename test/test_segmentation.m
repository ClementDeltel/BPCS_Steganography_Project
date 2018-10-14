BPc = [0 0 0 0; 1 0 0 0; 1 1 0 1; 1 0 1 1; 1 1 1 1;1 0 1 0; 1 0 1 1; 0 0 0 0];

disp('Testing segmentation...\n')
disp('Get complexity of matrix ')
disp(BPc)
[noise, informative] = segmentation(BPc);
disp('The noise areas are')
disp(noise)
disp('The informative areas are')
disp(informative)

assert(isequal([1 5 8],noise),'Fail to get noise bp')
assert(isequal([2 3 4 6 7],informative),'Fail to get informative bp')