function [testsign,testgroup,testall] = CheckColliding(PathSet,SystemTime,Path,TaskSetNum)
%���·��֮��ĳ�ͻ
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
        testsign = 1; %��ʾ�г�ͻ
    end
end
end

