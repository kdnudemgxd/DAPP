function DelayTime = GetDelayTime(TotalPath,TaskGroup)
% 得到任务完成延迟
DelayTime = mean(TotalPath.EndTime(1:length(TaskGroup.ArriveTimes))' - TaskGroup.ArriveTimes);
end