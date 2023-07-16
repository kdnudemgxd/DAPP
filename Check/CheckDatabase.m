function [SubgraphsPath,SubgraphsPathPeriod] = CheckDatabase(TaskDatabase,PathDatabase,Subgraphs,SignSubgraphs,SubgraphTypes,SubgraphsPoints,CurrentPointLocations,TemporaryGoalPoints)
%UNTITLED11 依据数据集检测出子图路径
% SubgraphsPath，子图路径
% SubgraphsPathPeriod，子图存在周期
SubgraphsPath = cell(length(SignSubgraphs),1);
SubgraphsPathPeriod = zeros(length(SignSubgraphs),1);
for i = find(SignSubgraphs)'
    %SubgraphStart，子图起点
    %SubgraphTempGoal，子图临时目标点
    SubgraphStart.GlobalCoordinate = CurrentPointLocations(SubgraphsPoints{i}(:),:);
    SubgraphTempGoal.GlobalCoordinate = TemporaryGoalPoints{i,1};
    %找出在对应子图中的局部坐标
    [~,b] = min(sum(Subgraphs(:,:,i),2)); %找出子图中最小的点
    SubgraphStart.LocalCoordinate = SubgraphStart.GlobalCoordinate - Subgraphs(b,:,i) +[1,1];
    SubgraphTempGoal.LocalCoordinate = SubgraphTempGoal.GlobalCoordinate - Subgraphs(b,:,i) +[1,1];
    %根据子图类型，转换为编号
    if SubgraphTypes(i) == 1 %水平子图
        SubgraphStart.Num = (SubgraphStart.LocalCoordinate(:,1) + SubgraphStart.LocalCoordinate(:,2)*3-3)';
        SubgraphTempGoal.Num = (SubgraphTempGoal.LocalCoordinate(:,1) + SubgraphTempGoal.LocalCoordinate(:,2)*3-3)';
    elseif SubgraphTypes(i) == 2 %垂直子图
        SubgraphStart.Num = (SubgraphStart.LocalCoordinate(:,2) + SubgraphStart.LocalCoordinate(:,1)*3-3)';
        SubgraphTempGoal.Num = (SubgraphTempGoal.LocalCoordinate(:,2) + SubgraphTempGoal.LocalCoordinate(:,1)*3-3)';
    end
    %找出多种变换中顺序最小的排列
    MinArrange.Num = MinArrange_3_2([SubgraphStart.Num SubgraphTempGoal.Num]);
    MinArrange.Str = num2str(MinArrange.Num,'%d');
    MinArrange.Seq = find(ismember(TaskDatabase,MinArrange.Str));
    %得到字符串路径
    LocalPath.Str = PathDatabase{MinArrange.Seq,1}; %字符串路径
    %转化为坐标路径
    LocalPath.Coordinate = TransformPath(SubgraphTypes(i),LocalPath.Str,MinArrange.Num,SubgraphStart.Num,SubgraphTempGoal.Num);
    SubgraphsPath{i} = LocalPath.Coordinate + Subgraphs(b,:,i) - [1,1];
    SubgraphsPathPeriod(i) = size(SubgraphsPath{i},1) - 1;
end

end

