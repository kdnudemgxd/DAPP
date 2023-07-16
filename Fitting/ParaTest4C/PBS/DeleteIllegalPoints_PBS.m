function Points_SpeDis_Return = DeleteIllegalPoints_PBS(MAP,Points_SpeDis,Entrances,ExistingTaskDes)
%% 删除不可行点_PBS（针对PBS，只删除障碍点）
% 参数
% MAP 地图
% Points_SpeDis 已生成的特定距离的点集（线性坐标）
% Entrances 地图入口位置（二维坐标）
% ExistingTaskDes 已存在的任务目的点（二维坐标）
% 返回值
% Points_SpeDis_Return 返回的符合规则的特点距离的线性坐标
%% 程序
% Line_Entrances = sub2ind(size(MAP),Entrances(:,1),Entrances(:,2)); %转化为线性坐标
% if ~isempty(ExistingTaskDes)
%     Line_ExistingTaskDes = sub2ind(size(MAP),ExistingTaskDes(:,1),ExistingTaskDes(:,2)); %转化为线性坐标
% else
%     Line_ExistingTaskDes = [];
% end
%做差集
Points_SpeDis_Return = Points_SpeDis;
% Points_SpeDis_Return = setdiff(Points_SpeDis_Return,Line_Entrances);
% Points_SpeDis_Return = setdiff(Points_SpeDis_Return,Line_ExistingTaskDes);
Points_SpeDis_Return = Points_SpeDis_Return(MAP(Points_SpeDis_Return) ~= -1); %地图中不为障碍物的点
end