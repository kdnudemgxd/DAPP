function [testsign,testgroup,testall] = CheckColliding(PathSet,SystemTime,Path,TaskSetNum)
%检测路径之间的冲突
%

for i = 1:size(PathSet,1)
%     cp(i,:) = PathSet{i}(SystemTime-1,:);
%     np(i,:) = PathSet{i}(SystemTime,:);
    cp(i,:) = PathSet{i}(SystemTime-Path.StartTime(TaskSetNum(i))+1-1,:);
    np(i,:) = PathSet{i}(SystemTime-Path.StartTime(TaskSetNum(i))+2-1,:);
end
[testgroup,testall] = CollidingRobotPairs(cp,np);
testsign = 0;
for i = 1:size(testgroup,2)
    if ~isempty(testgroup)
        testsign = 1; %表示有冲突
    end
end
end

