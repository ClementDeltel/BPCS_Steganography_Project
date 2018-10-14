clear all

BPc = [0 0 0 0; 1 0 0 0; 1 1 0 1; 1 0 1 1; 1 1 1 1;1 0 1 0; 1 0 1 1; 0 0 0 0];

disp('Testing get complexity...\n')
disp('Get complexity of matrix ')
disp(BPc)
complexity = zeros(8,1);
for i=1:8
    complexity(i) = get_complexity(BPc(i,:));
end
disp('The complexity obteined is ')
disp(complexity)

assert(isequal([0; 1/3; 2/3; 2/3; 0/3; 3/3; 2/3; 0],complexity),'Fail to get correct complexity')

