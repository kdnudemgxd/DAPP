    CurrentPointLocations = zeros(size(PathSet,1),2);
    %更新现在位置集合
    for i = 1:size(PathSet,1)
        if ~isempty(PathSet{i})
            %路径非空，已经行驶一段时间，现在位置为路径中的某个位置
            CurrentPointLocations(i,:) = PathSet{i}((SystemTime-Path.StartTime(TaskSetNum(i)))/StepTime+1,:);
        else
            %路径为空，说明刚开始分配，现在位置为起点
            CurrentPointLocations(i,:) = TaskSet(i,1:2);
        end
    end