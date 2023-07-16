function [TaskGroup,Entrances,Exits] = ExperimentTaskSetCreat(Row,Column,MAP,TaskNumPerEntrance)
%UNTITLED10 此处显示有关此函数的摘要
% TaskSet.StartPoints ,任务起点，即入口位置
% TaskSet.GoalPoints ,任务目标点
% TaskSet.ExitPoints ,任务离开点
NumAGV = 1;
[m,n] = size(MAP);
ExitPoints = zeros(2*Row,2);
EndPoints = zeros(2*Row,2);
%局部目标点选择集合
LocalGoalSet = [0 -1;1 -1;2 0;2 1;1 2;0 2;-1 1;-1 0];
%入口与出口
Entrances = zeros(2*Row,2);
Exits = zeros(2*Row,2);
Entrances(1:Row,:) = [(1:Row)'*4-2',ones(Row,1)];
Entrances(Row+1:2*Row,:) = [(1:Row)'*4-2',ones(Row,1)*n];
Exits = [Entrances(:,1)-1,Entrances(:,2)];
%任务结构体
TaskGroup.StartPoints = Entrances;
TaskGroup.GoalPoints = zeros(2*Row,2,TaskNumPerEntrance);
TaskGroup.ExitPoints = zeros(2*Row,2,TaskNumPerEntrance);
%% 多组任务
for Group = 1:TaskNumPerEntrance
    %分拣任务点
    for i = 1 : 2*Row
        j = randi(8);
        %随机在所选择的分拣窗格周围选择一个位置
        EndPoints(i,:) = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);
        while any(all(EndPoints(1:i-1,:) == EndPoints(i,:),2))
            EndPoints(i,:) = [4*randi(Row)-1,4*randi(Column)+1] + LocalGoalSet(j,:);
        end
    end
    %离开点
    for i = 1 : 2*Row
        Distance = Exits - EndPoints(i,:);
        Distance = sum(abs(Distance),2);
        [~,j] = min(Distance);
        ExitPoints(i,:) = Exits(j,:);
    end
    %% 记录任务
    TaskGroup.GoalPoints(:,:,Group) = EndPoints;
    TaskGroup.ExitPoints(:,:,Group) = ExitPoints;
end
end

