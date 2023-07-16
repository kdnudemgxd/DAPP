function Points_SpeDis = FindPoints_SpeDis(MAP,TaskPoint,Distance)
%% 找出在MAP范围内，与指定点TaskPoint的曼哈顿距离为Distance的所有点
%参数：
%TaskPoint 所选择的任务起点
%Distance 所设置的距离

% 返回
%Points_SpeDis 距离指定点TaskPoint的曼哈顿距离为Distance的所有点
%% 程序
[X,Y]=meshgrid(1:size(MAP,1),1:size(MAP,2)); %地图的坐标网格
Dis = abs(X' - TaskPoint(1)) + abs(Y' - TaskPoint(2)); %为了和线性索引相对应，所以转置了X和Y
%返回值为线性坐标
Points_SpeDis = find(Dis == Distance); 
end
