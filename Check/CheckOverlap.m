function [OverlapSign,OverlapTab] = CheckOverlap(PointSet)
%CHECKOVERLAP 检测所给的点集中是否有一样的点
% OverlapSign 重合标志，1为重合；0为不重合
% OverlapTab 任务重合表，表示各个任务重合的次数
OverlapSign = 0;
OverlapTab = zeros(size(PointSet,1),1);
%% 提取终点
TaskNowDes = zeros(size(PointSet,1),2); 
if size(PointSet,2) > 2
    %如果有两个目标点，则采用
    for i = 1:size(PointSet,1)
        if PointSet(i,3) == 0
            TaskNowDes(i,:) = PointSet(i,1:2);
        else
            TaskNowDes(i,:) = PointSet(i,3:4);
        end
    end
else
    TaskNowDes = PointSet;
end
%% 计算重合
for i = 1:size(TaskNowDes,1)
    OverlapTab(i) = sum(all(TaskNowDes(i,:) == TaskNowDes , 2));
end
if max(OverlapTab) > 1
    OverlapSign = 1;
end

end