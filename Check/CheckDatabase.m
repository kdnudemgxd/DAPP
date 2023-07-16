function [SubgraphsPath,SubgraphsPathPeriod] = CheckDatabase(TaskDatabase,PathDatabase,Subgraphs,SignSubgraphs,SubgraphTypes,SubgraphsPoints,CurrentPointLocations,TemporaryGoalPoints)
%UNTITLED11 �������ݼ�������ͼ·��
% SubgraphsPath����ͼ·��
% SubgraphsPathPeriod����ͼ��������
SubgraphsPath = cell(length(SignSubgraphs),1);
SubgraphsPathPeriod = zeros(length(SignSubgraphs),1);
for i = find(SignSubgraphs)'
    %SubgraphStart����ͼ���
    %SubgraphTempGoal����ͼ��ʱĿ���
    SubgraphStart.GlobalCoordinate = CurrentPointLocations(SubgraphsPoints{i}(:),:);
    SubgraphTempGoal.GlobalCoordinate = TemporaryGoalPoints{i,1};
    %�ҳ��ڶ�Ӧ��ͼ�еľֲ�����
    [~,b] = min(sum(Subgraphs(:,:,i),2)); %�ҳ���ͼ����С�ĵ�
    SubgraphStart.LocalCoordinate = SubgraphStart.GlobalCoordinate - Subgraphs(b,:,i) +[1,1];
    SubgraphTempGoal.LocalCoordinate = SubgraphTempGoal.GlobalCoordinate - Subgraphs(b,:,i) +[1,1];
    %������ͼ���ͣ�ת��Ϊ���
    if SubgraphTypes(i) == 1 %ˮƽ��ͼ
        SubgraphStart.Num = (SubgraphStart.LocalCoordinate(:,1) + SubgraphStart.LocalCoordinate(:,2)*3-3)';
        SubgraphTempGoal.Num = (SubgraphTempGoal.LocalCoordinate(:,1) + SubgraphTempGoal.LocalCoordinate(:,2)*3-3)';
    elseif SubgraphTypes(i) == 2 %��ֱ��ͼ
        SubgraphStart.Num = (SubgraphStart.LocalCoordinate(:,2) + SubgraphStart.LocalCoordinate(:,1)*3-3)';
        SubgraphTempGoal.Num = (SubgraphTempGoal.LocalCoordinate(:,2) + SubgraphTempGoal.LocalCoordinate(:,1)*3-3)';
    end
    %�ҳ����ֱ任��˳����С������
    MinArrange.Num = MinArrange_3_2([SubgraphStart.Num SubgraphTempGoal.Num]);
    MinArrange.Str = num2str(MinArrange.Num,'%d');
    MinArrange.Seq = find(ismember(TaskDatabase,MinArrange.Str));
    %�õ��ַ���·��
    LocalPath.Str = PathDatabase{MinArrange.Seq,1}; %�ַ���·��
    %ת��Ϊ����·��
    LocalPath.Coordinate = TransformPath(SubgraphTypes(i),LocalPath.Str,MinArrange.Num,SubgraphStart.Num,SubgraphTempGoal.Num);
    SubgraphsPath{i} = LocalPath.Coordinate + Subgraphs(b,:,i) - [1,1];
    SubgraphsPathPeriod(i) = size(SubgraphsPath{i},1) - 1;
end

end

