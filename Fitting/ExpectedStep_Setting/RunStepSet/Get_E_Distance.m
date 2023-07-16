function E_Distance = Get_E_Distance(MAP,Entrances,Exits)
%UNTITLED2 函数求出对于特定地图中所生成任务的期望概率
% 输出参数：
% E_Distance 任务距离期望值

% 参数说明：
% MAP 地图，-1为障碍物，2为可行空间
% Entrances 入口坐标集
% Exits 出口坐标集
% Edge = 2;
% E_Distance = 0;
% MAP2 = MAP;
% MAP2(MAP2 == -1) = 0;
% MAP2(MAP2 == 2) = 1;
% S = sum(MAP2(:,Edge+1:end-Edge),'all'); %会被计入期望的点的总数
% for i = 1:size(MAP,1)
%     for j = Edge+1:size(MAP,2)-Edge %暂定边缘部分不计入统计
%         Sign_1 = any(all(Entrances == [i,j],2)); %表示节点是否和入口相同（求期望的节点不应该相同）
%         Sign_2 = any(all(Exits == [i,j],2)); %表示节点是否和出口相同（求期望的节点不应该相同）
%         Sign_3 = MAP(i,j)==2; %可到达点
%         if ~Sign_1 && ~Sign_2 && Sign_3
%             Distance_1 = sum(abs([i,j] - Entrances),2);
%             Distance_2 = min(sum(abs([i,j] - Exits),2));
%             Distance_3 = mean(Distance_1) + Distance_2;
%         end
%         E_Distance = E_Distance + Distance_3/S;
%     end
% end

%% 新的计算方法，更准确
E_Distance = 0;
MAP_1 = MAP == -1;
MAP_1(:,[1:2 end-1:end]) = 0;
[X,Y] = find(MAP_1);
SortingPoints = [X Y];
for i = 1:size(Entrances,1)
    for j = 1:size(X,1)
        Distance_1 = sum(abs(Entrances(i,:)-SortingPoints(j,:)));
        Distance_2 = min(sum(abs(Exits-SortingPoints(j,:)),2));
        Distance_3 = Distance_1+Distance_2;
        E_Distance = E_Distance + Distance_3;
    end
end
E_Distance = E_Distance/(size(Entrances,1)*size(X,1));
end