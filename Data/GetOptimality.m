function Optimality = GetOptimality(TotalDistance,TaskGroup)
% 花费步数与最短曼哈顿距离比值
OptimalDistance = sum(abs(TaskGroup.GoalPoints - TaskGroup.StartPoints)) + sum(abs(TaskGroup.ExitPoints - TaskGroup.GoalPoints));
OptimalDistance = sum(OptimalDistance);
Optimality = TotalDistance/OptimalDistance;

end