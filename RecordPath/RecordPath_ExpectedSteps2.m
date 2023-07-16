function [PathSet,SystemTime] = RecordPath_ExpectedSteps2(RouteNow,FinalTime,SystemTime,StepTime,ExpectedSteps,TaskGroup,TaskSetNum,SignTaskComplete,PathSet,CurrTempGoal)
%记录依照ExpectedSteps所设定步数的路径并增加系统时间
%删除TaskGroup_T,改为由TaskGroup代替判定是否记录所有路径（即判定记录ExpectedSteps长度的路径，还是记录所有路径）

%判断是否全部行驶至最后一段路径，若全部为最后一段路径，则不需要进行预测，直接记录所有路径
SignEnd = 1;
if any(SignTaskComplete == 0) %任务未分配完
    SignEnd = 0;
else
    CurrTempGoal_2 = zeros(size(CurrTempGoal,1),2); %提取临时目标，用于判断是否和出口相同
    for i = 1:size(CurrTempGoal,1)
        if CurrTempGoal(i,3) == 0
            CurrTempGoal_2(i,:) = CurrTempGoal(i,1:2);
        else
            CurrTempGoal_2(i,:) = CurrTempGoal(i,3:4);
        end
    end
    if ~all(all(CurrTempGoal_2 == TaskGroup.ExitPoints(TaskSetNum,:),2)) %临时目标点和出口不全相同，则还未完成
        SignEnd = 0;
    end
end
if (SignEnd == 1) || (FinalTime < ExpectedSteps)
    %此情况已经到达最后一步,或路径长度小于按预测所得的长度，只需要直接记录所有路径，无需按照预测时间记录
    for i = 1:length(TaskSetNum)
        PathSet{i}((end+1):(end+FinalTime),:) = RouteNow(2:FinalTime+1,:,i);
    end
    SystemTime = SystemTime + FinalTime*StepTime;
else %此时未到达最后一步，按照预测时间进行记录
    for i = 1:length(TaskSetNum)
        PathSet{i}((end+1):(end+ExpectedSteps),:) = RouteNow(2:ExpectedSteps+1,:,i);
    end
    SystemTime = SystemTime + ExpectedSteps*StepTime;
end
end