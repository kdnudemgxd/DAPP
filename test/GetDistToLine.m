function DistToLine = GetDistToLine(PointOnSlash2,StartPoint,GoalPoint)
DistToLine = zeros(size(PointOnSlash2,1),1);
for i = 1:length(DistToLine)
    %计算点到终点与起点连线的距离
    DistToLine(i) = abs(det([GoalPoint-StartPoint;PointOnSlash2(i,:)-StartPoint]))/norm(GoalPoint-StartPoint);
end
end