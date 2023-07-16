function [SignBreak,Location] = CheckBreak(PathSet)
%UNTITLED 检测路径断裂情况
%   此处显示详细说明
SignBreak = 0;
Location = zeros(1,2);
for i = 1:size(PathSet,1)
    testpoint1 = PathSet{i}(1,:);
    for j = 2:size(PathSet{i},1)
        testvalue = PathSet{i}(j,:) - PathSet{i}(j-1,:);
        testvalue = abs(testvalue(1))+abs(testvalue(2));
        if testvalue > 1
            SignBreak = 1;
            Location = [i j];
            return;
        end
    end
end
end

