function [MAP,Entrances,Exits,SortingPanes] = CreateExperimentMAP(Row,Column)
%创建实验所需地图
% Obstacle=-1, Space=2, Subgraph = 3
%Row 地图中分拣窗格行数
%Column 地图中分拣窗格列数
%装载窗格下方，行号从小到大第一个为出口，第二个为入口
%添加对分拣窗格的位置描述，但是因为分拣窗格占用4个位置，所以采用平均的位置坐标
MAP = ones(4*Row+2,4*Column+6)*2;
SortingPanes = zeros(Row*Column,2);
for i = 1:Row
    for j = 0:Column+1
        MAP(4*i-1:4*i,4*j+1:4*j+2) = -1;
        if j > 0 && j < Column+1
        SortingPanes(i+(j-1)*Row,:) = [mean([4*i-1:4*i]) mean(4*j+1:4*j+2)];
    end
end
%入口与出口
[m,n] = size(MAP);
Entrances = zeros(2*Row+2,2);
Exits = zeros(2*Row+2,2);
Entrances(1:Row+1,:) = [(1:Row+1)'*4-2',ones(Row+1,1)];
Entrances(Row+2:2*Row+2,:) = [(1:Row+1)'*4-2',ones(Row+1,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
end