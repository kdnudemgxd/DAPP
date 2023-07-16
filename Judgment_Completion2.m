function MissionComplete = Judgment_Completion2(TaskGroup,TaskSetNum,PathSet)
%判断任务完成,1为到目标点，2为到出口
%   此处显示详细说明
MissionComplete = zeros(length(TaskSetNum),1);
for i = 1:length(TaskSetNum)
    Index_Goal = find(ismember(PathSet{i},TaskGroup.GoalPoints(TaskSetNum(i),:),'rows'));
    Index_Exit = find(ismember(PathSet{i},TaskGroup.ExitPoints(TaskSetNum(i),:),'rows'));
    if ~isempty(Index_Goal) && ~isempty(Index_Exit) && max(Index_Exit) > max(Index_Goal) %判断目标点已经到达
        %到达出口
        MissionComplete(i) = 2;
    elseif ~isempty(Index_Goal)
        %到达目标点
        MissionComplete(i) = 1;
    end
end
end

