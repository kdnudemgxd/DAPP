function AveragePathLength = GetAveragePathLength(TotalPath)
% 计算平均路径长度
SumofLength = 0;
AveragePathLength = 0;
for i = 1:length(TotalPath.TotalSet)
    Index = sub2ind([34 22],TotalPath.TotalSet{i}(:,1),TotalPath.TotalSet{i}(:,2)); %转换为线性索引
    D = logical(diff(Index)); %差分并取逻辑值已检验是否和上一个点重合
    SumofLength = SumofLength + sum(D); %求和得到实际行走长度
end
AveragePathLength = SumofLength/length(TotalPath.TotalSet);
end